#!/bin/sh
#-------------------------------------------------------------------------------
#
# Purpose: EOxServer django-allauth integration - development mode
# Author(s): Martin Paces <martin.paces@eox.at>
#-------------------------------------------------------------------------------
# Copyright (C) 2015 EOX IT Services GmbH

. `dirname $0`/../lib_logging.sh

info "Installing EOxServer django-allauth integration package in the development mode."

# Path to the VirES-Server development directory tree:
EOXS_ALLAUTH_DEV_PATH="${EOXS_ALLAUTH_DEV_PATH:-/usr/local/eoxs-allauth}"

# STEP 1: INSTALL DEPENDENCIES
yum --assumeyes install python-setuptools

# STEP 2: INSTALL EOxServer django-allauth integration
pushd .
cd "$EOXS_ALLAUTH_DEV_PATH"
python ./setup.py develop
popd
