#!/bin/sh
#-------------------------------------------------------------------------------
#
# Purpose: PostgreSQL and PostGIS installation.
# Author(s): Martin Paces <martin.paces@eox.at>
#-------------------------------------------------------------------------------
# Copyright (C) 2015 EOX IT Services GmbH

. `dirname $0`/../lib_logging.sh

info "Installing PosgreSQL RDBMS ... "

PG_DATA_DIR_DEFAULT="/var/lib/pgsql/9.5/data"
PG_DATA_DIR="${VIRES_PGDATA_DIR:-$PG_DATA_DIR_DEFAULT}"
#======================================================================



# STEP 1: INSTALL RPM PACKAGES
yum --assumeyes install postgresql95 postgresql95-server postgis2_95 postgresql10-libs python3-psycopg2
# yum install --assumeyes postgresql10 postgresql10-server postgis2_10 python3-psycopg2

# STEP 2: Shut-down the postgress if already installed and running.
if [ -n "`systemctl | grep postgresql-9.5.service`" ]
then
    info "Stopping running PostgreSQL server ..."
    systemctl stop postgresql-9.5.service
fi

# STEP 3: CONFIGURE THE STORAGE DIRECTORY
info "Removing the existing PosgreSQL DB cluster ..."
[ ! -d "$PG_DATA_DIR_DEFAULT" ] || rm -fR "$PG_DATA_DIR_DEFAULT"
[ ! -d "$PG_DATA_DIR" ] || rm -fR "$PG_DATA_DIR"

# info "Setting the PostgreSQL data location to: $PG_DATA_DIR"
# cat >/etc/systemd/system/postgresql.service <<END
# .include /lib/systemd/system/postgresql-9.5.service
# [Service]
# Environment=PGDATA=$PG_DATA_DIR
# END
# systemctl daemon-reload

# STEP 4: INIT THE DB AND START THE SERVICE
info "New database initialisation ... "

/usr/pgsql-9.5/bin/postgresql95-setup initdb
systemctl disable postgresql-9.5.service # DO NOT REMOVE!
systemctl enable postgresql-9.5.service
systemctl start postgresql-9.5.service
systemctl status postgresql-9.5.service


# ls -lisah "$PG_DATA_DIR" || true

# /usr/pgsql-10/bin/postgresql-10-setup initdb
# systemctl disable postgresql-10.service # DO NOT REMOVE!
# systemctl enable postgresql-10.service
# systemctl start postgresql-10.service
# systemctl status postgresql-10.service

# STEP 5: SETUP POSTGIS DATABASE TEMPLATE
if [ -z "`sudo -u postgres psql --list | grep template_postgis`" ]
then
    sudo -u postgres createdb template_postgis
    #sudo -u postgres createlang plpgsql template_postgis

    # PG_SHARE=/usr/share/pgsql
    # POSTGIS_SQL="postgis-64.sql"
    # [ -f "$PG_SHARE/contrib/$POSTGIS_SQL" ] || POSTGIS_SQL="postgis.sql"
    # sudo -u postgres psql -q -d template_postgis -f "$PG_SHARE/contrib/$POSTGIS_SQL"
    # sudo -u postgres psql -q -d template_postgis -f "$PG_SHARE/contrib/spatial_ref_sys.sql"
    # sudo -u postgres psql -q -d template_postgis -c "GRANT ALL ON geometry_columns TO PUBLIC;"
    # sudo -u postgres psql -q -d template_postgis -c "GRANT ALL ON geography_columns TO PUBLIC;"
    # sudo -u postgres psql -q -d template_postgis -c "GRANT ALL ON spatial_ref_sys TO PUBLIC;"
fi
