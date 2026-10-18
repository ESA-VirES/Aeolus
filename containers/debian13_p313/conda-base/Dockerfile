#-----------------------------------------------------------------------
#
#  VirES - Debian 13 VirES common base Miniforge image
#
# Copyright (C) 2026 EOX IT Services GmbH
#-----------------------------------------------------------------------

ARG SOURCE_IMAGE
ARG VIRES_ROOT="/srv/vires"

# -----------------------------------------------------------------------------

FROM $SOURCE_IMAGE AS base
LABEL maintainer="EOX <martin.paces@eox.at>"

ENV MINIFORGE_SOURCE_URL="https://github.com/conda-forge/miniforge/releases/download/26.3.2-3/Miniforge3-26.3.2-3-Linux-x86_64.sh"
ENV MINIFORGE_SOURCE_SHA256="848194851a98903134187fbb4ab50efe87b003e0c0f808f97644b7524a62bf2c"
ENV CONDA_DIR="/opt/miniforge"

# install Miniforge3
RUN mkdir -p /build
RUN curl --silent --show-error --location "$MINIFORGE_SOURCE_URL" --output /build/miniforge3.sh
RUN sh -c 'echo "$MINIFORGE_SOURCE_SHA256  /build/miniforge3.sh" | sha256sum -c -'
RUN sh -c '/bin/bash /build/miniforge3.sh -b -p "$CONDA_DIR"'

# -----------------------------------------------------------------------------

FROM $SOURCE_IMAGE AS final
LABEL maintainer="EOX <martin.paces@eox.at>"

ENV VIRES_ROOT="/srv/vires"
ENV VIRES_USER="vires"
ENV VIRES_GROUP="vires"
ENV VIRES_HOME="$VIRES_ROOT/home"
ENV PIP_OPTIONS="--upgrade --upgrade-strategy=only-if-needed"

ENV CONDA_DIR="/opt/miniforge"
ENV PATH="${CONDA_DIR}/bin:${PATH}"

COPY --from=base "$CONDA_DIR" "$CONDA_DIR"
