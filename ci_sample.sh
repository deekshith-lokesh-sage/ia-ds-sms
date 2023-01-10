#!/usr/bin/env bash


aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin 827126933480.dkr.ecr.us-west-2.amazonaws.com/ia-ds
## Sample Settings path
# the bootstrap.sh script run by skaffold will pick it up
export M2_EXT_ARGS="-s ~/.m2/settings.xml -Dmaven.repo.local=~/.m2/repository/"

## optional docker volume setup for credentials; skaffold will run it as a pre-build hook anyway
./bootstrap.sh

## build images and push to registry:
skaffold build


## build the kubernetes manifests
# --offline=true to run without connecting to k8s cluster

SKAFFOLD_OUTPUT_FILE=ds-template.yml
skaffold render --offline=true --output=$SKAFFOLD_OUTPUT_FILE