#-----------------------------------------------------------------------
#
#  VirES - Debian 13 VirES development OAuth sever image
#
# Copyright (C) 2025 EOX IT Services GmbH
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

RUN  mkdir -p "$VIRES_ROOT/init"
COPY data/user_groups.json  data/user_permissions.json "$VIRES_ROOT/init"
COPY entrypoint.sh /usr/local/bin/

COPY render_template.py "$CONDA_DIR/envs/$CONDA_ENV_NAME/bin/render_template"

ENTRYPOINT ["entrypoint.sh"]

EXPOSE $SERVER_PORT

WORKDIR "$VIRES_HOME"
