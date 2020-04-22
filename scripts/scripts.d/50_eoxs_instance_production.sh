#!/bin/sh
#-------------------------------------------------------------------------------
#
# Purpose: EOxServer instance configuration
# Author(s): Martin Paces <martin.paces@eox.at>
#-------------------------------------------------------------------------------
# Copyright (C) 2015 EOX IT Services GmbH

. `dirname $0`/../lib_logging.sh
. `dirname $0`/../lib_apache.sh

info "Configuring EOxServer instance ... "

# NOTE: Don't use commands starting with 'sudo -u "$VIRES_USER"' as they
#       don't play nice with fabric and virtualenv.

# Configuration switches - all default to YES
CONFIGURE_AEOLUS=${CONFIGURE_AEOLUS:-YES}
CONFIGURE_ALLAUTH=${CONFIGURE_ALLAUTH:-YES}
CONFIGURE_WPSASYNC=${CONFIGURE_WPSASYNC:-YES}

# NOTE: Multiple EOxServer instances are not foreseen in VIRES.

[ -z "$VIRES_HOSTNAME" ] && error "Missing the required VIRES_HOSTNAME variable!"
[ -z "$VIRES_HOSTNAME_INTERNAL" ] && error "Missing the required VIRES_HOSTNAME_INTERNAL variable!"
[ -z "$VIRES_IP_ADDRESS" ] && error "Missing the required VIRES_IP_ADDRESS variable!"
[ -z "$VIRES_SERVER_HOME" ] && error "Missing the required VIRES_SERVER_HOME variable!"
[ -z "$VIRES_USER" ] && error "Missing the required VIRES_USER variable!"
[ -z "$VIRES_GROUP" ] && error "Missing the required VIRES_GROUP variable!"
[ -z "$VIRES_LOGDIR" ] && error "Missing the required VIRES_LOGDIR variable!"
[ -z "$VIRES_TMPDIR" ] && error "Missing the required VIRES_TMPDIR variable!"
[ -z "$VIRES_WPS_SERVICE_NAME" ] && error "Missing the required VIRES_WPS_SERVICE_NAME variable!"
[ -z "$VIRES_WPS_TEMP_DIR" ] && error "Missing the required VIRES_WPS_TEMP_DIR variable!"
[ -z "$VIRES_WPS_PERM_DIR" ] && error "Missing the required VIRES_WPS_PERM_DIR variable!"
[ -z "$VIRES_WPS_TASK_DIR" ] && error "Missing the required VIRES_WPS_TASK_DIR variable!"
[ -z "$VIRES_WPS_URL_PATH" ] && error "Missing the required VIRES_WPS_URL_PATH variable!"
[ -z "$VIRES_WPS_SOCKET" ] && error "Missing the required VIRES_WPS_SOCKET variable!"
[ -z "$VIRES_WPS_NPROC" ] && error "Missing the required VIRES_WPS_NPROC variable!"
[ -z "$VIRES_WPS_MAX_JOBS" ] && error "Missing the required VIRES_WPS_MAX_JOBS variable!"
[ -z "$DBNAME" ] && error "Missing the required DBNAME variable!"
[ -z "$DBUSER" ] && error "Missing the required DBUSER variable!"
[ -z "$DBPASSWD" ] && error "Missing the required DBPASSWD variable!"
[ -z "$DBHOST" ] && error "Missing the required DBHOST variable!"
[ -z "$DBPORT" ] && error "Missing the required DBPORT variable!"
[ -z "$SMTP_HOSTNAME" ] && error "Missing the required SMTP_HOSTNAME variable!"
[ -z "$SMTP_DEFAULT_SENDER" ] && error "Missing the required SMTP_DEFAULT_SENDER variable!"

HOSTNAME="$VIRES_HOSTNAME"
INSTANCE="`basename "$VIRES_SERVER_HOME"`"
INSTROOT="`dirname "$VIRES_SERVER_HOME"`"

SETTINGS="${INSTROOT}/${INSTANCE}/${INSTANCE}/settings.py"
WSGI_FILE="${INSTROOT}/${INSTANCE}/${INSTANCE}/wsgi.py"
URLS="${INSTROOT}/${INSTANCE}/${INSTANCE}/urls.py"
FIXTURES_DIR="${INSTROOT}/${INSTANCE}/${INSTANCE}/data/fixtures"
INSTSTAT_DIR="${INSTROOT}/${INSTANCE}/${INSTANCE}/static"
USER_UPLOAD_DIR="${INSTROOT}/user_uploads"
WSGI="${INSTROOT}/${INSTANCE}/${INSTANCE}/wsgi.py"
MNGCMD="${INSTROOT}/${INSTANCE}/manage.py"
#BASE_URL_PATH="/${INSTANCE}" # DO NOT USE THE TRAILING SLASH!!!
BASE_URL_PATH=""
STATIC_URL_PATH="/${INSTANCE}_static" # DO NOT USE THE TRAILING SLASH!!!

