#!/bin/sh
#-------------------------------------------------------------------------------
#
# VirES-Server utility scripts
# Authors: Martin Paces <martin.paces@eox.at>
#
#-------------------------------------------------------------------------------
# Copyright (C) 2018 EOX IT Services GmbH
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies of this Software or works derived from this Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#-------------------------------------------------------------------------------

set_instance_variables() {
    required_variables VIRES_SERVER_HOME VIRES_LOGDIR

    HOSTNAME="$VIRES_HOSTNAME"
    INSTANCE="`basename "$VIRES_SERVER_HOME"`"
    INSTROOT="`dirname "$VIRES_SERVER_HOME"`"

    SETTINGS="${INSTROOT}/${INSTANCE}/${INSTANCE}/settings.py"
    WSGI_FILE="${INSTROOT}/${INSTANCE}/${INSTANCE}/wsgi.py"
    URLS="${INSTROOT}/${INSTANCE}/${INSTANCE}/urls.py"
    TEMPLATES_DIR="${INSTROOT}/${INSTANCE}/${INSTANCE}/templates"
    FIXTURES_DIR="${INSTROOT}/${INSTANCE}/${INSTANCE}/data/fixtures"
    STATIC_DIR="${INSTROOT}/${INSTANCE}/${INSTANCE}/static"
    WSGI="${INSTROOT}/${INSTANCE}/${INSTANCE}/wsgi.py"
    MNGCMD="${INSTROOT}/${INSTANCE}/manage.py"
    alias manage="python3 $MNGCMD"

    #BASE_URL_PATH="/${INSTANCE}" # DO NOT USE THE TRAILING SLASH!!!
    BASE_URL_PATH=""
    STATIC_URL_PATH="/${INSTANCE}_static" # DO NOT USE THE TRAILING SLASH!!!

    VIRESLOG="${VIRES_LOGDIR}/eoxs/${INSTANCE}/vires.log"
    ACCESSLOG="${VIRES_LOGDIR}/eoxs/${INSTANCE}/access.log"

    GUNICORN_ACCESS_LOG="${VIRES_LOGDIR}/eoxs/${INSTANCE}/gunicorn_access.log"
    GUNICORN_ERROR_LOG="${VIRES_LOGDIR}/eoxs/${INSTANCE}/gunicorn_error.log"

    EOXSCONF="${INSTROOT}/${INSTANCE}/${INSTANCE}/conf/eoxserver.conf"
    OWS_URL="${VIRES_URL_ROOT}${BASE_URL_PATH}/ows"

    VIRES_DATA_DIR="${VIRES_DATA_DIR:-/mnt/data}"
    VIRES_OPTIMIZED_DIR="${VIRES_OPTIMIZED_DIR:-$VIRES_DATA_DIR/optimized}"
    VIRES_UPLOAD_DIR="${VIRES_UPLOAD_DIR:-$INSTROOT/user_upload}"
}

load_db_conf () {
    if [ -f "$1" ]
    then
        . "$1"
    fi
}

save_db_conf () {
    touch "$1"
    chmod 0600 "$1"
    cat > "$1" <<END
DBENGINE="$DBENGINE"
DBNAME="$DBNAME"
DBUSER="$DBUSER"
DBPASSWD="$DBPASSWD"
DBHOST="$DBHOST"
DBPORT="$DBPORT"
END
}

required_variables()
{
    for __VARIABLE___
    do
        if [ -z "${!__VARIABLE___}" ]
        then
            error "Missing the required ${__VARIABLE___} variable!"
        fi
    done
}
