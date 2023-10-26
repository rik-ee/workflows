#!/bin/bash

#  Required env vars:
#   1) IMAGE_TYPE: ${{ inputs.image_type }}
#   2) TAG_BRANCH: ${{ inputs.tag_branch }}
#   3) APP_VERSION: ${{ inputs.app_version }}

export TZ="Europe/Tallinn"
TIMESTAMP=$(date +'%Y%m%d%H%M%S')

if [[ "$IMAGE_TYPE" == "base" ]]; then
    echo "FIRST_TAG=latest" >> $GITHUB_ENV
    echo "SECOND_TAG=${TIMESTAMP}" >> $GITHUB_ENV
elif [[ "$IMAGE_TYPE" == "deployment" ]]; then
    SHORT_SHA=$(git rev-parse --short=7 HEAD)

    echo "FIRST_TAG=${TAG_BRANCH}-latest" >> $GITHUB_ENV
    echo "SECOND_TAG=${TAG_BRANCH}-${SHORT_SHA}-${TIMESTAMP}" >> $GITHUB_ENV

    if [[ -n "$APP_VERSION" ]]; then
        echo "THIRD_TAG=${TAG_BRANCH}-${APP_VERSION}" >> $GITHUB_ENV
    fi
fi
