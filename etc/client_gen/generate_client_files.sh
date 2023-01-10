#!/usr/bin/env bash

usage(){
  echo "valid flags: [-a api.package.name -m model.pacakge.name -c config.package.name -s path/to/spec]"
  exit 0;
}

OPEN_API_SPEC=../../target/ia-resources/openapi.json

cmd=openapi-generator-cli
[[ $(type -P "$cmd") ]] && echo "$cmd is in PATH"  ||
    { echo "$cmd is NOT in PATH" 1>&2; exit 1; }


modelPackage=com.intacct.ds.client.model
apiPackage=com.intacct.ds.client.api
configPackage=com.intacct.ds.client.config

while getopts "a:m:c:s:h" flag
do
    case "${flag}" in
        a)
          apiPackage=${OPTARG}
          echo "api pacakge set to $apiPackage"
          ;;
        m)
          modelPackage=${OPTARG}
          echo "model pacakge set to $apiPackage"
          ;;
        c)
          configPackage=${OPTARG}
          echo "conf pacakge set to $apiPackage"
          ;;
        s)
          $OPEN_API_SPEC=${OPTARG}
          echo "looking for api spec at: $OPEN_API_SPEC"
          ;;
        h | *)
          usage
          exit 0
          ;;
    esac
done

FILE=$OPEN_API_SPEC
if [ -f "$FILE" ]; then
    echo "$FILE exists."

else
  echo "$FILE does not exist; aborting;" 1>&2
  exit 1;
fi

## generate the Feign client (just model and api)
openapi-generator-cli generate -c ia-feign.yml -i "$OPEN_API_SPEC" --api-package "$apiPackage" --model-package "$modelPackage" --additional-properties configPackage="$configPackage"
[ $? -eq 0 ]  || exit 1;

## cleanup files that we don't care about
CRT_WD=$(pwd)
cd generated_client && find . -type f -name "ApiKeyRequestInterceptor.java" -print0 | xargs rm && cd "$CRT_WD" || return