DBENGINE="django.contrib.gis.db.backends.postgis"
DBNAME=$DBNAME
DBUSER=$DBUSER
DBPASSWD=$DBPASSWD
DBHOST=$DBHOST
DBPORT=$DBPORT

SMTP_USE_TLS=${SMTP_USE_TLS:-YES}
SMTP_HOSTNAME="$SMTP_HOSTNAME"
SMTP_PORT=${SMTP_PORT:-25}
SMTP_DEFAULT_SENDER="$SMTP_DEFAULT_SENDER"

EOXSLOG="${VIRES_LOGDIR}/eoxserver/${INSTANCE}/eoxserver.log"
ACCESSLOG="${VIRES_LOGDIR}/eoxserver/${INSTANCE}/access.log"
EOXSCONF="${INSTROOT}/${INSTANCE}/${INSTANCE}/conf/eoxserver.conf"
EOXSURL="${VIRES_URL_ROOT}${BASE_URL_PATH}/ows?"
EOXSMAXSIZE="20480"
EOXSMAXPAGE="200"

# process group label
EOXS_WSGI_PROCESS_GROUP=${EOXS_WSGI_PROCESS_GROUP:-eoxs_ows}

#-------------------------------------------------------------------------------
# STEP 1: CREATE INSTANCE if not already present

info "Creating EOxServer instance '${INSTANCE}' in '$INSTROOT/$INSTANCE' ..."


# check availability of the EOxServer
#HINT: Does python complain that the apparently installed EOxServer
#      package is not available? First check that the 'eoxserver' tree is
#      readable by anyone. (E.g. in case of read protected home directory when
#      the development setup is used.)
python3 -c 'import eoxserver' || {
    error "EOxServer does not seem to be installed!"
    exit 1
}

if [ ! -d "$INSTROOT/$INSTANCE" ]
then
    sudo -u "$VIRES_USER" mkdir -p "$INSTROOT/$INSTANCE"
    sudo -u "$VIRES_USER" /usr/local/bin/eoxserver-instance.py "$INSTANCE" "$INSTROOT/$INSTANCE"
fi

#-------------------------------------------------------------------------------
# STEP 2: CREATE POSTGRES DATABASE

#Removed for production

#-------------------------------------------------------------------------------
# STEP 3: SETUP DJANGO DB BACKEND

info "Connecting DB backend for '${INSTANCE}' in '${SETTINGS}' ..."

{ ex "$SETTINGS" || /bin/true ; } <<END
/^# DATABASE - BEGIN/,/^# DATABASE - END/d
wq
END

# extending the EOxServer settings.py
ex "$SETTINGS" <<END
/^db_type\s*=/
a
# DATABASE - BEGIN - Do not edit or remove this line!
db_type = None
DATABASES = {
    'default': {
        'ENGINE': 'django.contrib.gis.db.backends.postgis',
        'HOST': '$DBHOST',
        'PORT': '$DBPORT',
        'NAME': '$DBNAME',
        'USER': '$DBUSER',
        'PASSWORD': '$DBPASSWD',
    }
}
# DATABASE - END - Do not edit or remove this line!
.
wq
END


#-------------------------------------------------------------------------------
# STEP 4.x: GUNICORN WEB SERVER INTEGRATION


info "Creating gunicorn service"

echo "[Unit]
Description=gunicorn daemon
After=network.target

[Service]
User=$VIRES_USER
Group=$VIRES_GROUP
WorkingDirectory=$VIRES_SERVER_HOME
ExecStart=/usr/local/bin/gunicorn --workers $EOXS_WSGI_NPROC --timeout 600 --bind 127.0.0.1:8012 --chdir ${INSTROOT}/${INSTANCE} ${INSTANCE}.wsgi:application

[Install]
WantedBy=multi-user.target
" > /etc/systemd/system/gunicorn.service

systemctl daemon-reload

systemctl enable "gunicorn.service"
systemctl restart "gunicorn.service"
systemctl status "gunicorn.service"

#-------------------------------------------------------------------------------
# STEP 4: APACHE WEB SERVER INTEGRATION

info "Mapping EOxServer instance '${INSTANCE}' to URL path '${INSTANCE}' ..."

# locate proper configuration file (see also apache configuration)
_PORT=443 # HTTPS only
[ -z `locate_apache_conf $_PORT $HOSTNAME` ] && error "Failed to locate Apache virtual host $HOSTNAME:$_PORT configuration!"
{
    locate_apache_conf $_PORT $HOSTNAME
    locate_apache_conf $_PORT $VIRES_HOSTNAME_INTERNAL
} | while read CONF
do
    { ex "$CONF" || /bin/true ; } <<END
