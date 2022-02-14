#!/bin/sh
#-------------------------------------------------------------------------------
#
# Purpose: VirES-Server instance configuration
# Author(s): Martin Paces <martin.paces@eox.at>
#-------------------------------------------------------------------------------
# Copyright (C) 2015 EOX IT Services GmbH

. `dirname $0`/../lib_logging.sh
. `dirname $0`/../lib_apache.sh
. `dirname $0`/../lib_python_venv.sh
. `dirname $0`/../lib_vires.sh

info "Configuring Aeolus-Server instance ... "

DEBUG="${DEBUG:-True}"

activate_venv "$VIRES_VENV_ROOT"

AEOLUS_ACCESS_PERMISSION=${AEOLUS_ACCESS_PERMISSION:-aeolus_default}
AEOLUS_PRIVILEGED_PERMISSION=${AEOLUS_PRIVILEGED_PERMISSION:-aeolus_privileged}

# Configuration switches - all default to YES
CONFIGURE_VIRES=${CONFIGURE_VIRES:-YES}
CONFIGURE_ALLAUTH=${CONFIGURE_ALLAUTH:-YES}
CONFIGURE_WPSASYNC=${CONFIGURE_WPSASYNC:-YES}

required_variables VIRES_SERVER_HOME
required_variables VIRES_SERVER_HOST VIRES_SERVICE_NAME
required_variables VIRES_SERVER_NPROC VIRES_SERVER_NTHREAD
required_variables VIRES_USER VIRES_GROUP VIRES_INSTALL_USER VIRES_INSTALL_GROUP
required_variables VIRES_LOGDIR VIRES_TMPDIR
required_variables VIRES_WPS_SERVICE_NAME VIRES_WPS_URL_PATH
required_variables VIRES_WPS_TEMP_DIR VIRES_WPS_PERM_DIR VIRES_WPS_TASK_DIR
required_variables VIRES_WPS_SOCKET VIRES_WPS_NPROC VIRES_WPS_MAX_JOBS

set_instance_variables

#required_variables HOSTNAME
required_variables INSTANCE INSTROOT
required_variables FIXTURES_DIR STATIC_DIR
required_variables SETTINGS WSGI_FILE URLS WSGI MNGCMD EOXSCONF
required_variables STATIC_URL_PATH OWS_URL
required_variables VIRESLOG ACCESSLOG
required_variables OAUTH_SERVER_HOST
required_variables VIRES_OPTIMIZED_DIR VIRES_UPLOAD_DIR

if [ -z "$DBENGINE" -o -z "$DBNAME" ]
then
    load_db_conf "`dirname $0`/../db_eoxs.conf"
fi
required_variables DBENGINE DBNAME

HTTP_TIMEOUT=600

#-------------------------------------------------------------------------------
# STEP 1: CREATE INSTANCE (if not already present)

info "Creating VirES-Server instance '${INSTANCE}' in '$INSTROOT/$INSTANCE' ..."

# check availability of the EOxServer
#HINT: Does python3 complain that the apparently installed EOxServer
#      package is not available? First check that the 'eoxserver' tree is
#      readable by anyone. (E.g. in case of read protected home directory when
#      the development setup is used.)
python3 -c 'import eoxserver' || error "EOxServer does not seem to be installed!"

if [ ! -d "$INSTROOT/$INSTANCE" ]
then
    mkdir -p "$INSTROOT/$INSTANCE"
    eoxserver-instance.py "$INSTANCE" "$INSTROOT/$INSTANCE"
fi

# create WPS and upload directories if missing
for DIR in "$VIRES_OPTIMIZED_DIR" "$VIRES_UPLOAD_DIR" "$VIRES_WPS_TEMP_DIR" "$VIRES_WPS_PERM_DIR" "$VIRES_WPS_TASK_DIR" "`dirname "$VIRES_WPS_SOCKET"`"
do
    if [ ! -d "$DIR" ]
    then
        mkdir -p "$DIR"
        chown -v "$VIRES_USER:$VIRES_GROUP" "$DIR"
        chmod -v 0755 "$DIR"
    fi
done

