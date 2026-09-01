#-----------------------------------------------------------------------
#
#  VirES - Debian 13 VirES base Aeolus server image
#
# Copyright (C) 2026 EOX IT Services GmbH
#-----------------------------------------------------------------------

ARG SOURCE_IMAGE

# -----------------------------------------------------------------------------

FROM $SOURCE_IMAGE AS final
LABEL maintainer="EOX <martin.paces@eox.at>"

ENV CONDA_ENV_NAME="aeolus"
ENV CODADEF_VERSION="20231201"                                             
ENV CODADEF_FILENAME="AEOLUS-${CODADEF_VERSION}.codadef"
ENV CODADEF_SOURCE_URL="https://github.com/stcorp/codadef-aeolus/releases/download/${CODADEF_VERSION}/${CODADEF_FILENAME}"
ENV CODADEF_SOURCE_SHA256="a3c2ea373603050b75067b980d1b773de16cd13a06d69acf3edcd05f16de43e6"
ENV CODADEF_DIR="${CONDA_DIR}/envs/${CONDA_ENV_NAME}/share/coda/definitions"

RUN mkdir -p /build
COPY aeolus.yaml /build/aeolus.yaml
RUN conda env create --quiet --yes --name "$CONDA_ENV_NAME" --file="/build/aeolus.yaml" \
 && conda clean --all -f -y

RUN mkdir -p "$CODADEF_DIR"
RUN curl --silent --show-error --location "$CODADEF_SOURCE_URL" --output "$CODADEF_DIR/$CODADEF_FILENAME"
RUN sh -c 'echo "$CODADEF_SOURCE_SHA256  $CODADEF_DIR/$CODADEF_FILENAME" | sha256sum -c -'

# -----------------------------------------------------------------------------

ENV SERVER_NPROC=4
#ENV SERVER_NTHREAD=1 # fixed to 1, not configurable
ENV SERVER_PORT=8011

ENV VIRES_ASYNC_WPS_MAX_JOBS=64
ENV VIRES_ASYNC_WPS_NPROC=2

ENV INSTANCE_NAME="aeolus"
ENV LOG_DIR="/var/log/vires"
ENV INSTANCE_DIR="$VIRES_ROOT/$INSTANCE_NAME"
ENV STATIC_DIR="$VIRES_ROOT/${INSTANCE_NAME}_static"

ENV VIRES_DATA_DIR="$VIRES_ROOT/data"
ENV VIRES_WPS_DIR="$VIRES_ROOT/wps"
ENV VIRES_SOCKET_DIR="$VIRES_ROOT/sockets"
ENV VIRES_ASYNC_WPS_SOCKET_FILE="$VIRES_SOCKET_DIR/async_wps.socket"

ENV AEOLUS_OPTIMIZED_DIR="$VIRES_ROOT/optimized"
ENV AEOLUS_UPLOAD_DIR="$VIRES_ROOT/upload"

ENV INSTANCE_LOG="$LOG_DIR/$INSTANCE_NAME/server.log"
ENV ACCESS_LOG="$LOG_DIR/$INSTANCE_NAME/access.log"
ENV GUNICORN_ACCESS_LOG="$LOG_DIR/$INSTANCE_NAME/gunicorn_access.log"
ENV GUNICORN_ERROR_LOG="$LOG_DIR/$INSTANCE_NAME/gunicorn_error.log"

ENV PATH=$INSTANCE_DIR:$PATH

RUN mkdir -p "$LOG_DIR"
RUN mkdir -p "$INSTANCE_DIR"
RUN mkdir -p "$STATIC_DIR"
RUN mkdir -p "$VIRES_DATA_DIR"
RUN mkdir -p "$VIRES_WPS_DIR"
RUN mkdir -p "$VIRES_SOCKET_DIR"
RUN mkdir -p "$AEOLUS_OPTIMIZED_DIR"
RUN mkdir -p "$AEOLUS_UPLOAD_DIR"

# matplotlib configuration
RUN mkdir -p "$VIRES_HOME/.config/matplotlib/" \
  && sh -c "echo 'backend:Agg' > '$VIRES_HOME/.config/matplotlib/matplotlibrc'"

# web-client installation script
COPY install_client.sh $VENV_ROOT/bin/install_client

# data registration script
COPY register_products.sh  /usr/local/bin/register_products
