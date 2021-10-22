#!/bin/sh
#-------------------------------------------------------------------------------
#
# Purpose: Messagepack python installation.
# Author(s): Fabian Schindler <fabian.schindler@eox.at>
#-------------------------------------------------------------------------------
# Copyright (C) 2015 EOX IT Services GmbH

. `dirname $0`/../lib_logging.sh
. `dirname $0`/../lib_python_venv.sh

info "Installing msgpack ..."

activate_venv "$VIRES_VENV_ROOT"

pip3 install $PIP_OPTIONS 'msgpack-python'