#-------------------------------------------------------------------------------
# STEP 2-1: INSTANCE CONFIGURATION - common

# if possible extract secret key from the existing settings
[ ! -f "$SETTINGS" ] || SECRET_KEY="`sed -ne 's/^SECRET_KEY\s*=\s*'\''\([^'\'']*\)'\''.*$/\1/p' "$SETTINGS" `"
[ -n "$SECRET_KEY" ] || SECRET_KEY="`python3 -c 'from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())'`"

cat > "$SETTINGS" <<END
# generated by VirES-for-Aeolus configuration scrip

from os.path import join, abspath, dirname

DEBUG = $DEBUG

PROJECT_DIR = dirname(abspath(__file__))
PROJECT_URL_PREFIX = ''

MANAGERS = ADMINS = (
)

DATABASES = {
    'default': {
        'ENGINE': '$DBENGINE',
        'NAME': '$DBNAME',
        'USER': '$DBUSER',
        'PASSWORD': '$DBPASSWD',
        'HOST': '$DBHOST',
        'PORT': '$DBPORT',
    }
}

SITE_ID = 1
ALLOWED_HOSTS = ['*', '127.0.0.1', '::1']
USE_X_FORWARDED_HOST = True

LANGUAGE_CODE = 'en-us'
USE_I18N = True
USE_L10N = True

TIME_ZONE = 'UTC'
USE_TZ = True
MEDIA_ROOT = ''
MEDIA_URL = ''

STATIC_ROOT = join(PROJECT_DIR, 'static')
STATIC_URL = '$STATIC_URL_PATH/'

STATICFILES_DIRS = []

STATICFILES_FINDERS = [
    'django.contrib.staticfiles.finders.FileSystemFinder',
    'django.contrib.staticfiles.finders.AppDirectoriesFinder',
]

SECRET_KEY = '$SECRET_KEY'

MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',
    'django.middleware.gzip.GZipMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
]

ROOT_URLCONF = '$INSTANCE.urls'

# Python dotted path to the WSGI application used by Django's runserver.
WSGI_APPLICATION = '$INSTANCE.wsgi.application'

TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [join(PROJECT_DIR, 'templates')],
        'APP_DIRS': True,
        'OPTIONS': {
            'debug': DEBUG,
            'context_processors': [
                'django.template.context_processors.debug',
                'django.template.context_processors.request',
                'django.contrib.auth.context_processors.auth',
                'django.contrib.messages.context_processors.messages',
            ],
        }
    }
]

INSTALLED_APPS = [
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.sites',
    'django.contrib.messages',
    'django.contrib.gis',
    'django.contrib.staticfiles',
    'eoxserver.core',
    'eoxserver.services',
    'eoxserver.resources.coverages',
    'eoxserver.backends',
    'eoxserver.testing',
    #'eoxserver.webclient'
    'aeolus',
]

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

EOXS_WMS_DIM_RANGES_SEPARATOR = ';'
EOXS_WMS_DIM_RANGE_SEPARATOR = ','
EOXS_ASYNC_BACKENDS = [
    'eoxs_wps_async.backend.WPSAsyncBackendBase',
]
EOXS_VALIDATE_IDS_NCNAME = False
AEOLUS_OPTIMIZED_DIR = '${VIRES_OPTIMIZED_DIR}'
USER_UPLOAD_DIR = '${VIRES_UPLOAD_DIR}'

