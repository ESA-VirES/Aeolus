#!/bin/sh
#-------------------------------------------------------------------------------
#
# Purpose: Vagrant OAuth instance initialization
# Author(s): Martin Paces <martin.paces@eox.at>
#-------------------------------------------------------------------------------
# Copyright (C) 2019 EOX IT Services GmbH

. `dirname $0`/../lib_logging.sh
. `dirname $0`/../lib_python_venv.sh
. `dirname $0`/../lib_oauth.sh

info "Initializing test user ... "

activate_venv "$OAUTH_VENV_ROOT"
set_instance_variables
required_variables MNGCMD

# vagrant users (password: vagrant)
python3 "$MNGCMD" user import << END
[
  {
    "username": "admin",
    "password": "pbkdf2_sha256\$150000\$Hpjuirbl8DfK\$8w2VtP5bw09Mtlgvf0Tsiu852cRhkTjaHpEmXw6ErXw=",
    "is_active": true,
    "date_joined": "2016-05-01T00:00:00.000000+00:00",
    "last_login": "2016-05-01T00:00:00.000000+00:00",
    "email": "vagrant.aelos.admin@eox.at",
    "groups": [
      "admin",
      "default",
      "vre",
      "l1a_access"
    ],
    "user_profile": {
      "country": "AT"
    },
    "email_addresses": [
      {
        "email": "vagrant.aelos.admin@eox.at",
        "verified": false,
        "primary": true
      }
    ]
  },
  {
    "username": "default",
    "password": "pbkdf2_sha256\$150000\$Hpjuirbl8DfK\$8w2VtP5bw09Mtlgvf0Tsiu852cRhkTjaHpEmXw6ErXw=",
    "is_active": true,
    "date_joined": "2016-05-01T00:00:00.000000+00:00",
    "last_login": "2016-05-01T00:00:00.000000+00:00",
    "email": "vagrant.aelos.default@eox.at",
    "groups": [
      "default",
      "vre"
    ],
    "user_profile": {
      "country": "AT"
    },
    "email_addresses": [
      {
        "email": "vagrant.aelos.default@eox.at",
        "verified": false,
        "primary": true
      }
    ]
  },
  {
    "username": "privileged",
    "password": "pbkdf2_sha256\$150000\$Hpjuirbl8DfK\$8w2VtP5bw09Mtlgvf0Tsiu852cRhkTjaHpEmXw6ErXw=",
    "is_active": true,
    "date_joined": "2016-05-01T00:00:00.000000+00:00",
    "last_login": "2016-05-01T00:00:00.000000+00:00",
    "email": "vagrant.aelos.privileged@eox.at",
    "groups": [
      "default",
      "privileged",
      "vre"
    ],
    "user_profile": {
      "country": "AT"
    },
    "email_addresses": [
      {
        "email": "vagrant.aelos.privileged@eox.at",
        "verified": false,
        "primary": true
      }
    ]
  }
]
END
