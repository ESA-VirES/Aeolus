#-----------------------------------------------------------------------
#
#  VirES - Debian 13 VirES for Aeolus sever image
#
# Copyright (C) 2026 EOX IT Services GmbH
#-----------------------------------------------------------------------

ARG SOURCE_IMAGE

FROM $SOURCE_IMAGE
LABEL maintainer="EOX <martin.paces@eox.at>"

# copy configuration templates
ENV CONFIGURATION_TEMPLATES_DIR="$VIRES_ROOT/configuration_templates"
COPY templates "$CONFIGURATION_TEMPLATES_DIR"

# create the VirES user and group
RUN groupadd -r "$VIRES_GROUP"
RUN useradd -r -M -g "$VIRES_GROUP" -d "$VIRES_HOME" -s /sbin/nologin -c "VirES system user" "$VIRES_USER"

COPY render_template.py "$CONDA_DIR/envs/$CONDA_ENV_NAME/bin/render_template"

COPY entrypoint.sh /usr/local/bin/
ENTRYPOINT ["entrypoint.sh"]

EXPOSE $SERVER_PORT

WORKDIR "$VIRES_HOME"
