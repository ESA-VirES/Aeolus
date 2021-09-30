#!/bin/sh
#-------------------------------------------------------------------------------
#
# Purpose: EOxServer django-allauth integration
# Author(s): Martin Paces <martin.paces@eox.at>
#-------------------------------------------------------------------------------
# Copyright (C) 2015 EOX IT Services GmbH

. `dirname $0`/../lib_logging.sh
. `dirname $0`/../lib_python_venv.sh

info "Installing EOxServer django-allauth integration package."

activate_venv "$VIRES_VENV_ROOT"

pip3 install $PIP_OPTIONS "${EOXS_ALLAUTH_SOURCE_PATH:-/usr/local/vires/eoxs_allauth}"
#pip3 install $PIP_OPTIONS "${EOXS_ALLAUTH_SOURCE_PATH:-/usr/local/eoxs-allauth}"
