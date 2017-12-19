#!/bin/sh
#-------------------------------------------------------------------------------
#
# Purpose: CODA installation setup
# Author(s): Fabian Schindler <fabian.schindler@eox.at>
#-------------------------------------------------------------------------------
# Copyright (C) 2017 EOX IT Services GmbH

. `dirname $0`/../lib_logging.sh

info "Installing coda ..."

yum --assumeyes install coda coda-python
