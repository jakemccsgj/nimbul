
SHELL = /bin/sh

#### Start of system configuration section. ####

srcdir = .
topdir = /usr/local/rvm/rubies/ree-1.8.7-2012.02/lib/ruby/1.8/x86_64-linux
hdrdir = $(topdir)
VPATH = $(srcdir):$(topdir):$(hdrdir)
exec_prefix = $(prefix)
prefix = $(DESTDIR)/usr/local/rvm/rubies/ree-1.8.7-2012.02
includedir = $(prefix)/include
sitearchdir = $(sitelibdir)/$(sitearch)
htmldir = $(docdir)
datarootdir = $(prefix)/share
localstatedir = $(prefix)/var
oldincludedir = $(DESTDIR)/usr/include
sitelibdir = $(sitedir)/$(ruby_version)
mandir = $(datarootdir)/man
infodir = $(datarootdir)/info
vendordir = $(libdir)/ruby/vendor_ruby
psdir = $(docdir)
archdir = $(rubylibdir)/$(arch)
libexecdir = $(exec_prefix)/libexec
sysconfdir = $(prefix)/etc
datadir = $(datarootdir)
libdir = $(exec_prefix)/lib
sitedir = $(libdir)/ruby/site_ruby
pdfdir = $(docdir)
docdir = $(datarootdir)/doc/$(PACKAGE)
bindir = $(exec_prefix)/bin
vendorlibdir = $(vendordir)/$(ruby_version)
rubylibdir = $(libdir)/ruby/$(ruby_version)
vendorarchdir = $(vendorlibdir)/$(sitearch)
localedir = $(datarootdir)/locale
dvidir = $(docdir)
sbindir = $(exec_prefix)/sbin
sharedstatedir = $(prefix)/com

CC = /usr/bin/gcc
LIBRUBY = $(LIBRUBY_A)
LIBRUBY_A = lib$(RUBY_SO_NAME)-static.a
LIBRUBYARG_SHARED = -Wl,-R -Wl,$(libdir) -L$(libdir) 
LIBRUBYARG_STATIC = -l$(RUBY_SO_NAME)-static

RUBY_EXTCONF_H = 
CFLAGS   =  -fPIC -g -O2  $(cflags) -O0 -Wall 
INCFLAGS = $(PREINCFLAGS) -I. -I/opt/local/include -I. -I/usr/local/rvm/rubies/ree-1.8.7-2012.02/lib/ruby/1.8/x86_64-linux -I.
DEFS     = 
CPPFLAGS =    
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
LIBS =  -lc  -L/opt/local/lib -lrt -ldl -lcrypt -lm   -lc
SRCS = gherkin_lexer_en_au.c
OBJS = gherkin_lexer_en_au.o
TARGET = gherkin_lexer_en_au
DLLIB = $(TARGET).so
EXTSTATIC = 
STATIC_LIB = 

BINDIR        = $(bindir)
RUBYCOMMONDIR = $(sitedir)$(target_prefix)
RUBYLIBDIR = /opt/nyt/nimbul/.bundle/ruby/1.8/gems/gherkin-2.9.3/lib$(target_prefix)
RUBYARCHDIR = /opt/nyt/nimbul/.bundle/ruby/1.8/gems/gherkin-2.9.3/lib$(target_prefix)

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



$(OBJS): ruby.h defines.h
