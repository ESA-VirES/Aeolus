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

ENV MINIFORGE_SOURCE_URL="https://github.com/conda-forge/miniforge/releases/download/26.1.1-2/Miniforge3-26.1.1-2-Linux-x86_64.sh"
ENV MINIFORGE_SOURCE_SHA256="831421c1f32d8b510e0ef7f261aaabdbf567bdbba37373432d492621b824ab1f"
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
