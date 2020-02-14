#!/bin/sh

[ -z "$VIRES_SERVER_HOME" ] && error "Missing the required VIRES_SERVER_HOME variable!"
[ -z "$VIRES_USER" ] && error "Missing the required VIRES_USER variable!"

INSTANCE="`basename "$VIRES_SERVER_HOME"`"
INSTROOT="`dirname "$VIRES_SERVER_HOME"`"
MNGCMD="${INSTROOT}/${INSTANCE}/manage.py"

# create initial collections
for product_type in ALD_U_N_1B ALD_U_N_2A ALD_U_N_2B ALD_U_N_2C AUX_ISR_1B AUX_MET_12 AUX_MRC_1B AUX_RRC_1B AUX_ZWC_1B ; do
    sudo -u "$VIRES_USER" python3 "$MNGCMD" producttype create ${product_type}
    sudo -u "$VIRES_USER" python3 "$MNGCMD" collectiontype create ${product_type} -p ${product_type}
    sudo -u "$VIRES_USER" python3 "$MNGCMD" collection create ${product_type} -t ${product_type}
done

# register albedo files

sudo -u "$VIRES_USER" python3 "$MNGCMD" collectiontype create ADAM_albedo -c ADAM_albedo
sudo -u "$VIRES_USER" python3 "$MNGCMD" collection create ADAM_albedo -t ADAM_albedo

sudo python3 "$MNGCMD" aeolus_albedo_register -r 2000-2020 -m 1  -c ADAM_albedo -f /mnt/data/Albedo_maps/SDR_jan.nc
sudo python3 "$MNGCMD" aeolus_albedo_register -r 2000-2020 -m 2  -c ADAM_albedo -f /mnt/data/Albedo_maps/SDR_feb.nc
sudo python3 "$MNGCMD" aeolus_albedo_register -r 2000-2020 -m 3  -c ADAM_albedo -f /mnt/data/Albedo_maps/SDR_mar.nc
sudo python3 "$MNGCMD" aeolus_albedo_register -r 2000-2020 -m 4  -c ADAM_albedo -f /mnt/data/Albedo_maps/SDR_apr.nc
sudo python3 "$MNGCMD" aeolus_albedo_register -r 2000-2020 -m 5  -c ADAM_albedo -f /mnt/data/Albedo_maps/SDR_may.nc
sudo python3 "$MNGCMD" aeolus_albedo_register -r 2000-2020 -m 6  -c ADAM_albedo -f /mnt/data/Albedo_maps/SDR_jun.nc
sudo python3 "$MNGCMD" aeolus_albedo_register -r 2000-2020 -m 7  -c ADAM_albedo -f /mnt/data/Albedo_maps/SDR_jul.nc
sudo python3 "$MNGCMD" aeolus_albedo_register -r 2000-2020 -m 8  -c ADAM_albedo -f /mnt/data/Albedo_maps/SDR_aug.nc
sudo python3 "$MNGCMD" aeolus_albedo_register -r 2000-2020 -m 9  -c ADAM_albedo -f /mnt/data/Albedo_maps/SDR_sep.nc
sudo python3 "$MNGCMD" aeolus_albedo_register -r 2000-2020 -m 10 -c ADAM_albedo -f /mnt/data/Albedo_maps/SDR_oct.nc
sudo python3 "$MNGCMD" aeolus_albedo_register -r 2000-2020 -m 11 -c ADAM_albedo -f /mnt/data/Albedo_maps/SDR_nov.nc
sudo python3 "$MNGCMD" aeolus_albedo_register -r 2000-2020 -m 12 -c ADAM_albedo -f /mnt/data/Albedo_maps/SDR_dec.nc

# (re-)register

sudo python3 "$MNGCMD" aeolus_product_add /mnt/data/*/AE_OPER_ALD_U_N_1B*DBL --collection ALD_U_N_1B --conflict=REPLACE --traceback
sudo python3 "$MNGCMD" aeolus_product_add /mnt/data/*/AE_OPER_ALD_U_N_2A*DBL --collection ALD_U_N_2A --conflict=REPLACE --traceback
sudo python3 "$MNGCMD" aeolus_product_add /mnt/data/*/AE_OPER_ALD_U_N_2B*DBL --collection ALD_U_N_2B --conflict=REPLACE --traceback
sudo python3 "$MNGCMD" aeolus_product_add /mnt/data/*/AE_OPER_ALD_U_N_2C*DBL --collection ALD_U_N_2C --conflict=REPLACE --traceback

sudo python3 "$MNGCMD" aeolus_product_add /mnt/data/*/*_ISR_*EEF --collection AUX_ISR_1B  --conflict=REPLACE --traceback
sudo python3 "$MNGCMD" aeolus_product_add /mnt/data/*/*_MRC_*EEF --collection AUX_MRC_1B  --conflict=REPLACE --traceback
sudo python3 "$MNGCMD" aeolus_product_add /mnt/data/*/*_RRC_*EEF --collection AUX_RRC_1B  --conflict=REPLACE --traceback
sudo python3 "$MNGCMD" aeolus_product_add /mnt/data/*/*_ZWC_*EEF --collection AUX_ZWC_1B  --conflict=REPLACE --traceback
