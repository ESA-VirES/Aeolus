
#!/bin/bash

sudo python /var/www/vires/eoxs/manage.py eoxs_rangetype_load -i /usr/local/aeolus/aeolus/data/range_types.json

sudo python /var/www/vires/eoxs/manage.py aeolus_collection_create -i ALD_U_N_1B -r ALD_U_N_1B
sudo python /var/www/vires/eoxs/manage.py aeolus_collection_create -i ALD_U_N_2A -r ALD_U_N_2A
sudo python /var/www/vires/eoxs/manage.py aeolus_collection_create -i ALD_U_N_2B -r ALD_U_N_2B
sudo python /var/www/vires/eoxs/manage.py aeolus_collection_create -i ALD_U_N_2C -r ALD_U_N_2C
sudo python /var/www/vires/eoxs/manage.py aeolus_collection_create -i AUX_MRC_1B -r AUX_MRC_1B
sudo python /var/www/vires/eoxs/manage.py aeolus_collection_create -i AUX_RRC_1B -r AUX_RRC_1B
sudo python /var/www/vires/eoxs/manage.py aeolus_collection_create -i AUX_ISR_1B -r AUX_ISR_1B
sudo python /var/www/vires/eoxs/manage.py aeolus_collection_create -i AUX_ZWC_1B -r AUX_ZWC_1B
sudo python /var/www/vires/eoxs/manage.py aeolus_collection_create -i AUX_MET_12 -r AUX_MET_12

find /mnt/data/ALD_U_N_1B/ -type f -iname "*.DBL" -exec sudo python /var/www/vires/eoxs/manage.py aeolus_product_add {} --collection ALD_U_N_1B --conflict=REPLACE \;
find /mnt/data/ALD_U_N_2A/ -type f -iname "*.DBL" -exec sudo python /var/www/vires/eoxs/manage.py aeolus_product_add {} --collection ALD_U_N_2A --conflict=REPLACE \;
find /mnt/data/ALD_U_N_2B/ -type f -iname "*.DBL" -exec sudo python /var/www/vires/eoxs/manage.py aeolus_product_add {} --collection ALD_U_N_2B --conflict=REPLACE \;
find /mnt/data/ALD_U_N_2C/ -type f -iname "*.DBL" -exec sudo python /var/www/vires/eoxs/manage.py aeolus_product_add {} --collection ALD_U_N_2C --conflict=REPLACE \;
find /mnt/data/AUX_MRC_1B/ -type f -iname "*.EEF" -exec sudo python /var/www/vires/eoxs/manage.py aeolus_product_add {} --collection AUX_MRC_1B --conflict=REPLACE \;
find /mnt/data/AUX_RRC_1B/ -type f -iname "*.EEF" -exec sudo python /var/www/vires/eoxs/manage.py aeolus_product_add {} --collection AUX_RRC_1B --conflict=REPLACE \;
find /mnt/data/AUX_ISR_1B/ -type f -iname "*.EEF" -exec sudo python /var/www/vires/eoxs/manage.py aeolus_product_add {} --collection AUX_ISR_1B --conflict=REPLACE \;
find /mnt/data/AUX_ZWC_1B/ -type f -iname "*.EEF" -exec sudo python /var/www/vires/eoxs/manage.py aeolus_product_add {} --collection AUX_ZWC_1B --conflict=REPLACE \;
find /mnt/data/AUX_MET_12/ -type f -iname "*.DBL" -exec sudo python /var/www/vires/eoxs/manage.py aeolus_product_add {} --collection AUX_MET_12 --conflict=REPLACE \;



