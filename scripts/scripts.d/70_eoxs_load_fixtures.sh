#!/bin/sh
#-------------------------------------------------------------------------------
#
# Purpose: Load fixtures to the EOxServer instance.
# Author(s): Martin Paces <martin.paces@eox.at>
#-------------------------------------------------------------------------------
# Copyright (C) 2015 EOX IT Services GmbH


. `dirname $0`/../lib_logging.sh
. `dirname $0`/../lib_python_venv.sh
. `dirname $0`/../lib_vires.sh

info "Loading available EOxServer fixtures ... "

activate_venv "$VIRES_VENV_ROOT"

set_instance_variables

required_variables MNGCMD CONTRIB_DIR VIRES_USER VIRES_GROUP

{ ls "$FIXTURES_DIR_SRC/"*.json 2>/dev/null || true ; } | while read SRC
do
    FNAME="`basename "$SRC" .json`"
    info "Loading fixture '$FNAME' ..."
    DST="${FIXTURES_DIR_DST}/${FNAME}.json"
    cp "$SRC" "$DST"
    manage loaddata "$FNAME"
done
