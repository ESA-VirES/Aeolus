#!/bin/bash

MNGCMD="sudo -u vires /var/www/vires/venv_p36_eoxs/bin/python /var/www/vires/eoxs/manage.py"

INIT_COLLECIONS="NO"

if [ "$INIT_COLLECIONS" = "YES" ]
then
    $MNGCMD coveragetype import /usr/local/aeolus/aeolus/data/albedo_coverage_type.json
    $MNGCMD collectiontype create ADAM_albedo -c ADAM_albedo

    #ADAM_albedo

    while read TYPE
    do
        $MNGCMD producttype create "$TYPE"
        $MNGCMD collectiontype create "$TYPE" -p "$TYPE"
    done << END
ALD_U_N_1B
ALD_U_N_2A
ALD_U_N_2B
ALD_U_N_2C
AUX_ISR_1B
AUX_MET_12
AUX_MRC_1B
AUX_RRC_1B
AUX_ZWC_1B
END

    while read TYPE COLLECTION
    do
        $MNGCMD collection create $COLLECTION -t $TYPE
    done << END
ADAM_albedo ADAM_albedo
ALD_U_N_1B ALD_U_N_1B
ALD_U_N_1B ALD_U_N_1B_public
ALD_U_N_2A ALD_U_N_2A
ALD_U_N_2B ALD_U_N_2B
ALD_U_N_2B ALD_U_N_2B_public
ALD_U_N_2C ALD_U_N_2C
ALD_U_N_2C ALD_U_N_2C_public
AUX_ISR_1B AUX_ISR_1B
AUX_MET_12 AUX_MET_12
AUX_MRC_1B AUX_MRC_1B
AUX_RRC_1B AUX_RRC_1B
AUX_ZWC_1B AUX_ZWC_1B
END

fi

OPTIONS="--simplify 0.2"
$MNGCMD aeolus_product_add $OPTIONS $( find /mnt/data/ALD_U_N_1B -name AE_OPER_ALD_U_N_1B\*DBL ) --collection ALD_U_N_1B --conflict=REPLACE --traceback
$MNGCMD aeolus_product_add $OPTIONS $( find /mnt/data/ALD_U_N_1B -name AE_OPER_ALD_U_N_1B\*DBL ) --collection ALD_U_N_1B --conflict=REPLACE --traceback
$MNGCMD aeolus_product_add $OPTIONS $( find /mnt/data/ALD_U_N_2A -name AE_OPER_ALD_U_N_2A\*DBL ) --collection ALD_U_N_2A --conflict=REPLACE --traceback
$MNGCMD aeolus_product_add $OPTIONS $( find /mnt/data/ALD_U_N_2B -name AE_OPER_ALD_U_N_2B\*DBL ) --collection ALD_U_N_2B --conflict=REPLACE --traceback
$MNGCMD aeolus_product_add $OPTIONS $( find /mnt/data/ALD_U_N_2C -name AE_OPER_ALD_U_N_2C\*DBL ) --collection ALD_U_N_2C --conflict=REPLACE --traceback

$MNGCMD aeolus_product_add $OPTIONS $( find /mnt/data/ALD_U_N_1B_public -name AE_OPER_ALD_U_N_1B\*DBL ) --collection ALD_U_N_1B_public --conflict=REPLACE --traceback
$MNGCMD aeolus_product_add $OPTIONS $( find /mnt/data/ALD_U_N_2B_public -name AE_OPER_ALD_U_N_2B\*DBL ) --collection ALD_U_N_2B_public --conflict=REPLACE --traceback
$MNGCMD aeolus_product_add $OPTIONS $( find /mnt/data/ALD_U_N_2C_public -name AE_OPER_ALD_U_N_2C\*DBL ) --collection ALD_U_N_2C_publid --conflict=REPLACE --traceback

$MNGCMD aeolus_product_add $OPTIONS $( find /mnt/data -name AE_\*_ISR_\*EEF ) --collection AUX_ISR_1B --conflict=REPLACE --traceback
$MNGCMD aeolus_product_add $OPTIONS $( find /mnt/data -name AE_\*_MRC_\*EEF ) --collection AUX_MRC_1B --conflict=REPLACE --traceback
$MNGCMD aeolus_product_add $OPTIONS $( find /mnt/data -name AE_\*_RRC_\*EEF ) --collection AUX_RRC_1B --conflict=REPLACE --traceback
$MNGCMD aeolus_product_add $OPTIONS $( find /mnt/data -name AE_\*_ZWC_\*EEF ) --collection AUX_ZWC_1B --conflict=REPLACE --traceback
$MNGCMD aeolus_product_add $OPTIONS $( find /mnt/data -name AE_\*_MET_\*DBL ) --collection AUX_MET_12 --conflict=REPLACE --traceback

while read MONTH FILENAME
do
    $MNGCMD aeolus_albedo_register -r 2000-2020 -m $MONTH -c ADAM_albedo -f $FILENAME
done << END
1 /mnt/data/Albedo_maps/SDR_jan.nc
2 /mnt/data/Albedo_maps/SDR_feb.nc
3 /mnt/data/Albedo_maps/SDR_mar.nc
4 /mnt/data/Albedo_maps/SDR_apr.nc
5 /mnt/data/Albedo_maps/SDR_may.nc
6 /mnt/data/Albedo_maps/SDR_jun.nc
7 /mnt/data/Albedo_maps/SDR_jul.nc
8 /mnt/data/Albedo_maps/SDR_aug.nc
9 /mnt/data/Albedo_maps/SDR_sep.nc
10 /mnt/data/Albedo_maps/SDR_oct.nc
11 /mnt/data/Albedo_maps/SDR_nov.nc
12 /mnt/data/Albedo_maps/SDR_dec.nc
END
