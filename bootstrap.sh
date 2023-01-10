#!/usr/bin/env bash

force="false"
while getopts f: flag
do
    case "${flag}" in
        f) force="true";;
        *) echo "valid flags: [-f true]"
    esac
done

build="true"
VOLUMES=$(docker volume ls --filter name=bindings -q)
retVal=$?
if [ $retVal -ne 0 ]; then
    echo "cannot retrieve volume info from docker daemon, exiting"
    exit 1
fi
if [ "$VOLUMES" == "bindings" ] && [ ! "$force" == "true" ]; then
  echo "volume exists"
  build="false"
fi

ADDTL_MVN_ARGS=
if [ ! -z "${M2_EXT_ARGS}" ]; then
  ADDTL_MVN_ARGS=$M2_EXT_ARGS
  echo "using ADDTL_MVN_ARGS=$ADDTL_MVN_ARGS"
fi


if [ "$build" == "true" ]; then

docker volume create bindings
retVal=$?
if [ $retVal -ne 0 ]; then
    echo "cannot create volume 'bindings', exiting"
    exit 1
fi
mvn help:effective-settings replacer:replace -Psettings-replacer -DshowPasswords=true -Doutput=bindings/maven/settings.xml $ADDTL_MVN_ARGS
retVal=$?
if [ $retVal -ne 0 ]; then
    echo "cannot retrieve generate maven settings"
    exit 1
fi

docker run --rm \
    --volume bindings:/bindings:rw \
    --volume $(pwd)/bindings:/source:rw \
    bash -c 'cp -fr /source/* /bindings/'
retVal=$?
if [ $retVal -ne 0 ]; then
    echo "cannot copy settings file to bindings volume"
    exit 1
fi

rm bindings/maven/settings.xml
fi

