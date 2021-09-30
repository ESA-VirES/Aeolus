#!/bin/sh
#-------------------------------------------------------------------------------
#
# Purpose: Copy templates to the EOxServer instance.
# Author(s): Martin Paces <martin.paces@eox.at>
#            Daniel Santillan <daniel.santillan@eox.at>
#-------------------------------------------------------------------------------
# Copyright (C) 2015 EOX IT Services GmbH

. `dirname $0`/../lib_logging.sh
. `dirname $0`/../lib_vires.sh

info "Copying Aeolus templates and static assets ..."

EOXS_ALLAUTH_TEMPLATES_ROOT="${EOXS_ALLAUTH_TEMPLATES_ROOT:-/usr/local/vires-aeolus_ops/6_eoxs_allauth_templates}"

set_instance_variables
required_variables STATIC_DIR TEMPLATES_DIR EOXS_ALLAUTH_TEMPLATES_ROOT

# copy static files
cp -rv "${EOXS_ALLAUTH_TEMPLATES_ROOT}"/static/* "$STATIC_DIR" 2>/dev/null || true

# copy templates
cp -rv "${EOXS_ALLAUTH_TEMPLATES_ROOT}"/templates/* "$TEMPLATES_DIR" 2>/dev/null || true
