#!/bin/sh
#-------------------------------------------------------------------------------
#
# Purpose: EOxServer django-allauth integration
# Author(s): Martin Paces <martin.paces@eox.at>
#-------------------------------------------------------------------------------
# Copyright (C) 2015 EOX IT Services GmbH

. `dirname $0`/../lib_logging.sh

info "Installing EOxServer django-allauth integration package."

# Path to the VirES-Server development directory tree:
EOXS_ALLAUTH_DEV_PATH="${EOXS_ALLAUTH_DEV_PATH:-/usr/local/eoxs-allauth}"

# STEP 1: INSTALL DEPENDENCIES
yum --assumeyes install python-setuptools

# STEP 2: INSTALL EOxServer django-allauth integration
# setup.py install keeps messy leftovers!
# Uninstall previously installed package.
PACKAGE=EOxServer-allauth
[ -z "`pip freeze | grep "$PACKAGE" `" ] || pip uninstall -y "$PACKAGE"
pushd .
cd "$EOXS_ALLAUTH_DEV_PATH"
[ ! -d build/ ] || rm -fvR build/
[ ! -d dist/ ] || rm -fvR dist/
pip3 install --no-deps -U .
popd
