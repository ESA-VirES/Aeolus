#!/bin/sh
#-------------------------------------------------------------------------------
#
# Purpose: final server restart
# Author(s): Martin Paces <martin.paces@eox.at>
#-------------------------------------------------------------------------------
# Copyright (C) 2018 EOX IT Services GmbH

. `dirname $0`/../lib_logging.sh


list_services() {
    for SERVICE in httpd ${OAUTH_SERVICE_NAME} ${VIRES_SERVICE_NAME} ${VIRES_WPS_SERVICE_NAME}
    do
        echo "${SERVICE}.service"
    done
}

list_services
for SERVICE in `list_services`
do
    info "stopping $SERVICE ..."
    systemctl stop $SERVICE
done

info "reloading daemons' configuration ..."
systemctl daemon-reload

for SERVICE in `list_services | tac`
do
    info "starting $SERVICE ..."
    systemctl start $SERVICE
done

for SERVICE in `list_services`
do
    systemctl status $SERVICE
done
