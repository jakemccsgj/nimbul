#!/usr/bin/ruby
# 
# A Ruby client library for memcached (memory cache daemon)
# 
# == Synopsis
# 
#   require 'memcache'
#
#	cache = MemCache::new '10.0.0.15:11211',
#                        '10.0.0.15:11212',
#                        '10.0.0.17:11211:3', # weighted
#						 :debug => true,
#						 :c_threshold => 100_000,
#                        :compression => false,
#						 :namespace => 'foo'
#   cache.servers += [ "10.0.0.15:11211:5" ]
#   cache.c_threshold = 10_000
#   cache.compression = true
#
#   # Cache simple values with simple String or Symbol keys
#   cache["my_key"] = "Some value"
#   cache[:other_key] = "Another value"
# 
#   # ...or more-complex values
#   cache["object_key"] = { 'complex' => [ "object", 2, 4 ] }
#
#	# ...or more-complex keys
#   cache[ Time::now.to_a[1..7] ] ||= 0
#
#	# ...or both
#   cache[userObject] = { :attempts => 0, :edges => [], :nodes => [] }
#
#   val = cache["my_key"]				# => "Some value"
#   val = cache["object_key"]			# => {"complex" => ["object",2,4]}
#   print val['complex'][2]				# => 4
#
# == Notes
#
# * Symbols are stringified currently because that's the only way to guarantee
#   that they hash to the same value across processes.
#
#
# == Known Bugs
#
# * If one or more memcacheds error when asked for 'map' or 'malloc' stats, it
#   won't be possible to retrieve them from any of the other servers,
#   either. This is due to the way that the client handles server error
#   conditions, and needs rethinking.
#
#
# == Authors
# 
# * Michael Granger <ged@FaerieMUD.org>
# 
# Thanks to Martin Chase and Rick Bradley for peer review, bugfixes, and
# suggestions.
#
#
# == Copyright
#
# Copyright (c) 2003, 2004 The FaerieMUD Consortium. All rights reserved.
# 
# This module is free software. You may use, modify, and/or redistribute this
# software under the same terms as Ruby.
#
#
# == Subversion Id
#
#  $Id: memcache.rb 31 2004-11-13 17:32:54Z ged $
# 

require 'io/reactor'
require 'socket'
require 'sync'
require 'timeout'
require 'zlib'
require 'uri'


