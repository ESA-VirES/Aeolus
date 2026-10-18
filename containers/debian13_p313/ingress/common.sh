SOURCE_IMAGE_NAME="debian13"
SOURCE_IMAGE="$REGISTRY/$SOURCE_IMAGE_NAME:$IMAGE_TAG"

IMAGE_NAME="debian13-apache"
IMAGE="$REGISTRY/$IMAGE_NAME:$IMAGE_TAG"

BUILD_OPTIONS="--squash --no-cache --build-arg=SOURCE_IMAGE=$SOURCE_IMAGE"
CONTAINER_NAME="${POD_NAME:-vires-server}--ingress"
CREATE_OPTIONS="\
    --pod $POD_NAME \
    --volume ${POD_NAME:-vires-server}--oauth-static:/var/www/vires/oauth_static:ro \
    --volume ${POD_NAME:-vires-server}--aeolus-static:/var/www/vires/aeolus_static:ro \
    --volume ${POD_NAME:-vires-server}--aeolus-wps:/var/www/vires/aeolus_wps:ro \
    --volume ./ingress/vires.conf:/etc/apache2/sites-enabled/vires.conf:ro \
    --volume ./volumes/logs/httpd:/var/log/vires/httpd \
"
