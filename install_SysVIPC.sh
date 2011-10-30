#!/bin/bash -e
#
# $Id$
#

#
# settings
#
export sysvipc_gem_ver='0.7'

echo "Installing SysVIPC version ${sysvipc_gem_ver} (later version won't work)"
mkdir -p /tmp
cd /tmp
rm -rf sysvipc-${sysvipc_gem_ver}*
wget --tries=5 http://rubyforge.org/frs/download.php/23172/sysvipc-${sysvipc_gem_ver}.tar.gz
tar xzvf sysvipc-${sysvipc_gem_ver}.tar.gz
cd sysvipc-${sysvipc_gem_ver}
ruby extconf.rb
if [ $(uname | grep Darwin -c) -eq 1 ]; then
    echo "Patching Makefile to avoid weird 'error: redefinition of 'union semun'' issue"
    perl -pi -e 's/^CPPFLAGS(.*)$/CPPFLAGS$1 -DHAVE_TYPE_UNION_SEMUN/g;' Makefile
fi
make ; make install
cd /tmp
rm -rf sysvipc-${sysvipc_gem_ver}*

echo "Enjoy"

exit 0