/EOXS00_BEGIN/,/EOXS00_END/de
/^[ 	]*<\/VirtualHost>/i
    # EOXS00_BEGIN - EOxServer instance - Do not edit or remove this line!

    # EOxServer instance configured by the automatic installation script

    # static content
    Alias "$STATIC_URL_PATH" "$INSTSTAT_DIR"
    ProxyPass "$STATIC_URL_PATH" !
    <Directory "$INSTSTAT_DIR">
        Options -MultiViews +FollowSymLinks
        Header set Access-Control-Allow-Origin "*"
    </Directory>

    ProxyPass "/" "http://127.0.0.1:8012/" connectiontimeout=60 timeout=600

    # EOXS00_END - EOxServer instance - Do not edit or remove this line!
.
wq
END
done

# enable virtualenv in wsgi.py if necessary
if [ -n "$ENABLE_VIRTUALENV" ]
then
    info "Enabling virtualenv ..."
    { ex "$WSGI_FILE" || /bin/true ; } <<END
/^# Start load virtualenv$/,/^# End load virtualenv$/d
/^import sys/a
# Start load virtualenv
import site
# Add the site-packages of the chosen virtualenv to work with
site.addsitedir("${ENABLE_VIRTUALENV}/local/lib/python2.7/site-packages")
# End load virtualenv
.
/^# Start activate virtualenv$/,/^# End activate virtualenv$/d
/^os.environ/a
# Start activate virtualenv
activate_env=os.path.expanduser("${ENABLE_VIRTUALENV}/bin/activate_this.py")
exec(open(activate_env).read(), dict(__file__=activate_env))

# End activate virtualenv
.
wq
END
fi

#-------------------------------------------------------------------------------
# STEP 5: EOXSERVER CONFIGURATION

# remove any previous configuration blocks
{ ex "$EOXSCONF" || /bin/true ; } <<END
/^# WMS_SUPPORTED_CRS - BEGIN/,/^# WMS_SUPPORTED_CRS - END/d
/^# WCS_SUPPORTED_CRS - BEGIN/,/^# WCS_SUPPORTED_CRS - END/d
wq
END

# set the new configuration
ex "$EOXSCONF" <<END
/^[	 ]*http_service_url[	 ]*=/s;\(^[	 ]*http_service_url[	 ]*=\).*;\1${EOXSURL};
g/^#.*supported_crs/,/^$/d
/\[services\.ows\.wms\]/a
# WMS_SUPPORTED_CRS - BEGIN - Do not edit or remove this line!
supported_crs=4326,3857,#900913, # WGS84, WGS84 Pseudo-Mercator, and GoogleEarth spherical mercator
        3035, #ETRS89
        2154, # RGF93 / Lambert-93
        32601,32602,32603,32604,32605,32606,32607,32608,32609,32610, # WGS84 UTM  1N-10N
        32611,32612,32613,32614,32615,32616,32617,32618,32619,32620, # WGS84 UTM 11N-20N
        32621,32622,32623,32624,32625,32626,32627,32628,32629,32630, # WGS84 UTM 21N-30N
        32631,32632,32633,32634,32635,32636,32637,32638,32639,32640, # WGS84 UTM 31N-40N
        32641,32642,32643,32644,32645,32646,32647,32648,32649,32650, # WGS84 UTM 41N-50N
        32651,32652,32653,32654,32655,32656,32657,32658,32659,32660, # WGS84 UTM 51N-60N
        32701,32702,32703,32704,32705,32706,32707,32708,32709,32710, # WGS84 UTM  1S-10S
        32711,32712,32713,32714,32715,32716,32717,32718,32719,32720, # WGS84 UTM 11S-20S
        32721,32722,32723,32724,32725,32726,32727,32728,32729,32730, # WGS84 UTM 21S-30S
        32731,32732,32733,32734,32735,32736,32737,32738,32739,32740, # WGS84 UTM 31S-40S
        32741,32742,32743,32744,32745,32746,32747,32748,32749,32750, # WGS84 UTM 41S-50S
        32751,32752,32753,32754,32755,32756,32757,32758,32759,32760  # WGS84 UTM 51S-60S
        #32661,32761, # WGS84 UPS-N and UPS-S
