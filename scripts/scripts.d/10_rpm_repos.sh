#!/bin/sh
#-------------------------------------------------------------------------------
#
# Purpose: Installation of extra RPM repositories.
# Author(s): Martin Paces <martin.paces@eox.at>
#-------------------------------------------------------------------------------
# Copyright (C) 2015 EOX IT Services GmbH

. `dirname $0`/../lib_logging.sh

info "Installing extra RPM repositories ..."

# EPEL: http://fedoraproject.org/wiki/EPEL
yum --assumeyes install install epel-release

# EOX - EOX RPM repository
rpm -q --quiet eox-release || rpm -Uvh http://yum.packages.eox.at/el/eox-release-7-0.noarch.rpm

# reset yum cache
yum clean all
