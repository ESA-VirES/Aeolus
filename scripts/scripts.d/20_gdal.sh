#!/bin/sh
#-------------------------------------------------------------------------------
#
# Purpose: GDAL installation.
# Author(s): Martin Paces <martin.paces@eox.at>
#-------------------------------------------------------------------------------
# Copyright (C) 2015 EOX IT Services GmbH

. `dirname $0`/../lib_logging.sh

info "Installing GDAL library ... "

yum --assumeyes install gdal gdal-libs proj-epsg gdal-devel gcc-c++ python3-devel

# build gdal dependecies from source
pip3 install pygdal=="`gdal-config --version`.*"