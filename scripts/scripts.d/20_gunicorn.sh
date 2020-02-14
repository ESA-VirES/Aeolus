#!/bin/sh

. `dirname $0`/../lib_logging.sh

info "Installing gunicorn ..."

pip3 install 'gunicorn'
