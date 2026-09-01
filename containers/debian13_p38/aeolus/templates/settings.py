# VirES for Aeolus development server settings
from os.path import join, abspath, dirname

PROJECT_DIR = dirname(abspath(__file__))

DEBUG = True

MANAGERS = ADMINS = ()

DATABASES = {
    'default': {
        'ENGINE': 'django.contrib.gis.db.backends.postgis',
        'NAME': '{{DBNAME}}',
        'USER': '{{DBUSER}}',
        'PASSWORD': '{{DBPASSWD}}',
        'HOST': '::1',
        'PORT': '5432',
    }
}
DEFAULT_AUTO_FIELD = 'django.db.models.AutoField'

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

STATIC_ROOT = '/srv/vires/aeolus_static'
STATIC_URL = '/aeolus_static/'

STATICFILES_DIRS = []

STATICFILES_FINDERS = [
    'django.contrib.staticfiles.finders.FileSystemFinder',
    'django.contrib.staticfiles.finders.AppDirectoriesFinder',
]

SECRET_KEY = '{{SECRET_KEY}}'

MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    #'allauth.account.middleware.AccountMiddleware', # added in later versions
]

ROOT_URLCONF = 'aeolus_instance.urls'

# Python dotted path to the WSGI application used by Django's runserver.
WSGI_APPLICATION = 'aeolus_instance.wsgi.application'

TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'APP_DIRS': True,
        'DIRS': [
            join(PROJECT_DIR, 'templates'),
        ],
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

#EOXS_SERVICE_HANDLERS = [
#    'eoxserver.services.ows.wps.v10.getcapabilities.WPS10GetCapabilitiesHandler',
#    'eoxserver.services.ows.wps.v10.describeprocess.WPS10DescribeProcessHandler',
#    'eoxserver.services.ows.wps.v10.execute.WPS10ExecuteHandler',
#]

EOXS_PROCESSES = [
    'eoxserver.services.ows.wps.processes.get_time_data.GetTimeDataProcess',
    'aeolus.processes.aux.Level1BAUXISRExtract',
    'aeolus.processes.aux.Level1BAUXMRCExtract',
    'aeolus.processes.aux.Level1BAUXRRCExtract',
    'aeolus.processes.aux.Level1BAUXZWCExtract',
    'aeolus.processes.aux_met.AUXMET12Extract',
    'aeolus.processes.dsd.DSDExtract',
    'aeolus.processes.level_1a.Level1AExtract',
    'aeolus.processes.level_1b.Level1BExtract',
    'aeolus.processes.level_2a.Level2AExtract',
    'aeolus.processes.level_2b.Level2BExtract',
    'aeolus.processes.level_2c.Level2CExtract',
    'aeolus.processes.raw_download.RawDownloadProcess',
    'aeolus.processes.remove_job.RemoveJob',
    'aeolus.processes.list_jobs.ListJobs',
]

EOXS_ASYNC_BACKENDS = [
    'eoxs_wps_async.backend.WPSAsyncBackendBase',
]

EOXS_WMS_DIM_RANGES_SEPARATOR = ';'
EOXS_WMS_DIM_RANGE_SEPARATOR = ','
EOXS_VALIDATE_IDS_NCNAME = False

AEOLUS_OPTIMIZED_DIR = "{{AEOLUS_OPTIMIZED_DIR}}"
USER_UPLOAD_DIR = "{{AEOLUS_UPLOAD_DIR}}"

LOGGING = {
    'version': 1,
    'disable_existing_loggers': False, # Set False to preserve Gunicorn access logging.
    'filters': {
        'require_debug_false': {
            '()': 'django.utils.log.RequireDebugFalse'
        },
    },
    'formatters': {
        'default': {
            'format': '%(asctime)s.%(msecs)03d %(name)s %(levelname)s: %(message)s',
            'datefmt': '%Y-%m-%dT%H:%M:%S',
        },
        'access': {
            'format': '%(asctime)s.%(msecs)03d %(remote_addr)s %(username)s %(name)s %(levelname)s: %(message)s',
            'datefmt': '%Y-%m-%dT%H:%M:%S',
        },
    },
    'handlers': {
        'server_file': {
            'level': 'DEBUG',
            'class': 'logging.handlers.WatchedFileHandler',
            'filename': '{{INSTANCE_LOG}}',
            'formatter': 'default',
            'filters': [],
        },
        'access_file': {
            'level': 'DEBUG',
            'class': 'logging.handlers.WatchedFileHandler',
            'filename': '{{ACCESS_LOG}}',
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
            'handlers': ['server_file'],
            'level': 'DEBUG' if DEBUG else 'INFO',
            'propagate': False,
        },
        'aeolus': {
            'handlers': ['server_file'],
            'level': 'DEBUG' if DEBUG else 'INFO',
            'propagate': False,
        },
        'vires_sync': {
            'handlers': ['server_file'],
            'level': 'DEBUG' if DEBUG else 'INFO',
            'propagate': False,
        },
        'eoxs_wps_async': {
            'handlers': ['server_file'],
            'level': 'DEBUG' if DEBUG else 'INFO',
            'propagate': False,
        },
        'access': {
            'handlers': ['access_file'],
            'level': 'DEBUG' if DEBUG else 'INFO',
            'propagate': False,
        },
        '': {
            'handlers': ['server_file'],
            'level': 'INFO' if DEBUG else 'WARNING',
            'propagate': False,
        },
    },
}


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
        'DIRECT_SERVER_URL': 'http://[::1]:80/oauth',
        'SCOPE': ['read_id', 'read_permissions'],
        'PERMISSION': 'aeolus_default',
        'REQUIRED_GROUP_PERMISSIONS': {
            # <aeolus-group-name>: <oauth-permission>,
            'aeolus_default': 'aeolus_default',
            'aeolus_privileged': 'aeolus_privileged',
            'aeolus_l1a_access': 'aeolus_l1a_access',
        },
    },
}

MIDDLEWARE += [
    'eoxs_allauth.middleware.inactive_user_logout_middleware',
    'eoxs_allauth.middleware.access_logging_middleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
    'django.middleware.gzip.GZipMiddleware',
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
VIRES_VRE_JHUB_URL = None
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
        'handlers': ['server_file'],
        'level': 'DEBUG' if DEBUG else 'INFO',
        'propagate': False,
    },
})
