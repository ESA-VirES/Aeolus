#!/bin/sh
#-------------------------------------------------------------------------------
#
# Purpose: psycopg2 - Python-PostgreSQL Database Adapter installation
# Author(s): Martin Paces <martin.paces@eox.at>
#-------------------------------------------------------------------------------
# Copyright (C) 2015 EOX IT Services GmbH

. `dirname $0`/../lib_logging.sh
. `dirname $0`/../lib_python_venv.sh
. `dirname $0`/../lib_postgres.sh

info "Installing psycopg2 (Python-PostgreSQL Database Adapter) ... """

yum --assumeyes install $PG_DEVEL_PACKAGE

activate_venv "$VIRES_VENV_ROOT"
pip3 install --force-reinstall --no-binary :all: psycopg2
