#!/usr/bin/bash
#
# {{{ CDDL HEADER
#
# This file and its contents are supplied under the terms of the
# Common Development and Distribution License ("CDDL"), version 1.0.
# You may only use this file in accordance with the terms of version
# 1.0 of the CDDL.
#
# A full copy of the text of the CDDL should have accompanied this
# source. A copy of the CDDL is also available via the Internet at
# http://www.illumos.org/license/CDDL.
# }}}

# Copyright 2022 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/build.sh

PROG=libzip
VER=1.9.2
PKG=ooce/library/libzip
SUMMARY="libzip"
DESC="A C library for reading, creating and modifying zip archives"

BUILD_DEPENDS_IPS="
    ooce/developer/cmake
"

OPREFIX=$PREFIX
PREFIX+="/$PROG"

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DOPREFIX=${OPREFIX#/}
    -DPROG=$PROG
    -DPKGROOT=$PROG
"

CONFIGURE_OPTS="
    -DCMAKE_BUILD_TYPE=Release
    -DCMAKE_INSTALL_PREFIX=$PREFIX
    -DCMAKE_INSTALL_INCLUDEDIR=$OPREFIX/include
"
CONFIGURE_OPTS[i386]="
    -DCMAKE_INSTALL_LIBDIR=$OPREFIX/lib
"
CONFIGURE_OPTS[amd64]="
    -DCMAKE_INSTALL_LIBDIR=$OPREFIX/lib/amd64
    -DNettle_LIBRARY=$OPREFIX/lib/amd64/libnettle.so
"
[ $RELVER -lt 151035 ] \
    && CONFIGURE_OPTS[amd64]+=" -DZstd_LIBRARY=$OPREFIX/lib/amd64/libzstd.so"

LDFLAGS[i386]+=" -R$OPREFIX/lib"
LDFLAGS[amd64]+=" -R$OPREFIX/lib/amd64"

init
download_source $PROG $PROG $VER
prep_build cmake+ninja
patch_source
build -ctf
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
