#!/bin/sh
#-------------------------------------------------------------------------------
#
# Purpose: Register Aeolus products
# Author(s): Martin Paces <martin.paces@eox.at>
#            Fabian Schindler <fabian.schindler@eox.at>
#-------------------------------------------------------------------------------
# Copyright (C) 2018 EOX IT Services GmbH

. `dirname $0`/../lib_logging.sh
. `dirname $0`/../lib_python_venv.sh
. `dirname $0`/../lib_vires.sh

info "Registering Aeolus products. """

activate_venv "$VIRES_VENV_ROOT"

set_instance_variables

# register albedo maps
manage aeolus_albedo_register -r 2000-2020 -m 1  -c ADAM_albedo -f /mnt/data/Albedo_maps/SDR_jan.nc || true
manage aeolus_albedo_register -r 2000-2020 -m 2  -c ADAM_albedo -f /mnt/data/Albedo_maps/SDR_feb.nc || true
manage aeolus_albedo_register -r 2000-2020 -m 3  -c ADAM_albedo -f /mnt/data/Albedo_maps/SDR_mar.nc || true
manage aeolus_albedo_register -r 2000-2020 -m 4  -c ADAM_albedo -f /mnt/data/Albedo_maps/SDR_apr.nc || true
manage aeolus_albedo_register -r 2000-2020 -m 5  -c ADAM_albedo -f /mnt/data/Albedo_maps/SDR_may.nc || true
manage aeolus_albedo_register -r 2000-2020 -m 6  -c ADAM_albedo -f /mnt/data/Albedo_maps/SDR_jun.nc || true
manage aeolus_albedo_register -r 2000-2020 -m 7  -c ADAM_albedo -f /mnt/data/Albedo_maps/SDR_jul.nc || true
manage aeolus_albedo_register -r 2000-2020 -m 8  -c ADAM_albedo -f /mnt/data/Albedo_maps/SDR_aug.nc || true
manage aeolus_albedo_register -r 2000-2020 -m 9  -c ADAM_albedo -f /mnt/data/Albedo_maps/SDR_sep.nc || true
manage aeolus_albedo_register -r 2000-2020 -m 10 -c ADAM_albedo -f /mnt/data/Albedo_maps/SDR_oct.nc || true
manage aeolus_albedo_register -r 2000-2020 -m 11 -c ADAM_albedo -f /mnt/data/Albedo_maps/SDR_nov.nc || true
manage aeolus_albedo_register -r 2000-2020 -m 12 -c ADAM_albedo -f /mnt/data/Albedo_maps/SDR_dec.nc || true

# register Aeolus products
manage aeolus_product_add /mnt/data/ALD_U_N_1B/AE_OPER_ALD_U_N_1B*.DBL --collection ALD_U_N_1B --conflict=REPLACE --traceback
manage aeolus_product_add /mnt/data/ALD_U_N_1B_public/AE_OPER_ALD_U_N_1B*.DBL --collection ALD_U_N_1B_public --conflict=REPLACE --traceback
manage aeolus_product_add /mnt/data/ALD_U_N_2A/AE_OPER_ALD_U_N_2A*.DBL --collection ALD_U_N_2A --conflict=REPLACE --traceback
manage aeolus_product_add /mnt/data/ALD_U_N_2B/AE_OPER_ALD_U_N_2B*.DBL --collection ALD_U_N_2B --conflict=REPLACE --traceback
manage aeolus_product_add /mnt/data/ALD_U_N_2B_public/AE_OPER_ALD_U_N_2B*.DBL --collection ALD_U_N_2B_public --conflict=REPLACE --traceback
manage aeolus_product_add /mnt/data/ALD_U_N_2C/AE_OPER_ALD_U_N_2C*.DBL --collection ALD_U_N_2C --conflict=REPLACE --traceback
manage aeolus_product_add /mnt/data/ALD_U_N_2C_public/AE_OPER_ALD_U_N_2C*.DBL --collection ALD_U_N_2C_public --conflict=REPLACE --traceback
manage aeolus_product_add /mnt/data/AUX_ISR_1B/AE_*_ISR_*.EEF --collection AUX_ISR_1B  --conflict=REPLACE --traceback
manage aeolus_product_add /mnt/data/AUX_MRC_1B/AE_*_MRC_*.EEF --collection AUX_MRC_1B  --conflict=REPLACE --traceback
manage aeolus_product_add /mnt/data/AUX_RRC_1B/AE_*_RRC_*.EEF --collection AUX_RRC_1B  --conflict=REPLACE --traceback
manage aeolus_product_add /mnt/data/AUX_ZWC_1B/AE_*_ZWC_*.EEF --collection AUX_ZWC_1B  --conflict=REPLACE --traceback
manage aeolus_product_add /mnt/data/AUX_MET_12/AE_*_MET_*.DBL --collection AUX_MET_12  --conflict=REPLACE --traceback
