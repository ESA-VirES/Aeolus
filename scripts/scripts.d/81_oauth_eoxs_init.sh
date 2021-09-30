#!/bin/sh
#-------------------------------------------------------------------------------
#
# Purpose: Vagrant OAuth instance initialization
# Author(s): Martin Paces <martin.paces@eox.at>
#-------------------------------------------------------------------------------
# Copyright (C) 2019 EOX IT Services GmbH

. `dirname $0`/../lib_logging.sh
. `dirname $0`/../lib_python_venv.sh

info "Initializing Aeolus OAuth app ... "

CONFIGURE_ALLAUTH="${CONFIGURE_ALLAUTH:-YES}"

if [ "$CONFIGURE_ALLAUTH" != "YES" ]
then
    warn "OAuth authetication disabled. Initialization skipped."
    exit
fi

VIRES_CALLBACK_URL="${LOCAL_URL:-http://localhost:8400}/accounts/vires/login/callback/"
VIRES_CLIENT_ID="YPGerrotDZTNtBM3di7fNwZSmTXfuuPbTNp67CJC"
VIRES_CLIENT_SECRET="`base64 /dev/urandom | tr -d '+/\n' | head -c '128'`"

. `dirname $0`/../lib_oauth.sh
activate_venv "$OAUTH_VENV_ROOT"
set_instance_variables
required_variables MNGCMD

# Aeolus-Server OAuth client initialization
python3 "$MNGCMD" app import << END
[
  {
    "name": "VirES for Aeolus - Vagrant",
    "client_id": "$VIRES_CLIENT_ID",
    "client_secret": "$VIRES_CLIENT_SECRET",
    "redirect_uris": [
        "$VIRES_CALLBACK_URL"
    ],
    "client_type": "confidential",
    "authorization_grant_type": "authorization-code",
    "skip_authorization": false
  }
]
END

deactivate

. `dirname $0`/../lib_vires.sh
activate_venv "$VIRES_VENV_ROOT"
set_instance_variables
required_variables MNGCMD

# initialize "social network" provider
python3 "$MNGCMD" social_provider import <<END
[
  {
    "provider": "vires",
    "name": "VirES",
    "client_id": "$VIRES_CLIENT_ID",
    "secret": "$VIRES_CLIENT_SECRET"
  }
]
END
