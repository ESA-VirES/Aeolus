#!/bin/sh
#-------------------------------------------------------------------------------
#
# Purpose: django-allauth installation
# Author(s): Daniel Santillan <daniel.santillan@eox.at>
#-------------------------------------------------------------------------------
# Copyright (C) 2016 EOX IT Services GmbH

. `dirname $0`/../lib_logging.sh
. `dirname $0`/../lib_python_venv.sh

info "Installing django-allauth ..."

activate_venv "$VIRES_VENV_ROOT"

pip3 install $PIP_OPTIONS python-openid
pip3 install $PIP_OPTIONS requests-oauthlib
pip3 install $PIP_OPTIONS django-allauth
pip3 install $PIP_OPTIONS django-countries
