#!/bin/sh
#-------------------------------------------------------------------------------
#
# Purpose: netCDF4 installation.
# Author(s): Fabian Schindler <fabian.schindler@eox.at>
#-------------------------------------------------------------------------------
# Copyright (C) 2018 EOX IT Services GmbH

. `dirname $0`/../lib_logging.sh
. `dirname $0`/../lib_python_venv.sh

info "Installing netCDF4 ..."

activate_venv "$VIRES_VENV_ROOT"

pip3 install $PIP_OPTIONS 'netcdf4>=1.5.0,<1.6a0'
