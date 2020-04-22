#!/bin/sh
#-------------------------------------------------------------------------------
#
# Purpose: django-allauth installation
# Author(s): Daniel Santillan <daniel.santillan@eox.at>
#-------------------------------------------------------------------------------
# Copyright (C) 2016 EOX IT Services GmbH

. `dirname $0`/../lib_logging.sh

info "Installing django-allauth ..."


# TODO: figure out what we actually need
# yum --assumeyes install python-openid python-requests-oauthlib

pip3 install --upgrade --no-deps django-allauth #==0.24.1
pip3 install --upgrade django-countries #==3.4.1
