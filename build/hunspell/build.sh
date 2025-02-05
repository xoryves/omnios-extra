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

# Copyright 2023 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/build.sh

PROG=hunspell
VER=1.7.2
PKG=ooce/text/hunspell
SUMMARY="$PROG"
DESC="$PROG - spell checker"

# https://github.com/fin-w/LibreOffice-Geiriadur-Cymraeg-Welsh-Dictionary
CYVER=1.2

forgo_isaexec
set_clangver

OPREFIX=$PREFIX
PREFIX+=/$PROG

XFORM_ARGS="
    -DOPREFIX=${OPREFIX#/}
    -DPREFIX=${PREFIX#/}
    -DPROG=$PROG
    -DPKGROOT=$PROG
"

CONFIGURE_OPTS="
    --prefix=$PREFIX
    --includedir=$OPREFIX/include
    --with-ui
"
CONFIGURE_OPTS[i386]="
    --libdir=$OPREFIX/lib
"
CONFIGURE_OPTS[amd64]="
    --libdir=$OPREFIX/lib/amd64
"

CPPFLAGS+=" -I/usr/include/ncurses"

# libtool adds '-nostdlib' which prevents clang from adding the proper RPATH
# for libstdc++
LDFLAGS[i386]+=" -Wl,-R/usr/gcc/$DEFAULT_GCC_VER/lib"
LDFLAGS[amd64]+=" -Wl,-R/usr/gcc/$DEFAULT_GCC_VER/lib/amd64"

post_install() {
    [ $1 = i386 ] && return

    note -n "getting dictionaries"
    dictbaseurl="https://cgit.freedesktop.org/libreoffice/dictionaries/plain"
    cybaseurl="https://raw.githubusercontent.com/fin-w/"
    cybaseurl+="LibreOffice-Geiriadur-Cymraeg-Welsh-Dictionary/v$CYVER"

    logcmd $MKDIR -p $DESTDIR/$PREFIX/share/$PROG || logerr "failed to mkdir"
    for l in en_US en_GB; do
        for t in aff dic; do
            logmsg "downloading $l.$t"
            logcmd $WGET -O $DESTDIR/$PREFIX/share/$PROG/$l.$t \
                $dictbaseurl/en/$l.$t || logerr "failed to download $l.$t"
        done
    done
    logcmd $WGET -O $TMPDIR/$BUILDDIR/licence_libre.txt \
        $dictbaseurl/en/license.txt || logerr "failed to download licence"

    for t in aff dic; do
        logmsg "downloading cy_GB.$t"
        logcmd $WGET -O $DESTDIR/$PREFIX/share/$PROG/cy_GB.$t \
            $cybaseurl/dictionaries/cy_GB.$t \
            || logerr "failed to download cy_GB.$t"
    done
    logcmd $WGET -O $TMPDIR/$BUILDDIR/licence_cymraeg.txt \
        $cybaseurl/LICENSE || logerr "failed to download licence"
}

init
download_source $PROG $PROG $VER
patch_source
prep_build autoconf -autoreconf
build -noctf    # C++
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
