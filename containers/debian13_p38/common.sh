# common settings

export POD_PORT="9400"
export POD_NAME="aeolus-server-debian13-p38-dev"

list_managed_images() {
    cat - << END
debian13
ingress
database
redis
conda-base
oauth-base
oauth
aeolus-base
aeolus
END
}

list_nonmanaged_images() {
    cat - << END
END
}

list_all_images() {
    list_managed_images
    list_nonmanaged_images
}

start_containers() {
    $BIN_DIR/container database start \
      && $BIN_DIR/container redis start \
      && $BIN_DIR/container database exec /bin/sh -c 'while ! pg_isready ; do sleep 1 ; done' \
      && $BIN_DIR/container database exec -i create_db < $VIRES_CONTAINER_ROOT/volumes/secrets/oauth.conf \
      && $BIN_DIR/container database exec -i create_db < $VIRES_CONTAINER_ROOT/volumes/secrets/aeolus.conf \
      && $BIN_DIR/container oauth start \
      && $BIN_DIR/container aeolus start \
      && $BIN_DIR/container ingress start
}

VIRES_CONTAINER_ROOT="${VIRES_CONTAINER_ROOT:-.}"
[ -f "$VIRES_CONTAINER_ROOT/tag.conf" ] && . "$VIRES_CONTAINER_ROOT/tag.conf"
