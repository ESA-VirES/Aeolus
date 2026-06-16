SOURCE_IMAGE_NAME="debian13-p38-vires-aeolus-base"
SOURCE_IMAGE="$REGISTRY/$SOURCE_IMAGE_NAME:$IMAGE_TAG"

IMAGE_NAME="debian13-p38-vires-aeolus-dev"
IMAGE="$REGISTRY/$IMAGE_NAME:$IMAGE_TAG"

AEOLUS_DATA=${AEOLUS_DATA:-../../data}

BUILD_OPTIONS="--squash --no-cache --build-arg=SOURCE_IMAGE=$SOURCE_IMAGE"
CONTAINER_NAME="${POD_NAME:-vires-server}--aeolus"
#    --volume ../../../VirES-Server_alt:/usr/local/vires \
CREATE_OPTIONS="\
    --pod $POD_NAME \
    --volume ../../../Aeolus-Server:/usr/local/aeolus \
    --volume ../../../VirES-Server:/usr/local/vires \
    --volume ../../../eoxserver:/usr/local/eoxserver \
    --volume ../../../WPS-Backend:/usr/local/eoxs_wps_async \
    --volume ../../../vires_sync:/usr/local/vires_sync \
    --volume ../../contrib/Aeolus-Client.tar.gz:/srv/vires/sources/Aeolus-Client.tar.gz:ro \
    --volume ../../branding/static:/srv/vires/sources/static:ro \
    --volume ../../branding/templates:/srv/vires/sources/templates:ro \
    --volume ../../config:/srv/vires/sources/config:ro \
    --volume ./volumes/secrets/aeolus.conf:/srv/vires/secrets.conf:ro \
    --volume ./volumes/secrets/oauth_aeolus.conf:/srv/vires/vires.conf:ro \
    --volume ./volumes/options.conf:/srv/vires/options.conf:ro \
    --volume ./volumes/home:/srv/vires/home\
    --volume ./volumes/logs/aeolus:/var/log/vires/aeolus \
    --volume ./volumes/aeolus:/srv/vires/aeolus \
    --volume ${POD_NAME:-vires-server}--aeolus-static:/srv/vires/aeolus_static \
    --volume ${POD_NAME:-vires-server}--aeolus-upload:/srv/vires/upload \
    --volume ${POD_NAME:-vires-server}--aeolus-wps:/srv/vires/wps \
    --volume $AEOLUS_DATA:/srv/vires/data:ro \
"
EXEC_OPTIONS="--user vires"
RUN_OPTIONS="$CREATE_OPTIONS --entrypoint /bin/bash"
