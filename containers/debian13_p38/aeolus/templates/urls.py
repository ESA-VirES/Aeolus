""" VirES Aeolus server URL Configuration
"""

from django.conf.urls import include, url
from eoxserver.services.views import ows
from eoxs_allauth.views import wrap_protected_api, wrap_open_api, workspace
from eoxs_allauth.urls import document_urlpatterns
from aeolus.views import upload_user_file

urlpatterns = [
    url(r'^$', workspace(), name="workspace"),
    url(r'^ows$', wrap_protected_api(ows), name="ows"),
    url(r'^accounts/', include('eoxs_allauth.urls')),
    url(r'^upload/$', wrap_protected_api(upload_user_file)),
] + document_urlpatterns
