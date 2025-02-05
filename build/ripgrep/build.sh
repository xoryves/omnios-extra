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

# Copyright 2021 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/build.sh

PROG=ripgrep
VER=13.0.0
PKG=ooce/text/ripgrep
SUMMARY="Fast line-oriented search tool"
DESC="A fast line-oriented search tool that recursively searches your current "
DESC+="directory for a regex pattern while respecting your gitignore rules"

BUILD_DEPENDS_IPS=ooce/developer/rust

# libpcre2 is included with OmniOS as of r151029 and ripgrep can use it
if [ $RELVER -ge 151029 ]; then
    BUILD_DEPENDS_IPS+=" library/pcre2"
    args="--features pcre2"
fi

set_arch 64

SKIP_LICENCES=UNLICENSE

export XML_CATALOG_FILES=$PREFIX/docbook-xsl/catalog.xml

init
download_source $PROG $VER
patch_source
prep_build
build_rust $args
PROG=rg install_rust
strip_install
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