### A Ruby implementation of the 'memcached' client interface.
class MemCache
	include Socket::Constants


	### Class constants

	# SVN Revision
	SVNRev = %q$Rev: 31 $

	# SVN Id
	SVNId = %q$Id: memcache.rb 31 2004-11-13 17:32:54Z ged $

	# SVN URL
	SVNURL = %q$URL: svn+ssh://svn.FaerieMUD.org/var/svn/RMemCache/trunk/lib/memcache.rb $

	# Default compression threshold.
	DefaultCThreshold = 10_000

	# Default memcached port
	DefaultPort = 11211

	# Default 'weight' value assigned to a server.
	DefaultServerWeight = 1

	# Minimum percentage length compressed values have to be to be preferred
	# over the uncompressed version.
	MinCompressionRatio = 0.80

	# Default constructor options
	DefaultOptions = {
		:debug			=> false,
		:c_threshold	=> DefaultCThreshold,
		:compression	=> true,
		:namespace		=> nil,
		:readonly		=> false,
		:urlencode		=> true,
	}

	# Storage flags
	F_SERIALIZED = 1
	F_COMPRESSED = 2
	F_ESCAPED    = 4
	F_NUMERIC	 = 8

	# Line-ending
	CRLF = "\r\n"

	# Flags to use for the BasicSocket#send call. Note that Ruby's socket
	# library doesn't define MSG_NOSIGNAL, but if it ever does it'll be used.
	SendFlags = 0
	SendFlags |= Socket.const_get( :MSG_NOSIGNAL ) if
		Socket.const_defined?( :MSG_NOSIGNAL )
	
	# Patterns for matching against server error replies
	GENERAL_ERROR		 = /^ERROR\r\n/
	CLIENT_ERROR		 = /^CLIENT_ERROR\s+([^\r\n]+)\r\n/
	SERVER_ERROR		 = /^SERVER_ERROR\s+([^\r\n]+)\r\n/
	ANY_ERROR			 = Regexp::union( GENERAL_ERROR, CLIENT_ERROR, SERVER_ERROR )

	# Terminator regexps for the two styles of replies from memcached
	LINE_TERMINATOR 	 = Regexp::union( /\r\n$/, ANY_ERROR )
	MULTILINE_TERMINATOR = Regexp::union( /^END\r\n$/, ANY_ERROR )

	# Callables to convert various part of the server stats reply to appropriate
	# object types.
	StatConverters = {
		:__default__	=> lambda {|stat| Integer(stat) },
		:version		=> lambda {|stat| stat }, # Already a String
		:rusage_user	=> lambda {|stat|
			seconds, microseconds = stat.split(/:/, 2)
			Float(seconds) + (Float(microseconds) / 1_000_000)
		},
		:rusage_system	=> lambda {|stat|
			seconds, microseconds = stat.split(/:/, 2)
			Float(seconds) + (Float(microseconds) / 1_000_000)
		}
	}



	#################################################################
	###	I N S T A N C E   M E T H O D S
	#################################################################

	### Create a new memcache object that will distribute gets and sets between
	### the specified +servers+. You can also pass one or more options as hash
	### arguments. Valid options are:
	### [<b>:compression</b>]
	###   Set the compression flag. See #use_compression? for more info.
	### [<b>:c_threshold</b>]
	###   Set the compression threshold, in bytes. See #c_threshold for more
	###   info.
	### [<b>:debug</b>]
	###   Send debugging output to the object specified as a value if it
	###   responds to #call, and to $deferr if set to anything else but +false+
	###   or +nil+.
	### [<b>:namespace</b>]
	###   If specified, all keys will have the given value prepended before
	###   accessing the cache. Defaults to +nil+.
	### [<b>:urlencode</b>]
	###   If this is set, all keys and values will be urlencoded. If this is not
	###   set, keys and/or values with certain characters in them may generate
	###   client errors when interacting with the cache, but the values used
	###   will be more compatible with those set by other clients. Defaults to
	###   +true+.
	### [<b>:readonly</b>]
	###   If this is set, any attempt to write to the cache will generate an
	###   exception. Defaults to +false+.
	### If a +block+ is given, it is used as the default hash function for
	### determining which server the key (given as an argument to the block) is
	### stored/fetched from.
	def initialize( *servers, &block )
		opts = servers.pop if servers.last.is_a?( Hash )
		opts = DefaultOptions.merge( opts || {} )

		@debug			= opts[:debug]

		@c_threshold	= opts[:c_threshold]
		@compression	= opts[:compression]
		@namespace		= opts[:namespace]
		@readonly		= opts[:readonly]
		@urlencode		= opts[:urlencode]

		@buckets		= nil
		@hashfunc		= block || lambda {|val| val.hash}
		@mutex			= Sync::new

		@reactor		= IO::Reactor::new

		# Stats is an auto-vivifying hash -- an access to a key that hasn't yet
		# been created generates a new stats subhash
		@stats			= Hash::new {|hsh,k|
			hsh[k] = {:count => 0, :utime => 0.0, :stime => 0.0}
		}
		@stats_callback	= nil

		self.servers	= servers
	end


	### Return a human-readable version of the cache object.
	def inspect
		"<MemCache: %d servers/%s buckets: ns: %p, debug: %p, cmp: %p, ro: %p>" % [
			@servers.nitems,
			@buckets.nil? ? "?" : @buckets.nitems,
			@namespace,
			@debug,
			@compression,
			@readonly,
		]
	end


	######
	public
	######

	# The compression threshold setting, in bytes. Values larger than this
	# threshold will be compressed by #[]= (and #set) and decompressed by #[]
	# (and #get).
	attr_accessor :c_threshold
	alias_method :compression_threshold, :c_threshold

	# Turn compression on or off temporarily.
	attr_accessor :compression

	# Debugging flag -- when set to +true+, debugging output will be send to
	# $deferr. If set to an object which supports either #<< or #call, debugging
	# output will be sent to it via this method instead (#call being
	# preferred). If set to +false+ or +nil+, no debugging will be generated.
	attr_accessor :debug

	# The function (a Method or Proc object) which will be used to hash keys for
	# determining where values are stored.
	attr_accessor :hashfunc

	# The Array of MemCache::Server objects that represent the memcached
	# instances the client will use.
	attr_reader :servers

	# The namespace that will be prepended to all keys set/fetched from the
	# cache.
	attr_accessor :namespace

	# Hash of counts of cache operations, keyed by operation (e.g., +:delete+,
	# +:flush_all+, +:set+, +:add+, etc.). Each value of the hash is another
	# hash with statistics for the corresponding operation:
	#   {
	#		:stime	=> <total system time of all calls>,
	#		:utime	=> <total user time> of all calls,
	#		:count	=> <number of calls>,
	#	}
	attr_reader :stats

	# Hash of system/user time-tuples for each op
	attr_reader :times

	# Settable statistics callback -- setting this to an object that responds to
	# #call will cause it to be called once for each operation with the
	# operation type (as a Symbol), and Struct::Tms objects created immediately
	# before and after the operation.
	attr_accessor :stats_callback

	# The Sync mutex object for the cache
	attr_reader :mutex


	### Returns +true+ if the cache was created read-only.
	def readonly?
		@readonly
	end


	### Set the servers the memcache will distribute gets and sets
	### between. Arguments can be either Strings of the form
	### <tt>"hostname:port"</tt> (or "hostname:port:weight"), or
	### MemCache::Server objects.
	def servers=( servers )
		@mutex.synchronize( Sync::EX ) {
			@servers = servers.collect {|svr|
				self.debug_msg( "Transforming svr = %p", svr )

				case svr
				when String
					host, port, weight = svr.split( /:/, 3 )
					weight ||= DefaultServerWeight
					port ||= DefaultPort
					Server::new( host, port.to_i, weight )

				when Array
					host, port = svr[0].split(/:/, 2)
					weight = svr[1] || DefaultServerWeight
					port ||= DefaultPort
					Server::new( host, port.to_i, weight )

				when Server
					svr

				else
					raise TypeError, "cannot convert %s to MemCache::Server" %
						svr.class.name
				end
			}

			@buckets = nil
		}
		
		return @servers			# (ignored)
	end


	### Returns +true+ if there is at least one active server for the receiver.
	def active?
		not @servers.empty?
	end


	### Fetch and return the values associated with the given +keys+ from the
	### cache. Returns +nil+ for any value that wasn't in the cache.
	def get( *keys )
		raise MemCacheError, "no active servers" unless self.active?
		hash = nil

		@mutex.synchronize( Sync::SH ) {
			hash = self.fetch( :get, *keys )
		}

		return *(hash.values_at( *keys ))
	end
	alias_method :[], :get


	### Fetch and return the values associated the the given +keys+ from the
	### cache as a Hash object. Returns +nil+ for any value that wasn't in the
	### cache.
	def get_hash( *keys )
		raise MemCacheError, "no active servers" unless self.active?
		return @mutex.synchronize( Sync::SH ) {
			self.fetch( :get_hash, *keys )
		}
	end


	### Fetch, delete, and return the given +keys+ atomically from the cache.
	#def take( *keys )
	#	raise MemCacheError, "no active servers" unless self.active?
	#	raise MemCacheError, "readonly cache" if self.readonly?
	#
	#	hash = @mutex.synchronize( Sync::EX ) {
	#		self.fetch( :take, *keys )
	#	}
	#
	#	return hash[*keys]
	#end


	### Unconditionally set the entry in the cache under the given +key+ to
	### +value+, returning +true+ on success. The optional +exptime+ argument
	### specifies an expiration time for the tuple, in seconds relative to the
	### present if it's less than 60*60*24*30 (30 days), or as an absolute Unix
	### time (E.g., Time#to_i) if greater. If +exptime+ is +0+, the entry will
	### never expire.
	def set( key, val, exptime=0 )
		raise MemCacheError, "no active servers" unless self.active?
		raise MemCacheError, "readonly cache" if self.readonly?
		rval = nil

		@mutex.synchronize( Sync::EX ) {
			rval = self.store( :set, key, val, exptime )
		}

		return rval
	end


	### Multi-set method; unconditionally set each key/value pair in
	### +pairs+. The call to set each value is done synchronously, but until
	### memcached supports a multi-set operation this is only a little more
	### efficient than calling #set for each pair yourself.
	def set_many( pairs )
		raise MemCacheError, "no active servers" unless self.active?
		raise MemCacheError, "readonly cache" if self.readonly?
		raise MemCacheError,
			"expected an object that responds to the #each_pair message" unless
			pairs.respond_to?( :each_pair )

		rvals = []

		# Just iterate over the pairs, setting them one-by-one until memcached
		# supports multi-set.
		@mutex.synchronize( Sync::EX ) {
			pairs.each_pair do |key, val|
				rvals << self.store( :set, key, val, 0 )
			end
		}

		return rvals
	end


	### Index assignment method. Supports slice-setting, e.g.:
	###   cache[ :foo, :bar ] = 12, "darkwood"
	### This uses #set_many internally if there is more than one key, or #set if
	### there is only one.
	def []=( *args )
		raise MemCacheError, "no active servers" unless self.active?
		raise MemCacheError, "readonly cache" if self.readonly?

		# Use #set if there's only one pair
		if args.length <= 2
			self.set( *args )
		else
			# Args from a slice-style call like
			#   cache[ :foo, :bar ] = 1, 2
			# will be passed in like:
			#   ( :foo, :bar, [1, 2] )
			# so just shift the value part off, transpose them into a Hash and
			# pass them on to #set_many.
			vals = args.pop
			vals = [vals] unless vals.is_a?( Array ) # Handle [:a,:b] = 1
			pairs = Hash[ *([ args, vals ].transpose) ]
			self.set_many( pairs )
		end

		# It doesn't matter what this returns, as Ruby ignores it for some
		# reason.
		return nil
	end


	### Like #set, but only stores the tuple if it doesn't already exist.
	def add( key, val, exptime=0 )
		raise MemCacheError, "no active servers" unless self.active?
		raise MemCacheError, "readonly cache" if self.readonly?

		@mutex.synchronize( Sync::EX ) {
			self.store( :add, key, val, exptime )
		}
	end


	### Like #set, but only stores the tuple if it already exists.
	def replace( key, val, exptime=0 )
		raise MemCacheError, "no active servers" unless self.active?
		raise MemCacheError, "readonly cache" if self.readonly?

		@mutex.synchronize( Sync::EX ) {
			self.store( :replace, key, val, exptime )
		}
	end


	### Atomically increment the value associated with +key+ by +val+. Returns
	### +nil+ if the value doesn't exist in the cache, or the new value after
	### incrementing if it does. +val+ should be zero or greater.  Overflow on
	### the server is not checked.  Beware of values approaching 2**32.
	def incr( key, val=1 )
		raise MemCacheError, "no active servers" unless self.active?
		raise MemCacheError, "readonly cache" if self.readonly?

		@mutex.synchronize( Sync::EX ) {
			self.incrdecr( :incr, key, val )
		}
	end


	### Like #incr, but decrements. Unlike #incr, underflow is checked, and new
	### values are capped at 0.  If server value is 1, a decrement of 2 returns
	### 0, not -1.
	def decr( key, val=1 )
		raise MemCacheError, "no active servers" unless self.active?
		raise MemCacheError, "readonly cache" if self.readonly?

		@mutex.synchronize( Sync::EX ) {
			self.incrdecr( :decr, key, val )
		}
	end


	### Delete the entry with the specified key, optionally at the specified
	### +time+.
	def delete( key, time=nil )
		raise MemCacheError, "no active servers" unless self.active?
		raise MemCacheError, "readonly cache" if self.readonly?
		svr = nil

		res = @mutex.synchronize( Sync::EX ) {
			svr = self.get_server( key )
			cachekey = self.make_cache_key( key )

			self.add_stat( :delete ) do
				cmd = "delete %s%s" % [ cachekey, time ? " #{time.to_i}" : "" ]
				self.send( svr => cmd )
			end
		}

		res && res[svr].rstrip == "DELETED"
	end


	### Mark all entries on all servers as expired.
	def flush_all
		raise MemCacheError, "no active servers" unless self.active?
		raise MemCacheError, "readonly cache" if self.readonly?

		res = @mutex.synchronize( Sync::EX ) {

			# Build commandset for servers that are alive
			servers = @servers.select {|svr| svr.alive? }
			cmds = self.make_command_map( "flush_all", servers )

			# Send them in parallel
			self.add_stat( :flush_all ) {
				self.send( cmds )
			}
		}

		!res.find {|svr,st| st.rstrip != 'OK'}
	end
	alias_method :clear, :flush_all


	### Return a hash of statistics hashes for each of the specified +servers+.
	def server_stats( servers=@servers )

		# Build commandset for servers that are alive
		asvrs = servers.select {|svr| svr.alive?}
		cmds = self.make_command_map( "stats", asvrs )

		# Send them in parallel
		return self.add_stat( :server_stats ) do
			self.send( cmds ) do |svr,reply|
				self.parse_stats( reply )
			end
		end
	end


	### Reset statistics on the given +servers+.
	def server_reset_stats( servers=@servers )

		# Build commandset for servers that are alive
		asvrs = servers.select {|svr| svr.alive? }
		cmds = self.make_command_map( "stats reset", asvrs )

		# Send them in parallel
		return self.add_stat( :server_reset_stats ) do
			self.send( cmds ) do |svr,reply|
				reply.rstrip == "RESET"
			end
		end
	end


	### Return memory maps from the specified +servers+ (not supported on all
	### platforms)
	def server_map_stats( servers=@servers )

		# Build commandset for servers that are alive
		asvrs = servers.select {|svr| svr.alive? }
		cmds = self.make_command_map( "stats maps", asvrs )

		# Send them in parallel
		return self.add_stat( :server_map_stats ) do
			self.send( cmds )
		end
	rescue MemCache::ServerError => err
		self.debug_msg "%p doesn't support 'stats maps'" % err.server
		return {}
	end


	### Return malloc stats from the specified +servers+ (not supported on all
	### platforms)
	def server_malloc_stats( servers=@servers )

		# Build commandset for servers that are alive
		asvrs = servers.select {|svr| svr.alive? }
		cmds = self.make_command_map( "stats malloc", asvrs )

		# Send them in parallel
		return self.add_stat( :server_malloc_stats ) do
			self.send( cmds ) do |svr,reply|
				self.parse_stats( reply )
			end
		end
	rescue MemCache::InternalError
		self.debug_msg( "One or more servers doesn't support 'stats malloc'" )
		return {}
	end


	### Return slab stats from the specified +servers+
	def server_slab_stats( servers=@servers )

		# Build commandset for servers that are alive
		asvrs = servers.select {|svr| svr.alive? }
		cmds = self.make_command_map( "stats slabs", asvrs )

		# Send them in parallel
		return self.add_stat( :server_slab_stats ) do
			self.send( cmds ) do |svr,reply|
				### :TODO: I could parse the results from this further to split
				### out the individual slabs into their own sub-hashes, but this
				### will work for now.
				self.parse_stats( reply )
			end
		end
	end


	### Return item stats from the specified +servers+
	def server_item_stats( servers=@servers )

		# Build commandset for servers that are alive
		asvrs = servers.select {|svr| svr.alive? }
		cmds = self.make_command_map( "stats items", asvrs )

		# Send them in parallel
		return self.add_stat( :server_stats_items ) do
			self.send( cmds ) do |svr,reply|
				self.parse_stats( reply )
			end
		end
	end


	### Return item size stats from the specified +servers+
	def server_size_stats( servers=@servers )

		# Build commandset for servers that are alive
		asvrs = servers.select {|svr| svr.alive? }
		cmds = self.make_command_map( "stats sizes", asvrs )

		# Send them in parallel
		return self.add_stat( :server_stats_sizes ) do
			self.send( cmds ) do |svr,reply|
				reply.sub( /#{CRLF}END#{CRLF}/, '' ).split( /#{CRLF}/ )
			end
		end
	end



	#########
	protected
	#########

	### Create a hash mapping the specified command to each of the given
	### +servers+.
	def make_command_map( command, servers=@servers )
		Hash[ *([servers, [command]*servers.nitems].transpose.flatten) ]
	end


	### Parse raw statistics lines from a memcached 'stats' +reply+ and return a
	### Hash.
	def parse_stats( reply )

		# Trim off the footer
		reply.sub!( /#{CRLF}END#{CRLF}/, '' )

		# Make a hash out of the other values
		pairs = reply.split( /#{CRLF}/ ).collect {|line|
			stat, name, val = line.split(/\s+/, 3)
			name = name.to_sym

			if StatConverters.key?( name )
				val = StatConverters[ name ].call( val )
			else
				val = StatConverters[ :__default__ ].call( val )
			end

			[name,val]
		}

		return Hash[ *(pairs.flatten) ]
	end


	### Get the server corresponding to the given +key+.
	def get_server( key )
		@mutex.synchronize( Sync::SH ) {
			return @servers.first if @servers.length == 1

			# If the key is an integer, it's assumed to be a precomputed hash
			# key so don't bother hashing it. Otherwise use the hashing function
			# to come up with a hash of the key to determine which server to
			# talk to
			hkey = nil
			if key.is_a?( Integer )
				hkey = key
			else
				hkey = @hashfunc.call( key )
			end

			# Set up buckets if they haven't been already
			unless @buckets
				@mutex.synchronize( Sync::EX ) {
					# Check again after switching to an exclusive lock
					unless @buckets
						@buckets = []
						@servers.each do |svr|
							self.debug_msg( "Adding %d buckets for %p", svr.weight, svr )
							svr.weight.times { @buckets.push(svr) }
						end
					end
				}
			end

			# Fetch a server for the given key, retrying if that server is
			# offline
			20.times do |tries|
				svr = @buckets[ (hkey + tries) % @buckets.nitems ]
				break if svr.alive?
				svr = nil
			end

			raise MemCacheError, "No servers available" if svr.nil?
			return svr
		}
	end


	### Store the specified +value+ to the cache associated with the specified
	### +key+ and expiration time +exptime+.
	def store( type, key, val, exptime )
		return self.delete( key ) if val.nil?
		svr = self.get_server( key )
		cachekey = self.make_cache_key( key )
		res = nil

		self.add_stat( type ) {
			# Prep the value for storage
			sval, flags = self.prep_value( val )

			# Form the command
			cmd = []
			cmd << "%s %s %d %d %d" %
				[ type, cachekey, flags, exptime, sval.length ]
			cmd << sval
			self.debug_msg( "Storing with: %p", cmd )

			# Send the command and read the reply
			res = self.send( svr => cmd )
		}

		# Check for an appropriate server response
		return (res && res[svr] && res[svr].rstrip == "STORED")
	end


	### Fetch the values corresponding to the given +keys+ from the cache and
	### return them as a Hash.
	def fetch( type, *keys )

		# Make a hash to hold servers => commands for the keys to be fetched,
		# and one to match cache keys to user keys.
		map = Hash::new {|hsh,key| hsh[key] = 'get'}
		cachekeys = {}

		res = {}
		self.add_stat( type ) {

			# Map the key's server to the command to fetch its value
			keys.each do |key|
				svr = self.get_server( key )
				
				ckey = self.make_cache_key( key )
				cachekeys[ ckey ] = key
				map[ svr ] << " " + ckey
			end

			# Send the commands and map the results hash into the return hash
			self.send( map, true ) do |svr, reply|

				# Iterate over the replies, stripping first the 'VALUE
				# <cachekey> <flags> <len>' line with a regexp and then the data
				# line by length as specified by the VALUE line.
				while reply.sub!( /^VALUE (\S+) (\d+) (\d+)\r\n/, '' )
					ckey, flags, len = $1, $2.to_i, $3.to_i

					# Restore compressed and thawed values that require it.
					data = reply.slice!( 0, len + 2 ) # + CRLF
					rval = self.restore( data[0,len], flags )

					res[ cachekeys[ckey] ] = rval
				end

				unless reply == "END" + CRLF
					raise MemCacheError, "Malformed reply fetched from %p: %p" %
						[ svr, rval ]
				end
			end
		}

		return res
	end


	### Increment/decrement the value associated with +key+ on the server by
	### +val+.
	def incrdecr( type, key, val )
		svr = self.get_server( key )
		cachekey = self.make_cache_key( key )

		# Form the command, send it, and read the reply
		res = self.add_stat( type ) {
			cmd = "%s %s %d" % [ type, cachekey, val ]
			self.send( svr => cmd )
		}

		# De-stringify the number if it is one and return it as an Integer, or
		# nil if it isn't a number.
		if /^(\d+)/.match( res[svr] )
			return Integer( $1 )
		else
			return nil
		end
	end


	### Prepare the specified value +val+ for insertion into the cache,
	### serializing and compressing as necessary/configured.
	def prep_value( val )
		sval = nil
		flags = 0

		# Serialize if something other than a String, Numeric
		case val
		when String
			sval = val.dup
		when Numeric
			sval = val.to_s
			flags |= F_NUMERIC
		else
			self.debug_msg "Serializing %p" % val
			sval = Marshal::dump( val )
			flags |= F_SERIALIZED
		end
		
		# Compress if compression is enabled, the value exceeds the
		# compression threshold, and the compressed value is smaller than
		# the uncompressed version.
		if @compress && sval.length > @c_threshold
			zipped = Zlib::ZStream::Deflate::deflate( sval )
			
			if zipped.length < (sval.length * MinCompressionRatio)
				self.debug_msg "Using compressed value (%d/%d)" %
					[ zipped.length, sval.length ]
				sval = zipped
				flags |= F_COMPRESSED
			end
		end

		# Urlencode unless told not to
		unless !@urlencode
			sval = URI::escape( sval )
			flags |= F_ESCAPED
		end

		return sval, flags
	end


	### Restore the specified value +val+ from the form inserted into the cache,
	### given the specified +flags+.
	def restore( val, flags=0 )
		self.debug_msg( "Restoring value %p (flags: %d)", val, flags )
		rval = val.dup

		# De-urlencode
		if (flags & F_ESCAPED).nonzero?
			rval = URI::unescape( rval )
		end

		# Decompress
		if (flags & F_COMPRESSED).nonzero?
			rval = Zlib::ZStream::Inflate::inflate( rval )
		end

		# Unserialize
		if (flags & F_SERIALIZED).nonzero?
			rval = Marshal::load( rval )
		end

		if (flags & F_NUMERIC).nonzero?
			if /\./.match( rval )
				rval = Float( rval )
			else
				rval = Integer( rval )
			end
		end

		return rval
	end


	### Statistics wrapper: increment the execution count and processor times
	### for the given operation +type+ for the specified +server+.
	def add_stat( type )
		raise LocalJumpError, "no block given" unless block_given?

		# Time the block
		starttime = Process::times
		res = yield
		endtime = Process::times

		# Add time/call stats callback
		@stats[type][:count] += 1
		@stats[type][:utime]  += endtime.utime - starttime.utime
		@stats[type][:stime]  += endtime.stime - starttime.stime
		@stats_callback.call( type, starttime, endtime ) if @stats_callback

		return res
	end


	### Write a message (formed +sprintf+-style with +fmt+ and +args+) to the
	### debugging callback in @debug, to $stderr if @debug doesn't appear to be
	### a callable object but is still +true+. If @debug is +nil+ or +false+, do
	### nothing.
	def debug_msg( fmt, *args )
		return unless @debug

		if @debug.respond_to?( :call )
			@debug.call( fmt % args )
		elsif @debug.respond_to?( :<< )
			@debug << "#{fmt}\n" % args
		else
			$stderr.puts( fmt % args )
		end
	end


	### Create a key for the cache from any object. Strings are used as-is,
	### Symbols are stringified, and other values use their #hash method.
	def make_cache_key( key )
		ck = @namespace ? "#@namespace:" : ""

		case key
		when String, Symbol
			ck += key.to_s
		else
			ck += "%s" % key.hash
		end

		ck = URI::escape( ck ) unless !@urlencode

		self.debug_msg( "Cache key for %p: %p", key, ck )
		return ck
	end


	### Socket IO Methods

	### Given +pairs+ of MemCache::Server objects and Strings or Arrays of
	### commands for each server, do multiplexed IO between all of them, reading
	### single-line responses.
	def send( pairs, multiline=false )
		raise TypeError, "type mismatch: #{pairs.class.name} given" unless
			pairs.is_a?( Hash )
		buffers = {}
		rval = {}

		# Fetch the Method object for the IO handler
		handler = self.method( :handle_line_io )

		# Set up the buffers and reactor for the exchange
		pairs.each do |server,cmds|
			unless server.alive?
				rval[server] = nil
				pairs.delete( server )
				next
			end

			# Handle either Arrayish or Stringish commandsets
			wbuf = cmds.respond_to?( :join ) ? cmds.join( CRLF ) : cmds.to_s
			self.debug_msg( "Created command %p for %p", wbuf, server )
			wbuf += CRLF

			# Make a buffer tuple (read/write) for the server
			buffers[server] = { :rbuf => '', :wbuf => wbuf }

			# Register the server's socket with the reactor
			@reactor.register( server.socket, :write, :read, server,
							   buffers[server], multiline, &handler )
		end

		# Do all the IO at once
		self.debug_msg( "Reactor starting for %d IOs", @reactor.handles.length )
		@reactor.poll until @reactor.empty?
		self.debug_msg( "Reactor finished." )

		# Build the return value, delegating the processing to a block if one
		# was given.
		pairs.each {|server,cmds|

			# Handle protocol errors if they happen.  I have no idea if this is
			# desirable/correct behavior: none of the other clients react to
			# CLIENT_ERROR or SERVER_ERROR at all; in fact, I think they'd all
			# hang on one like this one did before I added them to the
			# terminator pattern in #handle_line_io. So this may change in the
			# future if it ends up being better to just ignore errors, try to
			# cache/fetch what we can, and hope returning nil will suffice in
			# the face of error conditions
			self.handle_protocol_error( buffers[server][:rbuf], server ) if
				ANY_ERROR.match( buffers[server][:rbuf] )

			# If the caller is doing processing on the reply, yield each buffer
			# in turn. Otherwise, just use the raw buffer as the return value
			if block_given?
				self.debug_msg( "Yielding value/s %p for %p",
					buffers[server][:rbuf], server )
				rval[server] = yield( server, buffers[server][:rbuf] )
			else
				rval[server] = buffers[server][:rbuf]
			end
		}

		return rval
	end


	### Handle an IO event +ev+ on the given +sock+ for the specified +server+,
	### expecting single-line syntax (i.e., ends with CRLF).
	def handle_line_io( sock, ev, server, buffers, multiline=false )
		self.debug_msg( "Line IO (ml=%p) event for %p: %s: %p - %p",
						multiline, sock, ev, server, buffers )

		# Set the terminator pattern based on whether multiline is turned on or
		# not.
		terminator = multiline ? MULTILINE_TERMINATOR : LINE_TERMINATOR

		# Handle the event
		case ev
		when :read
			len = buffers[:rbuf].length
			buffers[:rbuf] << sock.sysread( 256 )
			self.debug_msg "Read %d bytes." % [ buffers[:rbuf].length - len ]

			# If we've read the reply, then we're done with this socket
			# completely.
			if terminator.match( buffers[:rbuf] )
				self.debug_msg "Done with read for %p: %p", sock, buffers[:rbuf]
				@reactor.remove( sock )
			end

		when :write
			res = sock.send( buffers[:wbuf], SendFlags )
			self.debug_msg( "Wrote %d bytes.", res )
			buffers[:wbuf].slice!( 0, res ) unless res.zero?

			# If the write buffer's done, then we don't care about writability
			# anymore, so clear that event.
			if buffers[:wbuf].empty?
				self.debug_msg "Done with write for %p" % sock
				@reactor.disableEvents( sock, :write )
			end

		when :err
			so_error = sock.getsockopt( SOL_SOCKET, SO_ERROR )
 			self.debug_msg "Socket error on %p: %s" % [ sock, so_error ]
			@reactor.remove( sock )
			server.mark_dead( so_error )

		else
			raise ArgumentError, "Unhandled reactor event type: #{ev}"
		end
	rescue EOFError, IOError => err
		@reactor.remove( sock )
		server.mark_dead( err.message )
	end

		
	### Handle error messages defined in the memcached protocol. The +buffer+
	### argument will be parsed for the error type, and, if appropriate, the
	### error message. The +server+ argument is only used in the case of
	### +SERVER_ERROR+, in which case the raised exception will contain that
	### object. The +depth+ argument is used to specify the call depth from
	### which the exception's stacktrace should be gathered.
	def handle_protocol_error( buffer, server, depth=4 )
		case buffer
		when CLIENT_ERROR
			raise ClientError, $1, caller(depth)

		when SERVER_ERROR
			raise ServerError::new( server ), $1, caller(depth)

		else
			raise InternalError, "Unknown internal error", caller(depth)
		end
	end


	
	#####################################################################
	###	I N T E R I O R   C L A S S E S
	#####################################################################

	### A Multiton datatype to represent a potential memcached server
	### connection.
	class Server 

		# Default timeout for connections to memcached servers.
		ConnectTimeout = 0.25


		#############################################################
		###	I N S T A N C E   M E T H O D S
		#############################################################

		### Create a new MemCache::Server object for the memcached instance
		### listening on the given +host+ and +port+, weighted with the given
		### +weight+.
		def initialize( host, port=11211, weight=DefaultServerWeight )
			if host.nil? || host.empty?
				raise ArgumentError, "Illegal host %p" % host
			elsif port.nil? || port.to_i.zero?
				raise ArgumentError, "Illegal port %p" % port
			end

			@host 	= host
			@port 	= port
			@weight = weight

			@sock 	= nil
			@retry 	= nil
			@status	= "not yet connected"
		end


		######
		public
		######

		# The host the memcached server is running on
		attr_reader :host

		# The port the memcached is listening on
		attr_reader :port

		# The weight given to the server
		attr_reader :weight

		# The Time of next connection retry if the object is dead.
		attr_reader :retry

		# A text status string describing the state of the server.
		attr_reader :status


		### Return a string representation of the server object.
		def inspect
			return "<MemCache::Server: %s:%d [%d] (%s)>" % [
				@host,
				@port,
				@weight,
				@status,
			]
		end


		### Test the server for aliveness, returning +true+ if the object was
		### able to connect. This will cause the socket connection to be opened
		### if it isn't already.
		def alive?
			return !self.socket.nil?
		end


		### Try to connect to the memcached targeted by this object. Returns the
		### connected socket object on success; sets @dead and returns +nil+ on
		### any failure.
		def socket

			# Connect if not already connected
			unless @sock || (!@sock.nil? && @sock.closed?)

				# If the host was dead, don't retry for a while
				if @retry
					return nil if @retry > Time::now
				end

				# Attempt to connect, 
				begin
					@sock = timeout( ConnectTimeout ) {
						TCPSocket::new( @host, @port )
					}
					@status = "connected"
				rescue SystemCallError, IOError, TimeoutError => err
					self.mark_dead( err.message )
				end
			end

			return @sock
		end


		### Mark the server as dead for 30 seconds and close its socket. The
		### specified +reason+ will be used to construct an appropriate status
		### message.
		def mark_dead( reason="Unknown error" )
			@sock.close if @sock && !@sock.closed?
			@sock = nil
			@retry = Time::now + ( 30 + rand(10) )
			@status = "DEAD: %s: Will retry at %s" %
				[ reason, @retry ]
		end


	end # class Server


	#################################################################
	###	E X C E P T I O N   C L A S S E S
	#################################################################

	### Base MemCache exception class
	class MemCacheError < ::Exception
	end

	### MemCache internal error class -- instances of this class mean that there
	### is some internal error either in the memcache client lib or the
	### memcached server it's talking to.
	class InternalError < MemCacheError
	end

	### MemCache client error class -- this is raised if a "CLIENT_ERROR
	### <error>\r\n" is seen in the dialog with a server.
	class ClientError < InternalError
	end

	### MemCache server error class -- this is raised if a "SERVER_ERROR
	### <error>\r\n" is seen in the dialog with a server.
	class ServerError < InternalError
		def initialize( svr )
			@server = svr
		end

		attr_reader :server
	end


end # class memcache

