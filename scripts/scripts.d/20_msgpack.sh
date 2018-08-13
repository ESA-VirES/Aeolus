#!/bin/sh
#-------------------------------------------------------------------------------
#
# Purpose: Messagepack python installation.
# Author(s): Fabian Schindler <fabian.schindler@eox.at>
#-------------------------------------------------------------------------------
# Copyright (C) 2015 EOX IT Services GmbH

. `dirname $0`/../lib_logging.sh

info "Installing messagepack ..."

pip install msgpack-python
