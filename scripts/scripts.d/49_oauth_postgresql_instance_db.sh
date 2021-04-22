#!/bin/sh
#-------------------------------------------------------------------------------
#
# Purpose: PostgreSQL instance database creation
# Author(s): Martin Paces <martin.paces@eox.at>
#-------------------------------------------------------------------------------
# Copyright (C) 2019 EOX IT Services GmbH

# NOTE: To drop the existing database remove the db.conf file in the scripts directory.

. `dirname $0`/../lib_logging.sh
. `dirname $0`/../lib_postgres.sh
. `dirname $0`/../lib_oauth.sh

DB_CONF="`dirname $0`/../db_oauth.conf"

info "Creating OAuth instance's Postgres database ..."

# check if the database is already configured and if so skip the creation ...
load_db_conf "$DB_CONF"

if [ -n "$DBENGINE" -a "$DBNAME" ]
then
    info "Reusing configured existing database $DBNAME ($DBENGINE) rather then creating a new one."
    exit 0
fi

# set and save new database configuration ...
set_instance_variables

DBENGINE="django.db.backends.postgresql_psycopg2"
DBNAME="oauth_${INSTANCE}"
DBUSER="oauth_admin_${INSTANCE}"
DBPASSWD="${INSTANCE}_admin_admin_`head -c 24 < /dev/urandom | base64 | tr '/' '_'`"
DBHOST=""
DBPORT=""
PG_HBA="`psql -qA -c "SHOW hba_file;" | grep -m 1 "^/"`"

save_db_conf "$DB_CONF"

# deleting any previously existing database
psql -q -c "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = '$DBNAME' AND pid <> pg_backend_pid() ;" >/dev/null 2>&1 \
  && psql -q -c "DROP DATABASE $DBNAME ;" 2>/dev/null \
  && warn " The already existing database '$DBNAME' was removed." || /bin/true

# deleting any previously existing user
TMP=`psql -tAc "SELECT 1 FROM pg_roles WHERE rolname='$DBUSER' ;"`
if [ 1 == "$TMP" ]
then
    psql -q -c "DROP USER $DBUSER ;"
    warn " The already existing database user '$DBUSER' was removed"
fi

# create new users
psql -q -c "CREATE USER $DBUSER WITH ENCRYPTED PASSWORD '$DBPASSWD' NOSUPERUSER NOCREATEDB NOCREATEROLE ;"
psql -q -c "CREATE DATABASE $DBNAME WITH OWNER $DBUSER ENCODING 'UTF-8' ;"

# make the DB accessible for the dedicated user only
{ sudo -u postgres ex "$PG_HBA" || /bin/true ; } <<END
g/# OAuth instance:.*\/$INSTANCE/d
g/^\s*local\s*$DBNAME/d
/#\s*TYPE\s*DATABASE\s*USER\s*.*ADDRESS\s*METHOD/a
# OAuth instance: $INSTROOT/$INSTANCE
local	$DBNAME	$DBUSER	md5
local	$DBNAME	all	reject
.
wq
END
psql -q -c "SELECT pg_reload_conf();" >/dev/null
