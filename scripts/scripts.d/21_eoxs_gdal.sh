#!/bin/sh
#-------------------------------------------------------------------------------
#
# Purpose: GDAL installation.
# Author(s): Martin Paces <martin.paces@eox.at>
#-------------------------------------------------------------------------------
# Copyright (C) 2015 EOX IT Services GmbH

. `dirname $0`/../lib_logging.sh
. `dirname $0`/../lib_python_venv.sh
. `dirname $0`/../lib_util.sh

info "Installing GDAL library ... "

yum --assumeyes install gdal gdal-libs proj-epsg gdal-devel gcc-c++ python3-devel

activate_venv "$VIRES_VENV_ROOT"

# build gdal dependencies from source
pip3 install $PIP_OPTIONS pygdal=="`gdal-config --version`.*"
