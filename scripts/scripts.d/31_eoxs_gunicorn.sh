#!/bin/sh

. `dirname $0`/../lib_logging.sh
. `dirname $0`/../lib_apache.sh

info ""

GUNICORN_SOCKET="$VIRES_ROOT/gunicorn.sock"

echo "[Unit]
Description=gunicorn daemon
After=network.target

[Service]
User=$VIRES_USER
Group=$VIRES_GROUP
WorkingDirectory=$VIRES_SERVER_HOME
ExecStart=/usr/local/bin/gunicorn --workers $EOXS_WSGI_NPROC --timeout 600 --bind 127.0.0.1:8012 --chdir ${INSTROOT}/${INSTANCE} ${INSTANCE}.wsgi:application

[Install]
WantedBy=multi-user.target
" > /etc/systemd/system/gunicorn.service

service gunicorn start
service gunicorn status

systemctl status gunicorn.service
