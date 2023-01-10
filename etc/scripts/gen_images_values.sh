#!/usr/bin/env bash

BUILD_OUTPUT_FILE=$1
TARGET_DIR=$(dirname $BUILD_OUTPUT_FILE)
cp ./helm/values.yaml $TARGET_DIR/helm-values.yaml


cat $BUILD_OUTPUT_FILE

export TAG=$( cat $BUILD_OUTPUT_FILE |jq '.builds | .[0] | .tag' | awk -F '[:"]' '{ printf("%s\n",$3);}')
echo $TAG
yq e -i '.image.tag = strenv(TAG)' $TARGET_DIR/helm-values.yaml

rm "$BUILD_OUTPUT_FILE"

#cp ./helm/values.yaml ./tmp/helm_values.yaml