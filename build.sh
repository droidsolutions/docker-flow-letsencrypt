#!/usr/bin/env bash

GIT_BRANCH="develop"
DOCKER_TAG="develop"

NEXT_TAG=0
NEXT_BRANCH=0

BUILD=0
NO_CACHE=0
PUSH=0

# Use -gt 1 to consume two arguments per pass in the loop (e.g. each
# argument has a corresponding value to go with it).
# Use -gt 0 to consume one or more arguments per pass in the loop (e.g.
# some arguments don't have a corresponding value to go with it such
# as in the --default example).
# note: if this is set to -gt 0 the /etc/hosts part is not recognized ( may be a bug )
while [[ $# -gt 0 ]]
do
    key="$1"

    case $key in
        --no-cache)
            NO_CACHE=1
            echo "NO_CACHE SET"
            shift # past argument
        ;;
        --build)
            BUILD=1
            echo "BUILD SET"
            shift
        ;;
        --push)
            PUSH=1
            echo "PUSH SET"
            shift
        ;;
        --tag)
            NEXT_TAG=1
            shift
        ;;
        *)
            if [ ${NEXT_TAG} -eq 1 ]; then
                DOCKER_TAG=${key}
            fi;
            shift
        ;;
    esac
    #shift # past argument or value
done

echo "=============================================="
echo "= BUILD:       ${BUILD}"
echo "= PUSH:        ${PUSH}"
echo "= DOCKER_TAG:  ${DOCKER_TAG}"
echo "=============================================="

if [ ${BUILD} -eq 1 ]; then
    if [ ${NO_CACHE} -eq 1 ]; then
        CUSTOM_PARAMS="${CUSTOM_PARAMS} --no-cache"
    fi;


    echo "BUILD IMAGE"
    docker build \
        -t registry.kuldig.de:443/droidsolutions/docker-flow-letsencrypt:${DOCKER_TAG} \
        ${CUSTOM_PARAMS} \
        .
fi


# push to repo
if [ ${PUSH} -eq 1 ]; then
    echo "PUSH IMAGE"
    docker push registry.kuldig.de:443/droidsolutions/docker-flow-letsencrypt:${DOCKER_TAG}

fi
