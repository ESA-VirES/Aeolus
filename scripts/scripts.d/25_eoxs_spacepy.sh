#!/bin/sh
#-------------------------------------------------------------------------------
#
# Purpose: SpacePy package installation
# Author(s): Martin Paces <martin.paces@eox.at>
#-------------------------------------------------------------------------------
# Copyright (C) 2015 EOX IT Services GmbH

. `dirname $0`/../lib_logging.sh
. `dirname $0`/../lib_python_venv.sh

info "Installing SpacePy package and its dependencies ..."

activate_venv "$VIRES_VENV_ROOT"

yum --assumeyes install cdf

pip3 install $PIP_OPTIONS SpacePy
