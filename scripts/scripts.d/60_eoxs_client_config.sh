#!/bin/sh
#-------------------------------------------------------------------------------
#
# Purpose: VirES client installation
# Author(s): Martin Paces <martin.paces@eox.at>
#-------------------------------------------------------------------------------
# Copyright (C) 2015 EOX IT Services GmbH

. `dirname $0`/../lib_logging.sh
. `dirname $0`/../lib_apache.sh
. `dirname $0`/../lib_vires.sh

CONFIGURE_ALLAUTH="${CONFIGURE_ALLAUTH:-YES}"

info "Configuring Aeolus client ..."

#-------------------------------------------------------------------------------
# Integration with the Apache web server

if [ "$CONFIGURE_ALLAUTH" == "YES" ]
then
    info "Allauth authentication enabled. Removing any previous self-standing client configuration."
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

    if [ "$CONFIGURE_ALLAUTH" != "YES" ]
    then
        ex "$CONF" <<END
/^\\s*\\(# EOXS00_BEGIN\\|<\/VirtualHost>\\)/i
    # EOXC00_BEGIN - VirES Client - Do not edit or remove this line!

    ProxyPass "$VIRES_CLIENT_URL" !
    ProxyPassMatch "^/$" !
    RedirectMatch ^/$ $VIRES_CLIENT_URL/

    # VirES Client
    Alias $VIRES_CLIENT_URL "$VIRES_CLIENT_HOME"
    Alias /eoxc "/var/www/vires/client"
    <Directory "$VIRES_CLIENT_HOME">
        Options -MultiViews +FollowSymLinks
    </Directory>

    # EOXC00_END - VirES Client - Do not edit or remove this line!
.
wq
END
    fi

done

info "Apache web server has been re-configured."
