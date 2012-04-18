
SHELL = /bin/sh

#### Start of system configuration section. ####

srcdir = .
topdir = /usr/local/rvm/rubies/ree-1.8.7-2012.02/lib/ruby/1.8/x86_64-linux
hdrdir = $(topdir)
VPATH = $(srcdir):$(topdir):$(hdrdir)
prefix = $(DESTDIR)/usr/local/rvm/rubies/ree-1.8.7-2012.02
exec_prefix = $(prefix)
includedir = $(prefix)/include
libdir = $(exec_prefix)/lib
sysconfdir = $(prefix)/etc
sbindir = $(exec_prefix)/sbin
infodir = $(datarootdir)/info
rubylibdir = $(libdir)/ruby/$(ruby_version)
psdir = $(docdir)
datarootdir = $(prefix)/share
docdir = $(datarootdir)/doc/$(PACKAGE)
htmldir = $(docdir)
sharedstatedir = $(prefix)/com
dvidir = $(docdir)
mandir = $(datarootdir)/man
localstatedir = $(prefix)/var
libexecdir = $(exec_prefix)/libexec
datadir = $(datarootdir)
archdir = $(rubylibdir)/$(arch)
sitedir = $(libdir)/ruby/site_ruby
localedir = $(datarootdir)/locale
sitelibdir = $(sitedir)/$(ruby_version)
bindir = $(exec_prefix)/bin
pdfdir = $(docdir)
vendorarchdir = $(vendorlibdir)/$(sitearch)
sitearchdir = $(sitelibdir)/$(sitearch)
vendorlibdir = $(vendordir)/$(ruby_version)
oldincludedir = $(DESTDIR)/usr/include
vendordir = $(libdir)/ruby/vendor_ruby

CC = /usr/bin/gcc
LIBRUBY = $(LIBRUBY_A)
LIBRUBY_A = lib$(RUBY_SO_NAME)-static.a
LIBRUBYARG_SHARED = -Wl,-R -Wl,$(libdir) -L$(libdir) 
LIBRUBYARG_STATIC = -l$(RUBY_SO_NAME)-static

RUBY_EXTCONF_H = extconf.h
CFLAGS   =  -fPIC -g -O2  $(cflags) -I/usr/lib64/libffi-3.0.5/include   -Wno-declaration-after-statement  
INCFLAGS = $(PREINCFLAGS) -I. -I/opt/local/include -I. -I/usr/local/rvm/rubies/ree-1.8.7-2012.02/lib/ruby/1.8/x86_64-linux -I.
DEFS     = 
CPPFLAGS = -DRUBY_EXTCONF_H=\"$(RUBY_EXTCONF_H)\"   
CXXFLAGS = $(CFLAGS) 
ldflags  = -L.  -rdynamic -Wl,-export-dynamic 
dldflags = 
archflag = 
DLDFLAGS = $(ldflags) $(dldflags) $(archflag)
LDSHARED = $(CC) -shared
AR = ar
EXEEXT = 

RUBY_INSTALL_NAME = ruby
RUBY_SO_NAME = ruby
arch = x86_64-linux
sitearch = x86_64-linux
ruby_version = 1.8
ruby = /usr/local/rvm/rubies/ree-1.8.7-2012.02/bin/ruby
RUBY = $(ruby)
RM = rm -f
MAKEDIRS = mkdir -p
INSTALL = /usr/bin/install -c
INSTALL_PROG = $(INSTALL) -m 0755
INSTALL_DATA = $(INSTALL) -m 644
COPY = cp

#### End of system configuration section. ####

preload = 

libpath = . $(libdir)
LIBPATH =  -L. -L$(libdir) -Wl,-R$(libdir)
DEFFILE = 

CLEANFILES = mkmf.log
DISTCLEANFILES = 

extout = 
extout_prefix = 
target_prefix = 
LOCAL_LIBS = 
LIBS =  -lffi  -lffi   -L/opt/local/lib -lrt -ldl -lcrypt -lm   -lc
SRCS = ffi.c FunctionInfo.c StructByReference.c ClosurePool.c MappedType.c Type.c DataConverter.c Buffer.c LastError.c Pointer.c MemoryPointer.c Platform.c Function.c MethodHandle.c AbstractMemory.c Types.c StructLayout.c ArrayType.c Thread.c DynamicLibrary.c StructByValue.c Call.c Variadic.c Struct.c
OBJS = ffi.o FunctionInfo.o StructByReference.o ClosurePool.o MappedType.o Type.o DataConverter.o Buffer.o LastError.o Pointer.o MemoryPointer.o Platform.o Function.o MethodHandle.o AbstractMemory.o Types.o StructLayout.o ArrayType.o Thread.o DynamicLibrary.o StructByValue.o Call.o Variadic.o Struct.o
TARGET = ffi_c
DLLIB = $(TARGET).so
EXTSTATIC = 
STATIC_LIB = 

BINDIR        = $(bindir)
RUBYCOMMONDIR = $(sitedir)$(target_prefix)
RUBYLIBDIR = /opt/nyt/nimbul/vendor/bundle/ruby/1.8/gems/ffi-1.0.11/lib$(target_prefix)
RUBYARCHDIR = /opt/nyt/nimbul/vendor/bundle/ruby/1.8/gems/ffi-1.0.11/lib$(target_prefix)

TARGET_SO     = $(DLLIB)
CLEANLIBS     = $(TARGET).so $(TARGET).il? $(TARGET).tds $(TARGET).map
CLEANOBJS     = *.o *.a *.s[ol] *.pdb *.exp *.bak

all:		$(DLLIB)
static:		$(STATIC_LIB)

clean:
		@-$(RM) $(CLEANLIBS) $(CLEANOBJS) $(CLEANFILES)

distclean:	clean
		@-$(RM) Makefile $(RUBY_EXTCONF_H) conftest.* mkmf.log
		@-$(RM) core ruby$(EXEEXT) *~ $(DISTCLEANFILES)

realclean:	distclean
install: install-so install-rb

install-so: $(RUBYARCHDIR)
install-so: $(RUBYARCHDIR)/$(DLLIB)
$(RUBYARCHDIR)/$(DLLIB): $(DLLIB)
	$(INSTALL_PROG) $(DLLIB) $(RUBYARCHDIR)
install-rb: pre-install-rb install-rb-default
install-rb-default: pre-install-rb-default
pre-install-rb: Makefile
pre-install-rb-default: Makefile
$(RUBYARCHDIR):
	$(MAKEDIRS) $@

site-install: site-install-so site-install-rb
site-install-so: install-so
site-install-rb: install-rb

.SUFFIXES: .c .m .cc .cxx .cpp .C .o

.cc.o:
	$(CXX) $(INCFLAGS) $(CPPFLAGS) $(CXXFLAGS) -c $<

.cxx.o:
	$(CXX) $(INCFLAGS) $(CPPFLAGS) $(CXXFLAGS) -c $<

.cpp.o:
	$(CXX) $(INCFLAGS) $(CPPFLAGS) $(CXXFLAGS) -c $<

.C.o:
	$(CXX) $(INCFLAGS) $(CPPFLAGS) $(CXXFLAGS) -c $<

.c.o:
	$(CC) $(INCFLAGS) $(CPPFLAGS) $(CFLAGS) -c $<

$(DLLIB): $(OBJS) Makefile
	@-$(RM) $@
	$(LDSHARED) -o $@ $(OBJS) $(LIBPATH) $(DLDFLAGS) $(LOCAL_LIBS) $(LIBS)



$(OBJS): ruby.h defines.h $(RUBY_EXTCONF_H)
