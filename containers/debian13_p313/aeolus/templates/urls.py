""" VirES Aeolus server URL Configuration
"""

from django.urls import include, path
from eoxserver.services.views import ows
from eoxs_allauth.views import wrap_protected_api, wrap_open_api, workspace
from eoxs_allauth.urls import document_urlpatterns
from aeolus.views import upload_user_file, probe

urlpatterns = [
    path('', workspace(), name="workspace"),
    path('ows', wrap_protected_api(ows), name="ows"),
    path('accounts/', include('eoxs_allauth.urls')),
    path('upload/', wrap_protected_api(upload_user_file)),
    path('probe', probe, name="probe"),
] + document_urlpatterns