# WMS_SUPPORTED_CRS - END - Do not edit or remove this line!
.
/\[services\.ows\.wcs\]/a
# WCS_SUPPORTED_CRS - BEGIN - Do not edit or remove this line!
supported_crs=4326,3857,#900913, # WGS84, WGS84 Pseudo-Mercator, and GoogleEarth spherical mercator
        3035, #ETRS89
        2154, # RGF93 / Lambert-93
        32601,32602,32603,32604,32605,32606,32607,32608,32609,32610, # WGS84 UTM  1N-10N
        32611,32612,32613,32614,32615,32616,32617,32618,32619,32620, # WGS84 UTM 11N-20N
        32621,32622,32623,32624,32625,32626,32627,32628,32629,32630, # WGS84 UTM 21N-30N
        32631,32632,32633,32634,32635,32636,32637,32638,32639,32640, # WGS84 UTM 31N-40N
        32641,32642,32643,32644,32645,32646,32647,32648,32649,32650, # WGS84 UTM 41N-50N
        32651,32652,32653,32654,32655,32656,32657,32658,32659,32660, # WGS84 UTM 51N-60N
        32701,32702,32703,32704,32705,32706,32707,32708,32709,32710, # WGS84 UTM  1S-10S
        32711,32712,32713,32714,32715,32716,32717,32718,32719,32720, # WGS84 UTM 11S-20S
        32721,32722,32723,32724,32725,32726,32727,32728,32729,32730, # WGS84 UTM 21S-30S
        32731,32732,32733,32734,32735,32736,32737,32738,32739,32740, # WGS84 UTM 31S-40S
        32741,32742,32743,32744,32745,32746,32747,32748,32749,32750, # WGS84 UTM 41S-50S
        32751,32752,32753,32754,32755,32756,32757,32758,32759,32760  # WGS84 UTM 51S-60S
        #32661,32761, # WGS84 UPS-N and UPS-S
# WCS_SUPPORTED_CRS - END - Do not edit or remove this line!
.
wq
END

#set the limits
ex "$EOXSCONF" <<END
g/^[ 	#]*maxsize[ 	]/d
/\[services\.ows\.wcs\]/a
maxsize = $EOXSMAXSIZE
.
/^[	 ]*source_to_native_format_map[	 ]*=/s#\(^[	 ]*source_to_native_format_map[	 ]*=\).*#\1application/x-esa-envisat,application/x-esa-envisat#
/^[	 ]*paging_count_default[	 ]*=/s/\(^[	 ]*paging_count_default[	 ]*=\).*/\1${EOXSMAXPAGE}/

wq
END

# set the allowed hosts
# NOTE: Set the hostname manually if needed.
#TODO add aeolus.services and env.host to ALLOWED_HOSTS
ex "$SETTINGS" <<END
1,\$s/\(^ALLOWED_HOSTS\s*=\s*\).*/\1['${VIRES_HOSTNAME_INTERNAL}','${VIRES_IP_ADDRESS}','${HOSTNAME}','aeolus.services','127.0.0.1','::1']/
wq
END

# set-up logging
ex "$SETTINGS" <<END
g/^DEBUG\s*=/s#\(^DEBUG\s*=\s*\).*#\1False#
g/^LOGGING\s*=/,/^}/d
i
LOGGING = {
    'version': 1,
    'disable_existing_loggers': True,
    'filters': {
        'require_debug_false': {
            '()': 'django.utils.log.RequireDebugFalse'
        },
        'request_filter': {
            # '()': 'django_requestlogging.logging_filters.RequestFilter'
        },
    },
    'formatters': {
        'default': {
            'format': '[%(asctime)s.%(msecs)03d] %(name)s %(levelname)s: %(message)s',
            'datefmt': '%Y-%m-%dT%H:%M:%S',
        },
        'access': {
            'format': '[%(asctime)s.%(msecs)03d] %(remote_addr)s %(username)s %(name)s %(levelname)s: %(message)s',
            'datefmt': '%Y-%m-%dT%H:%M:%S',
        },
    },
    'handlers': {
        'eoxserver_file': {
            'level': 'DEBUG',
            'class': 'logging.handlers.WatchedFileHandler',
            'filename': '${EOXSLOG}',
            'formatter': 'default',
            'filters': [],
        },
        'access_file': {
            'level': 'DEBUG',
            'class': 'logging.handlers.WatchedFileHandler',
            'filename': '${ACCESSLOG}',
            'formatter': 'access',
            'filters': ['request_filter'],
        },
        'stderr_stream': {
            'level': 'INFO',
            'class': 'logging.StreamHandler',
            'formatter': 'default',
            'filters': [],
        },
    },
    'loggers': {
        'eoxserver': {
            'handlers': ['eoxserver_file'],
            'level': 'DEBUG' if DEBUG else 'INFO',
            'propagate': False,
        },
        'access': {
            'handlers': ['access_file'],
            'level': 'DEBUG' if DEBUG else 'INFO',
            'propagate': False,
        },
        '': {
            'handlers': ['eoxserver_file'],
            'level': 'INFO' if DEBUG else 'WARNING',
            'propagate': False,
        },
    },
}
.
g/^\s*'eoxserver.resources.processes',/s/'eoxserver.resources.processes'/#&/
wq
END

# touch the logfile and set the right permissions
_create_log_file() {
    [ -d "`dirname "$1"`" ] || mkdir -p "`dirname "$1"`"
    touch "$1"
    chown "$VIRES_USER:$VIRES_GROUP" "$1"
    chmod 0664 "$1"
}
_create_log_file "$EOXSLOG"
_create_log_file "$ACCESSLOG"

