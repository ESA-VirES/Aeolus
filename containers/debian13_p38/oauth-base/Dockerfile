#-----------------------------------------------------------------------
#
#  VirES - Debian 13 VirES base OAuth server image
#
# Copyright (C) 2026 EOX IT Services GmbH
#-----------------------------------------------------------------------

ARG SOURCE_IMAGE

# -----------------------------------------------------------------------------

FROM $SOURCE_IMAGE AS final
LABEL maintainer="EOX <martin.paces@eox.at>"

ENV CONDA_ENV_NAME="oauth"

RUN mkdir -p /build
COPY oauth.yaml /build/oauth.yaml
RUN conda env create --quiet --yes --name "$CONDA_ENV_NAME" --file="/build/oauth.yaml" \
 && conda clean --all -f -y

# -----------------------------------------------------------------------------

ENV SERVER_NPROC=2
ENV SERVER_NTHREAD=2
ENV SERVER_PORT=8010

ENV INSTANCE_NAME="oauth"
ENV LOG_DIR="/var/log/vires"
ENV INSTANCE_DIR="$VIRES_ROOT/$INSTANCE_NAME"
ENV STATIC_DIR="$VIRES_ROOT/${INSTANCE_NAME}_static"

ENV INSTANCE_LOG="$LOG_DIR/$INSTANCE_NAME/server.log"
ENV ACCESS_LOG="$LOG_DIR/$INSTANCE_NAME/access.log"
ENV GUNICORN_ACCESS_LOG="$LOG_DIR/$INSTANCE_NAME/gunicorn_access.log"
ENV GUNICORN_ERROR_LOG="$LOG_DIR/$INSTANCE_NAME/gunicorn_error.log"

PATH=$INSTANCE_DIR:$PATH

RUN mkdir -p "$INSTANCE_DIR"
RUN mkdir -p "$STATIC_DIR"
