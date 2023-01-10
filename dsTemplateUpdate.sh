#!/bin/bash

# This script does a poor man job of updating a DS project with the latest version of the DS template.
# The script should be executed inside the root folder of the DS project and invoked frm the ia-ds-template project.
# Executed without parameters, the script only shows a list of files that are different between the template and the specific DS project.

compare="true"
brief="true"
while getopts ":cd" flag
do
    case "${flag}" in
        c) compare="false";;
        d) brief="false";;
        *) echo -e "valid flags: -c -d\n  -c: copy over\n  -d: detail diff\n"
    esac
done

dir=`dirname $0`

if [ "$dir" == "" ]; then
  echo "Cannot find the dirname of the template based on executable path"
  exit 255
else
  TEMPL_DIR="$dir"
  echo "Using template repo from $dir"
fi

FILE_LIST="bootstrap.sh ci_sample.sh mvnw mvnw.cmd project.toml skaffold.yaml src/main/java/com/intacct/Application.java src/main/resources/application.yml"
DIR_LIST=".mvn bindings etc k8s"
EXTRA_LIST="pom.xml"

if [ "$compare" == "true" ]; then
  DIFF_OPTS="-b"
  if [ "$brief" == "true" ]; then
    DIFF_OPTS="$DIFF_OPTS --brief"
  fi
  for f in $FILE_LIST; do
    diff $DIFF_OPTS $TEMPL_DIR/$f $f
  done
  for d in $DIR_LIST; do
    diff $DIFF_OPTS -r $TEMPL_DIR/$d $d
  done
  for f in $EXTRA_LIST; do
    diff $DIFF_OPTS $TEMPL_DIR/$f $f
  done

  echo -e "\n\n Execute the command with -c option to update your project from template"
else

  echo "Copying files over..."

  for f in $FILE_LIST; do
    rm $f
    cp -v -p $TEMPL_DIR/$f $f
  done
  for d in $DIR_LIST; do
    rm -rf $d
    cp -Rv -p $TEMPL_DIR/$d $d
  done

  echo; echo
  for f in $EXTRA_LIST; do
    # rm $f
    # cp -v -p $TEMPL_DIR/$f $f
    echo "Please manually update $f"
    echo "    Run: diff -b $TEMPL_DIR/$f $f "
    echo
    echo "Diff the changed files to restore your project specific settings"
  done
fi
