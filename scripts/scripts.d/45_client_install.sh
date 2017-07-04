#!/bin/sh
#-------------------------------------------------------------------------------
#
# Purpose: VirES for Aeolus client installation
# Author(s): Martin Paces <martin.paces@eox.at>
#-------------------------------------------------------------------------------
# Copyright (C) 2015 EOX IT Services GmbH

. `dirname $0`/../lib_logging.sh

info "Installing Aeolus client ..."

CLIENT_REQUIRED=${CLIENT_REQUIRED:-NO}

[ -z "$CONTRIB_DIR" ] && error "Missing the required CONTRIB_DIR variable!"
[ -z "$VIRES_CLIENT_HOME" ] && error "Missing the required VIRES_CLIENT_HOME variable!"
[ -z "$VIRES_USER" ] && error "Missing the required VIRES_USER variable!"
[ -z "$VIRES_GROUP" ] && error "Missing the required VIRES_GROUP variable!"

TMPDIR='/tmp/eoxc'

# locate lates TGZ package
FNAME="`ls "$CONTRIB_DIR"/Aeolus-Client*.{tar.gz,tgz} 2>/dev/null | sort | tail -n 1`"

[ -n "$FNAME" -a -f "$FNAME" ] || {
    if [ "$CLIENT_REQUIRED" == "YES" ]
    then
        error "Failed to locate the installation package."
        exit 1
    else
        warn "Failed to locate the installation package."
        warn "Client installation will be skipped."
        exit 0
    fi
}

# installing the ODA-Client

# clean-up the previous installation if needed
[ -d "$VIRES_CLIENT_HOME" ] && rm -fR "$VIRES_CLIENT_HOME"
[ -d "$TMPDIR" ] && rm -fR "$TMPDIR"

# init
mkdir -p "$TMPDIR"

# unpack
info "Installation package located in: $FNAME"
tar -xzf "$FNAME" --directory="$TMPDIR"

# move to destination
ROOT="`find "$TMPDIR" -mindepth 1 -maxdepth 1 -type d | head -n 1`"
mv -f "$ROOT" "$VIRES_CLIENT_HOME"

# fix permisions
chown -R "$VIRES_USER:$VIRES_GROUP" "$VIRES_CLIENT_HOME"

info "Aeolus Client installed to: $VIRES_CLIENT_HOME"
