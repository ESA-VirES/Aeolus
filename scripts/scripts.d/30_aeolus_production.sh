#!/bin/sh
#-------------------------------------------------------------------------------
#
# Purpose: VirES server - production mode
# Author(s): Martin Paces <martin.paces@eox.at>
#-------------------------------------------------------------------------------
# Copyright (C) 2015 EOX IT Services GmbH

. `dirname $0`/../lib_logging.sh

info "Installing Aeolus-Server package."

# Path to the VirES-Server development directory tree:
VIRES_DEV_PATH="${VIRES_DEV_PATH:-/usr/local/aeolus}"

# STEP 1: INSTALL DEPENDENCIES
yum --assumeyes install python-matplotlib python-setuptools

# STEP 2: INSTALL VIRES
# setup.py install keeps messy leftovers!
# Uninstall previously installed package.
PACKAGE=Aeolus-Server
[ -z "`pip freeze | grep "$PACKAGE" `" ] || pip uninstall -y "$PACKAGE"
pushd .
cd "$VIRES_DEV_PATH"
[ ! -d build/ ] || rm -fvR build/
[ ! -d dist/ ] || rm -fvR dist/
python3 ./setup.py install
popd
