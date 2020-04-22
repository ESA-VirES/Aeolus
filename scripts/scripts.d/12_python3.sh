#!/bin/sh

. `dirname $0`/../lib_logging.sh

info "Installing Python3 ..."

yum --assumeyes install python3
