#!/bin/sh
#-------------------------------------------------------------------------------
#
# Purpose: Aeolus client installation
# Author(s): Martin Paces <martin.paces@eox.at>
#-------------------------------------------------------------------------------
# Copyright (C) 2015 EOX IT Services GmbH

. `dirname $0`/../lib_logging.sh
. `dirname $0`/../lib_util.sh
. `dirname $0`/../lib_vires.sh

CONFIGURE_ALLAUTH="${CONFIGURE_ALLAUTH:-YES}"

info "Aeolus client installation ..."

required_variables CONTRIB_DIR VIRES_INSTALL_USER VIRES_INSTALL_GROUP

install_client() {
    SOURCE="$1"
    INSTALL_DIR=$2

    # remove the previous installation
    [ -d "$INSTALL_DIR" ] && rm -fR "$INSTALL_DIR"

    tar -xzf "$SOURCE"

    # move the extracted directory to the final destination
    ROOT="`find "$PWD" -mindepth 1 -maxdepth 1 -type d -name 'Aeolus-Client*' | head -n 1`"
    chown -R "$VIRES_INSTALL_USER:$VIRES_INSTALL_GROUP" "$ROOT"
    mv -f "$ROOT" "$INSTALL_DIR"

    info "Aeolus Client installed to: $INSTALL_DIR"
}

# locate the installation package
FNAME="`lookup_package "$CONTRIB_DIR/Aeolus-Client*.tar.gz"`"
[ -n "$FNAME" ] || {
    warn "Failed to locate the client installation package."
    warn "The client installation is skipped."
    exit 0
}

info "Installation package located in: $FNAME"

# extract archive in a temporary directory
create_and_enter_tmp_dir

if [ "$CONFIGURE_ALLAUTH" != "YES" ]
then
    required_variables VIRES_CLIENT_HOME
    install_client "$FNAME" "$VIRES_CLIENT_HOME"
    exit
fi

# Install client again to get workspace static assets ...
info "Adding Aeolus client to EOxServer instance static files ..."
set_instance_variables
required_variables STATIC_DIR
install_client "$FNAME" "${STATIC_DIR}/workspace/"
