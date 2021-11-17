#!/bin/sh
#-------------------------------------------------------------------------------
#
# Purpose: CODA installation setup
# Author(s): Fabian Schindler <fabian.schindler@eox.at>
#-------------------------------------------------------------------------------
# Copyright (C) 2017 EOX IT Services GmbH

. `dirname $0`/../lib_logging.sh
. `dirname $0`/../lib_python_venv.sh
. `dirname $0`/../lib_util.sh

info "Installing coda ..."

yum --assumeyes install coda coda-devel python3-devel swig3

activate_venv "$VIRES_VENV_ROOT"

[ -z "$CONTRIB_DIR" ] && error "Missing the required CONTRIB_DIR variable!"
PACKAGE="`lookup_package "$CONTRIB_DIR/python-coda-*.tar.gz"`"
[ -n "$PACKAGE" ] || error "Source distribution package not found!"
pip3 install $PIP_OPTIONS "$PACKAGE"


# download Aeolus product definition file
VERSION="20211103"
FILENAME="AEOLUS-${VERSION}.codadef"
SOURCE_URL="https://github.com/stcorp/codadef-aeolus/releases/download/${VERSION}/${FILENAME}"
TARGET_DIR="$VENV_ROOT/share/coda/definitions/"

if [ ! -f "${TARGET_DIR}/${FILENAME}" ]
then
    info "Fetching coda Aeolus definition files ..."
    mkdir -p "$TARGET_DIR"
    rm -fv "$TARGET_DIR/*.codadef"
    wget -q -P "$TARGET_DIR" "$SOURCE_URL"
fi
