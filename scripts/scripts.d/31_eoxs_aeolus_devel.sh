#!/bin/sh
#-------------------------------------------------------------------------------
#
# Purpose: VirES for Aeolus server installation - development mode
# Author(s): Martin Paces <martin.paces@eox.at>
#-------------------------------------------------------------------------------
# Copyright (C) 2015 EOX IT Services GmbH

. `dirname $0`/../lib_logging.sh
. `dirname $0`/../lib_python_venv.sh

info "Installing Aeolus-Server package in the development mode ..."

activate_venv "$VIRES_VENV_ROOT"

pip3 install -e "${VIRES_SOURCE_PATH:-/usr/local/aeolus}"