#setup logrotate configuration
cat >"/etc/logrotate.d/aeolus_eoxserver_${INSTANCE}" <<END
$EOXSLOG {
    copytruncate
    weekly
    minsize 1M
    compress
    rotate 560
    missingok
}
$ACCESSLOG {
    copytruncate
    weekly
    minsize 1M
    compress
    rotate 560
    missingok
}
END

# create fixtures directory
mkdir -p "$FIXTURES_DIR"

#-------------------------------------------------------------------------------
# STEP 6: APPLICATION SPECIFIC SETTINGS

info "Application specific configuration ..."

# remove any previous configuration blocks
{ ex "$SETTINGS" || /bin/true ; } <<END
/^# AEOLUS APPS - BEGIN/,/^# AEOLUS APPS - END/d
/^# AEOLUS COMPONENTS - BEGIN/,/^# AEOLUS COMPONENTS - END/d
/^# AEOLUS PROCESSES - BEGIN/,/^# AEOLUS PROCESSES - END/d
/^# AEOLUS LOGGING - BEGIN/,/^# AEOLUS LOGGING - END/d
/^# WPSASYNC COMPONENTS - BEGIN/,/^# WPSASYNC COMPONENTS - END/d
/^# WPSASYNC LOGGING - BEGIN/,/^# WPSASYNC LOGGING - END/d
/^# ALLAUTH APPS - BEGIN/,/^# ALLAUTH APPS - END/d
/^# ALLAUTH MIDDLEWARE - BEGIN/,/^# ALLAUTH MIDDLEWARE - END/d
/^# ALLAUTH LOGGING - BEGIN/,/^# ALLAUTH LOGGING - END/d
/^# REQUESTLOGGING APPS - BEGIN/,/^# REQUESTLOGGING APPS - END/d
/^# REQUESTLOGGING MIDDLEWARE - BEGIN/,/^# REQUESTLOGGING MIDDLEWARE - END/d
/^# EMAIL_BACKEND - BEGIN/,/^# EMAIL_BACKEND - END/d
wq
END

{ ex "$URLS" || /bin/true ; } <<END
/^# AEOLUS URLS - BEGIN/,/^# AEOLUS URLS - END/d
/^# ALLAUTH URLS - BEGIN/,/^# ALLAUTH URLS - END/d
wq
END

{ ex "$EOXSCONF" || /bin/true ; } <<END
/^# WPSASYNC - BEGIN/,/^# WPSASYNC - END/d
wq
END

# configure the apps ...

if [ "$CONFIGURE_AEOLUS" != "YES" ]
then
    warn "AEOLUS specific configuration is disabled."
else
    info "AEOLUS specific configuration ..."

    # extending the EOxServer settings.py
    ex "$SETTINGS" <<END
/^INSTALLED_APPS\s*=/
/^)/
a
# AEOLUS APPS - BEGIN - Do not edit or remove this line!
INSTALLED_APPS += (
    'aeolus',
)
# AEOLUS APPS - END - Do not edit or remove this line!
.
/^COMPONENTS\s*=/
/^)/a
# AEOLUS PROCESSES - BEGIN - Do not edit or remove this line!
from eoxserver.services.ows.wps.config import DEFAULT_EOXS_PROCESSES
EOXS_PROCESSES = DEFAULT_EOXS_PROCESSES + [
    'aeolus.processes.aux.Level1BAUXISRExtract',
    'aeolus.processes.aux.Level1BAUXMRCExtract',
    'aeolus.processes.aux.Level1BAUXRRCExtract',
    'aeolus.processes.aux.Level1BAUXZWCExtract',
    'aeolus.processes.aux_met.AUXMET12Extract',
    'aeolus.processes.dsd.DSDExtract',
    'aeolus.processes.level_1b.Level1BExtract',
    'aeolus.processes.level_2a.Level2AExtract',
    'aeolus.processes.level_2b.Level2BExtract',
    'aeolus.processes.level_2c.Level2CExtract',
    'aeolus.processes.raw_download.RawDownloadProcess',
    'aeolus.processes.remove_job.RemoveJob',
    'aeolus.processes.list_jobs.ListJobs',
]
AEOLUS_OPTIMIZED_DIR = '/mnt/data/optimized'
EOXS_WMS_DIM_RANGES_SEPARATOR = ';'
EOXS_WMS_DIM_RANGE_SEPARATOR = ','
EOXS_ASYNC_BACKENDS = [
    'eoxs_wps_async.backend.WPSAsyncBackendBase',
]
# USER_UPLOAD_DIR = "${USER_UPLOAD_DIR}"
USER_UPLOAD_DIR = "/mnt/wps/user_uploads"

# required as EOxServer is now used behind a proxy
USE_X_FORWARDED_HOST = True

