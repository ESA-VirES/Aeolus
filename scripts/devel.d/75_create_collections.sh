#!/bin/sh
#-------------------------------------------------------------------------------
#
# Purpose: Load fixtures to the EOxServer instance.
# Author(s): Martin Paces <martin.paces@eox.at>
#-------------------------------------------------------------------------------
# Copyright (C) 2015 EOX IT Services GmbH


. `dirname $0`/../lib_logging.sh

info "Creating Aeolus collections ... "

[ -z "$CONTRIB_DIR" ] && error "Missing the required CONTRIB_DIR variable!"
[ -z "$VIRES_SERVER_HOME" ] && error "Missing the required VIRES_SERVER_HOME variable!"
[ -z "$VIRES_USER" ] && error "Missing the required VIRES_USER variable!"
[ -z "$VIRES_GROUP" ] && error "Missing the required VIRES_GROUP variable!"

INSTANCE="`basename "$VIRES_SERVER_HOME"`"
INSTROOT="`dirname "$VIRES_SERVER_HOME"`"
MNGCMD="${INSTROOT}/${INSTANCE}/manage.py"

RANGETYPE_FILE="/usr/local/aeolus/aeolus/data/range_types.json"

sudo -u "$VIRES_USER" python "$MNGCMD" eoxs_rangetype_load -i "${RANGETYPE_FILE}"

declare -A COLLECTION_TO_RANGETYPE
COLLECTION_TO_RANGETYPE=(
    ["L1B"]="ALD_U_N_1B"
    ["L2A"]="ALD_U_N_2A"
    ["L2B"]="ALD_U_N_2B"
    ["L2C"]="ALD_U_N_2C"
    ["AUX_ISR"]="AUX_ISR_1B"
    ["AUX_MET"]="AUX_MET_12"
    ["AUX_MRC"]="AUX_MRC_1B"
    ["AUX_RRC"]="AUX_RRC_1B"
    ["AUX_ZWC"]="AUX_ZWC_1B"
)

for collection in "${!COLLECTION_TO_RANGETYPE[@]}" ; do
    if sudo -u "$VIRES_USER" python "$MNGCMD" eoxs_id_check "${collection}" 2> /dev/null ; then
        echo "Creating collection ${collection}"
        sudo -u "$VIRES_USER" python "$MNGCMD" aeolus_collection_create \
            -i "${collection}" \
            -r "${COLLECTION_TO_RANGETYPE[$collection]}"
    else
        echo "Collection ${collection} already exists"
    fi
done