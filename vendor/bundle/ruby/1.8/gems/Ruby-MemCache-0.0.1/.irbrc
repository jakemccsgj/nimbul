#!/usr/bin/ruby

puts ">>> Adding lib and ext to load path..."
$LOAD_PATH.unshift( "lib" )

require './utils'
include UtilityFunctions

def colored( prompt, *args )
	return ansiCode( *(args.flatten) ) + prompt + ansiCode( 'reset' )
end


# Modify prompt to do highlighting unless we're running in an inferior shell.
unless ENV['EMACS']
	IRB.conf[:PROMPT][:memcache] = { # name of prompt mode
		:PROMPT_I => colored( "%N(%m):%03n:%i>", %w{bold white on_blue} ) + " ",
		:PROMPT_S => colored( "%N(%m):%03n:%i%l", %w{white on_blue} ) + " ",
		:PROMPT_C => colored( "%N(%m):%03n:%i*", %w{white on_blue} ) + " ",
		:RETURN => "    ==> %s\n\n"      # format to return value
	}
	IRB.conf[:PROMPT_MODE] = :memcache
end

# Try to require the 'memcache' library
begin
	puts "Requiring Memcache..."
	require "memcache"
rescue => e
	$stderr.puts "Ack! Memcache library failed to load: #{e.message}\n\t" +
		e.backtrace.join( "\n\t" )
end


__END__
Local Variables:
mode: ruby