# AEOLUS PROCESSES - END - Do not edit or remove this line!
.
\$a
# AEOLUS LOGGING - BEGIN - Do not edit or remove this line!
LOGGING['loggers']['aeolus'] = {
    'handlers': ['eoxserver_file'],
    'level': 'DEBUG' if DEBUG else 'INFO',
    'propagate': False,
}
# AEOLUS LOGGING - END - Do not edit or remove this line!
.
wq
END


# Remove original url patterns
{ ex "$URLS" || /bin/true ; } <<END
$ a
# AEOLUS URLS - BEGIN - Do not edit or remove this line!

from aeolus.views import upload_user_file

urlpatterns += [
    re_path(r'^upload/$', upload_user_file),
]

# AEOLUS URLS - END - Do not edit or remove this line!
.
wq
END


fi # end of AEOLUS configuration


if [ "$CONFIGURE_ALLAUTH" != "YES" ]
then
    warn "ALLAUTH specific configuration is disabled."
else
    info "ALLAUTH specific configuration ..."

    # extending the EOxServer settings.py
    ex "$SETTINGS" <<END
/^INSTALLED_APPS\s*=/
/^)/
a
# ALLAUTH APPS - BEGIN - Do not edit or remove this line!
INSTALLED_APPS += (
    'eoxs_allauth',
    'allauth',
    'allauth.account',
    'allauth.socialaccount',
    #'allauth.socialaccount.providers.facebook',
    #'allauth.socialaccount.providers.twitter',
    #'allauth.socialaccount.providers.linkedin_oauth2',
    #'allauth.socialaccount.providers.google',
    #'allauth.socialaccount.providers.github',
    #'allauth.socialaccount.providers.dropbox_oauth2',
    'django_countries',
)


# ALLAUTH APPS - END - Do not edit or remove this line!
.
/^MIDDLEWARE\s*=/
/^)/a
# ALLAUTH MIDDLEWARE - BEGIN - Do not edit or remove this line!

# allauth specific middleware classes
MIDDLEWARE += [
    'eoxs_allauth.middleware.access_logging_middleware',
    'eoxs_allauth.middleware.inactive_user_logout_middleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    # SessionAuthenticationMiddleware is only available in django 1.7
    # 'django.contrib.auth.middleware.SessionAuthenticationMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
]

# VirES Specific middleware classes
MIDDLEWARE += [
    'django.middleware.gzip.GZipMiddleware'
]

AUTHENTICATION_BACKENDS = (
    # Needed to login by username in Django admin, regardless of allauth
    'django.contrib.auth.backends.ModelBackend',
    # allauth specific authentication methods, such as login by e-mail
    'allauth.account.auth_backends.AuthenticationBackend',
)

# Django allauth
SITE_ID = 1 # ID from django.contrib.sites
LOGIN_URL = "/accounts/login/"
LOGIN_REDIRECT_URL = "${BASE_URL_PATH:-/}"
ACCOUNT_AUTHENTICATION_METHOD = 'username_email'
ACCOUNT_EMAIL_REQUIRED = True
ACCOUNT_EMAIL_VERIFICATION = 'mandatory'
ACCOUNT_EMAIL_CONFIRMATION_EXPIRE_DAYS = 3
ACCOUNT_UNIQUE_EMAIL = True
#ACCOUNT_EMAIL_SUBJECT_PREFIX = [aeolus.services]
ACCOUNT_CONFIRM_EMAIL_ON_GET = True
ACCOUNT_LOGIN_ON_EMAIL_CONFIRMATION = True
ACCOUNT_DEFAULT_HTTP_PROTOCOL = 'https'
ACCOUNT_PASSWORD_MIN_LENGTH = 8
ACCOUNT_LOGIN_ON_PASSWORD_RESET = True
ACCOUNT_USERNAME_REQUIRED = True
SOCIALACCOUNT_AUTO_SIGNUP = False
SOCIALACCOUNT_EMAIL_REQUIRED = True
SOCIALACCOUNT_EMAIL_VERIFICATION = 'mandatory'
SOCIALACCOUNT_QUERY_EMAIL = True
ACCOUNT_SIGNUP_FORM_CLASS = 'eoxs_allauth.forms.ESASignupForm'

TEMPLATE_CONTEXT_PROCESSORS = (
    # Required by allauth template tags
    'django.core.context_processors.request',
    'django.contrib.auth.context_processors.auth',
    'django.contrib.messages.context_processors.messages',
)

# EOxServer AllAuth
PROFILE_UPDATE_SUCCESS_URL = "/accounts/profile/"
PROFILE_UPDATE_SUCCESS_MESSAGE = "Profile was updated successfully."
PROFILE_UPDATE_TEMPLATE = "account/userprofile_update_form.html"
WORKSPACE_TEMPLATE="vires/workspace.html"
OWS11_EXCEPTION_XSL = join(STATIC_URL, "other/owserrorstyle.xsl")

