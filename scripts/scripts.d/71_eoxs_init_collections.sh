#!/bin/sh
#-------------------------------------------------------------------------------
#
# Purpose: Initialize Aeolus collections
# Author(s): Martin Paces <martin.paces@eox.at>
#            Fabian Schindler <fabian.schindler@eox.at>
#-------------------------------------------------------------------------------
# Copyright (C) 2018 EOX IT Services GmbH

. `dirname $0`/../lib_logging.sh
. `dirname $0`/../lib_python_venv.sh
. `dirname $0`/../lib_vires.sh

info "Initializing Aeolus data collections. """

activate_venv "$VIRES_VENV_ROOT"

set_instance_variables

_create_product_type() {
    if [ -z "`manage producttype list | grep "^$1\$"`" ]
    then
        manage producttype create "$@"
    else
        info "Product type $1 already exits."
    fi
}

_create_collection_type() {
    if [ -z "`manage collectiontype list | grep "^$1\$"`" ]
    then
        manage collectiontype create "$@"
    else
        info "Collection type $1 already exits."
    fi
}

_create_collection() {
    if [ -z "`manage id list -t Collection "$1"`" ]
    then
        manage collection create "$@"
    else
        info "Collection $1 already exits."
    fi
}

_import_coverage_type() {
    if [ -z "`manage coveragetype list | grep "^$1\$"`" ]
    then
        manage coveragetype import "$2"
    else
        info "Coverage type $1 already exits."
    fi
}

# create initial collections
for product_type in ALD_U_N_1B ALD_U_N_2A ALD_U_N_2B ALD_U_N_2C AUX_ISR_1B AUX_MET_12 AUX_MRC_1B AUX_RRC_1B AUX_ZWC_1B
do
    _create_product_type ${product_type}
    _create_collection_type ${product_type} -p ${product_type}
    _create_collection ${product_type} -t ${product_type}
done

# create public collections
for product_type in ALD_U_N_1B ALD_U_N_2B ALD_U_N_2C
do
    _create_collection ${product_type}_public -t ${product_type}
done

_import_coverage_type ADAM_albedo "/usr/local/aeolus/aeolus/data/albedo_coverage_type.json"
_create_collection_type ADAM_albedo -c ADAM_albedo
_create_collection ADAM_albedo -t ADAM_albedo

# fix the access permissions (https://github.com/ESA-VirES/Aeolus-Server/issues/44)
manage migrate