LOGGING = {
    'version': 1,
    'disable_existing_loggers': False, # Set False to preserve Gunicorn logging.
    'filters': {
        'require_debug_false': {
            '()': 'django.utils.log.RequireDebugFalse'
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
            'filename': '${VIRESLOG}',
            'formatter': 'default',
            'filters': [],
        },
        'access_file': {
            'level': 'DEBUG',
            'class': 'logging.handlers.WatchedFileHandler',
            'filename': '${ACCESSLOG}',
            'formatter': 'access',
            'filters': [],
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
        'aeolus': {
            'handlers': ['eoxserver_file'],
            'level': 'DEBUG' if DEBUG else 'INFO',
            'propagate': False,
        },
        'eoxs_wps_async': {
            'handlers': ['eoxserver_file'],
            'level': 'DEBUG' if DEBUG else 'INFO',
            'propagate': False,
        },
        'access': {
            'handlers': ['access_file'],
            'level': 'DEBUG' if DEBUG else 'INFO',
            'propagate': False,
        },
        'django.request': {
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

END

ex "$EOXSCONF" <<END
/\[services\.owscommon\]
.,/^\[/g/^\s*[^[]/d
.i
http_service_url=/ows?
.
/\[services\.ows\]
.,/^\[/g/^\s*[^[]/d
.i
update_sequence=`date -u +'%Y%m%dT%H%M%SZ'`
onlineresource=https://vires.services
keywords=ESA, Aeolus Mission, Atmospheric Science
fees=none
access_constraints=none
name=VirES for Aeolus
title=VirES for Aeolus
abstract=VirES for Aeolus
provider_name=EOX IT Services, GmbH
provider_site=https://eox.at
individual_name=
position_name=
phone_voice=
phone_facsimile=
delivery_point=Thurngasse 8/4
city=Wein
administrative_area=Wien
postal_code=1090
country=AT
electronic_mail_address=office@eox.at
hours_of_service=
contact_instructions=
role=Service provider
.
wq
END

{ ex "$EOXSCONF" || /bin/true ; } <<END
/^# WPSASYNC - BEGIN/,/^# WPSASYNC - END/d
wq
END

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

#-------------------------------------------------------------------------------
# STEP 2-2: INSTANCE CONFIGURATION - optional - no authentication

# FIXME

[ "$CONFIGURE_ALLAUTH" != "YES" ] && cat > "$URLS" <<END
from django.conf.urls import include, url
#from eoxserver.services.views import ows
from vires.views import custom_data #, custom_model, client_state
from aeolus.views import upload_user_file

urlpatterns = [
    url(r'^ows', include("eoxserver.services.urls")),
    url(r'^upload/$', upload_user_file),
]
END

#-------------------------------------------------------------------------------
# STEP 2-3: INSTANCE CONFIGURATION - optional - authentication enabled

# FIXME

[ "$CONFIGURE_ALLAUTH" == "YES" ] && cat > "$URLS" <<END
from django.conf.urls import include, url
from eoxserver.services.views import ows
from eoxs_allauth.views import wrap_protected_api, wrap_open_api, workspace
from eoxs_allauth.urls import document_urlpatterns
#from vires.views import custom_data #, custom_model, client_state
from aeolus.views import upload_user_file

urlpatterns = [
    url(r'^$', workspace(), name="workspace"),
    url(r'^ows$', wrap_protected_api(ows), name="ows"),
    url(r'^accounts/', include('eoxs_allauth.urls')),
    url(r'^upload/$', wrap_protected_api(upload_user_file)),
] + document_urlpatterns
END

[ "$CONFIGURE_ALLAUTH" == "YES" ] && cat >> "$SETTINGS" <<END

# Django-Allauth settings

INSTALLED_APPS += [
    'eoxs_allauth',
    'allauth',
    'allauth.account',
    'allauth.socialaccount',
    'eoxs_allauth.vires_oauth', # VirES-OAuth2 "social account provider"
    'django_countries',
]

SOCIALACCOUNT_PROVIDERS = {
    'vires': {
        'SERVER_URL': '/oauth/',
        'DIRECT_SERVER_URL': 'http://$OAUTH_SERVER_HOST',
        'SCOPE': ['read_id', 'read_permissions'],
        'PERMISSION': '$AEOLUS_ACCESS_PERMISSION',
        'REQUIRED_GROUP_PERMISSIONS': {
            # <aeolus-group-name>: <oauth-permission>,
            'aeolus_default': '$AEOLUS_ACCESS_PERMISSION',
            'aeolus_privileged': '$AEOLUS_PRIVILEGED_PERMISSION',
        },
    },
}

MIDDLEWARE += [
    'eoxs_allauth.middleware.inactive_user_logout_middleware',
    'eoxs_allauth.middleware.access_logging_middleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
]

AUTHENTICATION_BACKENDS = (
    # Needed to login by username in Django admin, regardless of allauth
    'django.contrib.auth.backends.ModelBackend',
    # allauth specific authentication methods, such as login by e-mail
    'allauth.account.auth_backends.AuthenticationBackend',
)

# Django allauth
SITE_ID = 1 # ID from django.contrib.sites
VIRES_VRE_JHUB_PERMISSION = "aeolus_vre"
VIRES_VRE_JHUB_URL = ${VIRES_VRE_JHUB_URL:+"'"}${VIRES_VRE_JHUB_URL:-None}${VIRES_VRE_JHUB_URL:+"'"}
LOGIN_REDIRECT_URL = "/"
LOGIN_URL = "/accounts/vires/login/"
SOCIALACCOUNT_AUTO_SIGNUP = True
SOCIALACCOUNT_EMAIL_REQUIRED = False
SOCIALACCOUNT_LOGIN_ON_GET = False
ACCOUNT_DEFAULT_HTTP_PROTOCOL = 'http'
CSRF_COOKIE_NAME = "aeolus:data:csrftoken"
SESSION_COOKIE_NAME = "aeolus:data:sessionid"
SESSION_EXPIRE_AT_BROWSER_CLOSE = True

TEMPLATES[0]['OPTIONS']['context_processors'] = TEMPLATES[0]['OPTIONS'].get('context_processors', []) + [
    'eoxs_allauth.vires_oauth.context_processors.vires_oauth',
    'eoxs_allauth.context_processors.vre_jhub', # required by VRE/JupyterHub integration
]

# VirES-Server AllAuth settings
WORKSPACE_TEMPLATE="vires/workspace.html"
OWS11_EXCEPTION_XSL = join(STATIC_URL, "other/owserrorstyle.xsl")

LOGGING['loggers'].update({
    'eoxs_allauth': {
        'handlers': ['eoxserver_file'],
        'level': 'DEBUG' if DEBUG else 'INFO',
        'propagate': False,
    },
})
END

#-------------------------------------------------------------------------------
# STEP 3: APACHE WEB SERVER INTEGRATION

info "Mapping VirES-Server instance '${INSTANCE}' to URL path '${INSTANCE}' ..."

# locate proper configuration file (see also apache configuration)
{
    locate_apache_conf 80
    locate_apache_conf 443
} | while read CONF
do
    { ex "$CONF" || /bin/true ; } <<END
/EOXS00_BEGIN/,/EOXS00_END/de
/^\s*<\/VirtualHost>/i
    # EOXS00_BEGIN - VirES-Server instance - Do not edit or remove this line!

    # VirES-Server instance configured by the automatic installation script

    # static content
    Alias "$STATIC_URL_PATH" "$STATIC_DIR"
    ProxyPass "$STATIC_URL_PATH" !
    <Directory "$STATIC_DIR">
        Options -MultiViews +FollowSymLinks
        Header set Access-Control-Allow-Origin "*"
    </Directory>

    # favicon redirect
    Alias "/favicon.ico" "$INSTSTAT_DIR/other/favicon/favicon.ico"
    ProxyPass "/favicon.ico" !

    # WPS static content
    Alias "$VIRES_WPS_URL_PATH" "$VIRES_WPS_PERM_DIR"
    ProxyPass "$VIRES_WPS_URL_PATH" !
    <Directory "$VIRES_WPS_PERM_DIR">
        EnableSendfile off
        Options -MultiViews +FollowSymLinks
        Header set Access-Control-Allow-Origin "*"
    </Directory>

    ProxyPass "${BASE_URL_PATH:-/}" "http://$VIRES_SERVER_HOST${BASE_URL_PATH:-/}" connectiontimeout=60 timeout=$HTTP_TIMEOUT
    #ProxyPassReverse "${BASE_URL_PATH:-/}" "http://$VIRES_SERVER_HOST${BASE_URL_PATH:-/}"
    #RequestHeader set SCRIPT_NAME "${BASE_URL_PATH:-/}"

    # EOXS00_END - VirES-Server instance - Do not edit or remove this line!
.
wq
END
done

#-------------------------------------------------------------------------------
# STEP 4: setup logfiles

# touch the logfile and set the right permissions
_create_log_file() {
    [ -d "`dirname "$1"`" ] || mkdir -p "`dirname "$1"`"
    touch "$1"
    chown "$VIRES_USER:$VIRES_GROUP" "$1"
    chmod 0664 "$1"
}
_create_log_file "$VIRESLOG"
_create_log_file "$ACCESSLOG"
_create_log_file "$GUNICORN_ACCESS_LOG"
_create_log_file "$GUNICORN_ERROR_LOG"

#setup logrotate configuration
cat >"/etc/logrotate.d/vires_server_${INSTANCE}" <<END
$VIRESLOG {
    copytruncate
    weekly
    minsize 1M
    rotate 560
    compress
    missingok
}
$ACCESSLOG {
    copytruncate
    weekly
    minsize 1M
    rotate 560
    compress
    missingok
}
$GUNICORN_ACCESS_LOG {
    copytruncate
    weekly
    minsize 1M
    rotate 560
    compress
}
$GUNICORN_ERROR_LOG {
    copytruncate
    weekly
    minsize 1M
    rotate 560
    compress
}
END

#-------------------------------------------------------------------------------
# STEP 5: CHANGE OWNERSHIP OF THE CONFIGURATION FILES

info "Changing ownership of $INSTROOT/$INSTANCE to $VIRES_INSTALL_USER"
chown -R "$VIRES_INSTALL_USER:$VIRES_INSTALL_GROUP" "$INSTROOT/$INSTANCE"

#-------------------------------------------------------------------------------
# STEP 6: DJANGO INITIALISATION
info "Initializing VirES-Server instance '${INSTANCE}' ..."

# collect static files
manage collectstatic -l --noinput

# setup new database
manage migrate --noinput

#-------------------------------------------------------------------------------
# STEP 7: SERVICE SETUP

info "Setting up ${VIRES_SERVICE_NAME}.service"
cat > "/etc/systemd/system/${VIRES_SERVICE_NAME}.service" <<END
[Unit]
Description=VirES-Server instance
After=network.target
Before=httpd.service

[Service]
PIDFile=/run/${VIRES_SERVICE_NAME}.pid
Type=simple
WorkingDirectory=$INSTROOT/$INSTANCE
ExecStart=${VIRES_VENV_ROOT}/bin/gunicorn \\
    --preload \\
    --name ${VIRES_SERVICE_NAME} \\
    --user $VIRES_USER \\
    --group $VIRES_GROUP \\
    --workers $VIRES_SERVER_NPROC \\
    --threads $VIRES_SERVER_NTHREAD \\
    --timeout $HTTP_TIMEOUT \\
    --pid /run/${VIRES_SERVICE_NAME}.pid \\
    --access-logfile $GUNICORN_ACCESS_LOG \\
    --error-logfile $GUNICORN_ERROR_LOG \\
    --capture-output \\
    --bind "$VIRES_SERVER_HOST" \\
    --chdir $INSTROOT/$INSTANCE \\
    ${INSTANCE}.wsgi
ExecReload=/bin/kill -s HUP \$MAINPID
ExecStop=/bin/kill -s TERM \$MAINPID
PrivateTmp=true

[Install]
WantedBy=multi-user.target
END

info "Setting up ${VIRES_WPS_SERVICE_NAME}.service"
cat > "/etc/systemd/system/${VIRES_WPS_SERVICE_NAME}.service" <<END
[Unit]
Description=Asynchronous EOxServer WPS Daemon
After=network.target
Before=httpd.service

[Service]
Type=simple
User=$VIRES_USER
ExecStartPre=/usr/bin/rm -fv $VIRES_WPS_SOCKET
ExecStart=${VIRES_VENV_ROOT}/bin/python3 -EsOm eoxs_wps_async.daemon ${INSTANCE}.settings $INSTROOT/$INSTANCE

[Install]
WantedBy=multi-user.target
END

systemctl daemon-reload
systemctl enable "${VIRES_SERVICE_NAME}.service"
systemctl enable "${VIRES_WPS_SERVICE_NAME}.service"