# Disabled registration
REGISTRATION_OPEN = True
ACCOUNT_ADAPTER = 'eoxs_allauth.adapter.NoNewUsersAccountAdapter'

# ALLAUTH MIDDLEWARE - END - Do not edit or remove this line!
.
\$a
# ALLAUTH LOGGING - BEGIN - Do not edit or remove this line!
LOGGING['loggers'].update({
    'eoxs_allauth': {
        'handlers': ['access_file'],
        'level': 'DEBUG' if DEBUG else 'INFO',
        'propagate': False,
    },
    'django.request': {
        'handlers': ['access_file'],
        'level': 'DEBUG' if DEBUG else 'INFO',
        'propagate': False,
    },
})
# ALLAUTH LOGGING - END - Do not edit or remove this line!
.
wq
END

# Remove original url patterns
{ ex "$URLS" || /bin/true ; } <<END
/^urlpatterns = patterns(/,/^)/s/^\\s/# /
wq
END

    # extending the EOxServer settings.py
    ex "$URLS" <<END
$ a
# ALLAUTH URLS - BEGIN - Do not edit or remove this line!
import eoxs_allauth.views
from django.views.generic import TemplateView

urlpatterns += [
    re_path(r'^$', eoxs_allauth.views.workspace),
    re_path(r'^ows$', eoxs_allauth.views.wrapped_ows),
    re_path(r'^accounts/', include('eoxs_allauth.urls')),
    re_path(
        r'^accounts/faq$',
        TemplateView.as_view(template_name='account/faq.html'),
        name='faq'
    ),
    re_path(
        r'^accounts/datatc$',
        TemplateView.as_view(template_name='account/datatc.html'),
        name='datatc'
    ),
    re_path(
        r'^accounts/servicetc$',
         TemplateView.as_view(template_name='account/servicetc.html'),
        name='servicetc'
    ),
    re_path(
        r'^accounts/privacy_notice$',
        TemplateView.as_view(template_name='account/privacy_notice.html'),
        name='privacy_notice'
    ),
]
# ALLAUTH URLS - END - Do not edit or remove this line!
.
wq
END

fi # end of ALLAUTH configuration

# e-mail backend settings
if [ "$SMTP_USE_TLS" == YES -o "$SMTP_USE_TLS" == "True" ]
then
    _SMTP_USE_TLS="True"
else
    _SMTP_USE_TLS="False"
fi

ex "$SETTINGS" <<END
\$a
# EMAIL_BACKEND - BEGIN - Do not edit or remove this line!
EMAIL_BACKEND = 'django.core.mail.backends.smtp.EmailBackend'
EMAIL_USE_TLS = $_SMTP_USE_TLS
EMAIL_HOST = '$SMTP_HOSTNAME'
EMAIL_PORT = $SMTP_PORT
DEFAULT_FROM_EMAIL = '$SMTP_DEFAULT_SENDER'
# EMAIL_BACKEND - END - Do not edit or remove this line!
.
wq
END

# REQUESTLOGGER configuration
ex "$SETTINGS" <<END
/^INSTALLED_APPS\s*=/
/^)/
a
# REQUESTLOGGING APPS - BEGIN - Do not edit or remove this line!
INSTALLED_APPS += (
    # 'django_requestlogging',
)
# REQUESTLOGGING APPS - END - Do not edit or remove this line!
.
/^MIDDLEWARE\s*=/
/^)/a
# REQUESTLOGGING MIDDLEWARE - BEGIN - Do not edit or remove this line!

# request logger specific middleware classes
#MIDDLEWARE += [
#    'django_requestlogging.middleware.LogSetupMiddleware',
#]
# REQUESTLOGGING MIDDLEWARE - END - Do not edit or remove this line!
.
wq
END
# end of REQUESTLOGGER configuration


# WPS-ASYNC CONFIGURATION
if [ "$CONFIGURE_WPSASYNC" != "YES" ]
then
    warn "WPS async backend specific configuration is disabled."
else
    info "WPS async backend specific configuration ..."

    # locate proper configuration file (see also apache configuration)
    _PORT=443 # HTTPS only
    [ -z `locate_apache_conf $_PORT $HOSTNAME` ] && error "Failed to locate Apache virtual host $HOSTNAME:$_PORT configuration!"
    {
        locate_apache_conf $_PORT $HOSTNAME
        locate_apache_conf $_PORT $VIRES_HOSTNAME_INTERNAL
    } | while read CONF
    do
        { ex "$CONF" || /bin/true ; } <<END