sudo python /var/www/vires/eoxs/manage.py eoxs_collection_create -i ADAM_albedo
for i in {1..12};do sudo python /var/www/vires/eoxs/manage.py aeolus_albedo_register -f /mnt/data/Albedo_maps/SDR_${i}.nc -m ${i} -y 2003 -c ADAM_albedo --conflict=REPLACE;done
for i in {1..12};do sudo python /var/www/vires/eoxs/manage.py aeolus_albedo_register -f /mnt/data/Albedo_maps/SDR_${i}.nc -m ${i} -y 2004 -c ADAM_albedo --conflict=REPLACE;done
for i in {1..12};do sudo python /var/www/vires/eoxs/manage.py aeolus_albedo_register -f /mnt/data/Albedo_maps/SDR_${i}.nc -m ${i} -y 2005 -c ADAM_albedo --conflict=REPLACE;done
for i in {1..12};do sudo python /var/www/vires/eoxs/manage.py aeolus_albedo_register -f /mnt/data/Albedo_maps/SDR_${i}.nc -m ${i} -y 2005 -c ADAM_albedo --conflict=REPLACE;done
for i in {1..12};do sudo python /var/www/vires/eoxs/manage.py aeolus_albedo_register -f /mnt/data/Albedo_maps/SDR_${i}.nc -m ${i} -y 2006 -c ADAM_albedo --conflict=REPLACE;done
for i in {1..12};do sudo python /var/www/vires/eoxs/manage.py aeolus_albedo_register -f /mnt/data/Albedo_maps/SDR_${i}.nc -m ${i} -y 2007 -c ADAM_albedo --conflict=REPLACE;done
for i in {1..12};do sudo python /var/www/vires/eoxs/manage.py aeolus_albedo_register -f /mnt/data/Albedo_maps/SDR_${i}.nc -m ${i} -y 2008 -c ADAM_albedo --conflict=REPLACE;done
for i in {1..12};do sudo python /var/www/vires/eoxs/manage.py aeolus_albedo_register -f /mnt/data/Albedo_maps/SDR_${i}.nc -m ${i} -y 2009 -c ADAM_albedo --conflict=REPLACE;done
for i in {1..12};do sudo python /var/www/vires/eoxs/manage.py aeolus_albedo_register -f /mnt/data/Albedo_maps/SDR_${i}.nc -m ${i} -y 2010 -c ADAM_albedo --conflict=REPLACE;done
for i in {1..12};do sudo python /var/www/vires/eoxs/manage.py aeolus_albedo_register -f /mnt/data/Albedo_maps/SDR_${i}.nc -m ${i} -y 2011 -c ADAM_albedo --conflict=REPLACE;done
for i in {1..12};do sudo python /var/www/vires/eoxs/manage.py aeolus_albedo_register -f /mnt/data/Albedo_maps/SDR_${i}.nc -m ${i} -y 2012 -c ADAM_albedo --conflict=REPLACE;done
for i in {1..12};do sudo python /var/www/vires/eoxs/manage.py aeolus_albedo_register -f /mnt/data/Albedo_maps/SDR_${i}.nc -m ${i} -y 2013 -c ADAM_albedo --conflict=REPLACE;done
for i in {1..12};do sudo python /var/www/vires/eoxs/manage.py aeolus_albedo_register -f /mnt/data/Albedo_maps/SDR_${i}.nc -m ${i} -y 2014 -c ADAM_albedo --conflict=REPLACE;done
for i in {1..12};do sudo python /var/www/vires/eoxs/manage.py aeolus_albedo_register -f /mnt/data/Albedo_maps/SDR_${i}.nc -m ${i} -y 2015 -c ADAM_albedo --conflict=REPLACE;done
for i in {1..12};do sudo python /var/www/vires/eoxs/manage.py aeolus_albedo_register -f /mnt/data/Albedo_maps/SDR_${i}.nc -m ${i} -y 2016 -c ADAM_albedo --conflict=REPLACE;done
for i in {1..12};do sudo python /var/www/vires/eoxs/manage.py aeolus_albedo_register -f /mnt/data/Albedo_maps/SDR_${i}.nc -m ${i} -y 2017 -c ADAM_albedo --conflict=REPLACE;done
for i in {1..12};do sudo python /var/www/vires/eoxs/manage.py aeolus_albedo_register -f /mnt/data/Albedo_maps/SDR_${i}.nc -m ${i} -y 2018 -c ADAM_albedo --conflict=REPLACE;done
for i in {1..12};do sudo python /var/www/vires/eoxs/manage.py aeolus_albedo_register -f /mnt/data/Albedo_maps/SDR_${i}.nc -m ${i} -y 2019 -c ADAM_albedo --conflict=REPLACE;done
for i in {1..12};do sudo python /var/www/vires/eoxs/manage.py aeolus_albedo_register -f /mnt/data/Albedo_maps/SDR_${i}.nc -m ${i} -y 2020 -c ADAM_albedo --conflict=REPLACE;done