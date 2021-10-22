#!/bin/sh
#-------------------------------------------------------------------------------
#
# Purpose: numpy installation.
# Author(s): Martin Paces <martin.paces@eox.at>
#-------------------------------------------------------------------------------
# Copyright (C) 2018 EOX IT Services GmbH

. `dirname $0`/../lib_logging.sh
. `dirname $0`/../lib_python_venv.sh

info "Installing numpy ..."

activate_venv "$VIRES_VENV_ROOT"

pip3 install $PIP_OPTIONS 'numpy>=1.19.0,<1.20a0'
