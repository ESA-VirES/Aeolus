#!/bin/sh
#-------------------------------------------------------------------------------
#
# Purpose: netCDF4 installation.
# Author(s): Fabian Schindler <fabian.schindler@eox.at>
#-------------------------------------------------------------------------------
# Copyright (C) 2018 EOX IT Services GmbH

. `dirname $0`/../lib_logging.sh

info "Installing netCDF4 ..."

yum install --assumeyes python36-netcdf4
