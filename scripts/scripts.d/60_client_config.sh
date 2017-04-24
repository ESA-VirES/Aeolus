#!/bin/sh
#-------------------------------------------------------------------------------
#
# Purpose: VirES client installation
# Author(s): Martin Paces <martin.paces@eox.at>
#-------------------------------------------------------------------------------
# Copyright (C) 2015 EOX IT Services GmbH

. `dirname $0`/../lib_logging.sh
. `dirname $0`/../lib_apache.sh

info "Configuring VirES client ..."

CLIENT_REQUIRED=${CLIENT_REQUIRED:-NO}

[ -z "$VIRES_SERVER_HOME" ] && error "Missing the required VIRES_SERVER_HOME variable!"
[ -z "$VIRES_CLIENT_HOME" ] && error "Missing the required VIRES_CLIENT_HOME variable!"
[ -z "$VIRES_USER" ] && error "Missing the required VIRES_USER variable!"

CONFIGURE_ALLAUTH="${CONFIGURE_ALLAUTH:-YES}"
BASIC_AUTH_PASSWD_FILE="/etc/httpd/authn/damats-passwords"
#VIRES_SERVER_URL="/`basename "$VIRES_SERVER_HOME"`"
VIRES_SERVER_URL=""
VIRES_CLIENT_URL="/`basename "$VIRES_CLIENT_HOME"`"
if [ "$CONFIGURE_ALLAUTH" == "YES" ]
then
    INSTANCE="`basename "$VIRES_SERVER_HOME"`"
    CONFIG_JSON="${VIRES_SERVER_HOME}/${INSTANCE}/static/workspace/scripts/config.json"
else
    CONFIG_JSON="${VIRES_CLIENT_HOME}/scripts/config.json"
fi

#-------------------------------------------------------------------------------
# Client configuration.

info "CONFIG_JSON=$CONFIG_JSON"

[ -f "$CONFIG_JSON" ] || {
    if [ "$CLIENT_REQUIRED" == "YES" ]
    then
        error "Failed to locate the client configuration file."
        exit 1
    else
        warn "Failed to locate the client configuration file."
        warn "Client configuration will be skipped."
        exit 0
    fi
}

# locate original replaced URL
OLD_URL="`sudo -u "$VIRES_USER" jq -r '.mapConfig.products[].download.url | select(.)' "$CONFIG_JSON" | sort | uniq | grep '/ows$' | head -n 1`"
[ -z "$OLD_URL" ] || sudo -u "$VIRES_USER" sed -i -e "s#\"${OLD_URL}#\"${VIRES_SERVER_URL}/ows#g" "$CONFIG_JSON"

#-------------------------------------------------------------------------------
# Integration with the Apache web server

info "Configuring Apache web server"

if [ "$CONFIGURE_ALLAUTH" == "YES" ]
then
    warn "ALLAUTH enabled. Removing self-standing client configuration."
fi

# locate proper configuration file (see also apache configuration)
{
    locate_apache_conf 80
    locate_apache_conf 443
} | while read CONF
do

    { ex "$CONF" || /bin/true ; } <<END
/EOXC00_BEGIN/,/EOXC00_END/de
wq
END

    [ "$CONFIGURE_ALLAUTH" == "YES" ] || ex "$CONF" <<END
/^[ 	]*<\/VirtualHost>/i
    # EOXC00_BEGIN - VirES for Aeolus Client - Do not edit or remove this line!

    RedirectMatch permanent ^/$ /eoxc/

    # VirES Client
    Alias $VIRES_CLIENT_URL "$VIRES_CLIENT_HOME"
    <Directory "$VIRES_CLIENT_HOME">
        Options -MultiViews +FollowSymLinks
    </Directory>

    # EOXC00_END - VirES for Aeolus Client - Do not edit or remove this line!
.
wq
END
done

#-------------------------------------------------------------------------------
# Restart Apache web server.

systemctl restart httpd.service
systemctl status httpd.service