/EOXS01_BEGIN/,/EOXS01_END/de
/^[ 	]*<\/Location>/a
    # EOXS01_BEGIN - EOxServer instance - Do not edit or remove this line!

    # WPS static content
    Alias "$VIRES_WPS_URL_PATH" "$VIRES_WPS_PERM_DIR"
    ProxyPass "$VIRES_WPS_URL_PATH" !
    <Directory "$VIRES_WPS_PERM_DIR">
        EnableSendfile off
        Options -MultiViews +FollowSymLinks
        Header set Access-Control-Allow-Origin "*"
    </Directory>

    # EOXS01_END - EOxServer instance - Do not edit or remove this line!
.
wq
END
    done

    # extending the EOxServer settings.py
    ex "$SETTINGS" <<END
/^COMPONENTS\s*=/
/^)/a
# WPSASYNC COMPONENTS - BEGIN - Do not edit or remove this line!
# WPSASYNC COMPONENTS - END - Do not edit or remove this line!
.
\$a
# WPSASYNC LOGGING - BEGIN - Do not edit or remove this line!
LOGGING['loggers']['eoxs_wps_async'] = {
    'handlers': ['eoxserver_file'],
    'level': 'DEBUG' if DEBUG else 'INFO',
    'propagate': False,
}
# WPSASYNC LOGGING - END - Do not edit or remove this line!
.
wq
END

    [ -n "`grep -m 1 '\[services\.ows\.wps\]' "$EOXSCONF"`" ] || echo '[services.ows.wps]' >> "$EOXSCONF"

    # extending the EOxServer configuration
    ex "$EOXSCONF" <<END
/\[services\.ows\.wps\]/a
# WPSASYNC - BEGIN - Do not edit or remove this line!
path_temp=$VIRES_WPS_TEMP_DIR
path_perm=$VIRES_WPS_PERM_DIR
path_task=$VIRES_WPS_TASK_DIR
url_base=$VIRES_URL_ROOT$VIRES_WPS_URL_PATH
socket_file=$VIRES_WPS_SOCKET
max_queued_jobs=$VIRES_WPS_MAX_JOBS
num_workers=$VIRES_WPS_NPROC
# WPSASYNC - END - Do not edit or remove this line!
.
wq
END

    # reset the required WPS directories
    #[ ! -d "$VIRES_WPS_TEMP_DIR" ] || rm -fRv "$VIRES_WPS_TEMP_DIR"
    #[ ! -d "$VIRES_WPS_PERM_DIR" ] || rm -fRv "$VIRES_WPS_PERM_DIR"
    #[ ! -d "$VIRES_WPS_TASK_DIR" ] || rm -fRv "$VIRES_WPS_TASK_DIR"

    for D in "$VIRES_WPS_TEMP_DIR" "$VIRES_WPS_PERM_DIR" "$VIRES_WPS_TASK_DIR" "`dirname "$VIRES_WPS_SOCKET"`"
    do
        mkdir -p "$D"
        chown -v "$VIRES_USER:$VIRES_GROUP" "$D"
        chmod -v 0755 "$D"
    done

    info "WPS async backend ${VIRES_WPS_SERVICE_NAME}.service initialization ..."

    cat > "/etc/systemd/system/${VIRES_WPS_SERVICE_NAME}.service" <<END
[Unit]
Description=Asynchronous EOxServer WPS Daemon
After=network.target
Before=httpd.service

[Service]
Type=simple
User=$VIRES_USER
ExecStartPre=/usr/bin/rm -fv $VIRES_WPS_SOCKET
ExecStart=/usr/bin/python3 -EOm eoxs_wps_async.daemon ${INSTANCE}.settings $INSTROOT/$INSTANCE

[Install]
WantedBy=multi-user.target
END

    systemctl daemon-reload

fi # end of WPS-ASYNC configuration

#-------------------------------------------------------------------------------
# STEP 7: EOXSERVER INITIALISATION
info "Initializing EOxServer instance '${INSTANCE}' ..."

# collect static files
sudo -u "$VIRES_USER" python3 "$MNGCMD" collectstatic -l --noinput

# setup new database
# python "$MNGCMD" makemigrations
sudo -u "$VIRES_USER" python3 "$MNGCMD" migrate


#-------------------------------------------------------------------------------
# STEP 9: CHANGE OWNERSHIP OF THE CONFIGURATION FILES

info "Changing ownership of $INSTROOT/$INSTANCE to $VIRES_USER"
chown -vR "$VIRES_USER:$VIRES_GROUP" "$INSTROOT/$INSTANCE"

#-------------------------------------------------------------------------------
# STEP 10: FINAL SERVICE RESTART

systemctl enable "${VIRES_WPS_SERVICE_NAME}.service"
systemctl restart "${VIRES_WPS_SERVICE_NAME}.service"
systemctl status "${VIRES_WPS_SERVICE_NAME}.service"

#Disabled in order to restart apache only after deployment is fully configured
systemctl restart httpd.service
systemctl status httpd.service

systemctl restart gunicorn.service
systemctl status gunicorn.service