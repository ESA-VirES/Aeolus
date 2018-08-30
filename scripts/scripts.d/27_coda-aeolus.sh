#!/bin/sh
#-------------------------------------------------------------------------------
#
# Purpose: installation of coda Aeolus definitions
# Author(s): Fabian Schindler <fabian.schindler@eox.at>
#-------------------------------------------------------------------------------
# Copyright (C) 2017 EOX IT Services GmbH

. `dirname $0`/../lib_logging.sh

AEOLUS_DEFINITION_FILE=AEOLUS-20170913.codadef
AEOLUS_DEFINITION_URL=https://github.com/stcorp/codadef-aeolus/releases/download/20170913/${AEOLUS_DEFINITION_FILE}

if [ ! -f "/usr/share/coda/definitions/${AEOLUS_DEFINITION_FILE}" ]; then
    info "Fetching coda Aeolus definition files ..."
    wget -q -P /usr/share/coda/definitions/ $AEOLUS_DEFINITION_URL
fi
