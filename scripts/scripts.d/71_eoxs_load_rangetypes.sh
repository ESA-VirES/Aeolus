#!/bin/sh
#-------------------------------------------------------------------------------
#
# Purpose: Load Aeolus rangetypes to the EOxServer instance.
# Author(s): Martin Paces <martin.paces@eox.at>
#-------------------------------------------------------------------------------
# Copyright (C) 2018 EOX IT Services GmbH


[ -z "$VIRES_SERVER_HOME" ] && error "Missing the required VIRES_SERVER_HOME variable!"
[ -z "$VIRES_USER" ] && error "Missing the required VIRES_USER variable!"

INSTANCE="`basename "$VIRES_SERVER_HOME"`"
INSTROOT="`dirname "$VIRES_SERVER_HOME"`"
MNGCMD="${INSTROOT}/${INSTANCE}/manage.py"

RANGETYPE_FILE="/usr/local/aeolus/aeolus/data/range_types.json"

sudo -u "$VIRES_USER" python "$MNGCMD" eoxs_rangetype_load -i "${RANGETYPE_FILE}"
