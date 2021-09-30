#!/bin/sh
#-------------------------------------------------------------------------------
#
# Purpose: Gunicorn installation
# Author(s): Martin Paces <martin.paces@eox.at>
#-------------------------------------------------------------------------------
# Copyright (C) 2019 EOX IT Services GmbH

. `dirname $0`/../lib_logging.sh
. `dirname $0`/../lib_python_venv.sh

info "Installing Gunicorn ..."

activate_venv "$VIRES_VENV_ROOT"

pip3 install $PIP_OPTIONS setproctitle
pip3 install $PIP_OPTIONS gunicorn
