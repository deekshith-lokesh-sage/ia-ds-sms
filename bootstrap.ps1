$force="false"
if ($($args[0]) -ne $null) {
    if ($($args[0]) -eq "-f") {
        $force="true"
    } else {
        write-host "valid flags: [-f true]"
    }
}

$build="true"
$VOLUMES=docker volume ls --filter name=bindings -q
$retVal=$?
if ($retVal -ne $TRUE) {
    write-host "cannot retrieve volume info from docker daemon, exiting"
    exit 1
}

if (($VOLUMES -eq "bindings") -and ($force -ne "true")) {
    write-host "volume exists"
    $build="false"
}

# ADDTL_MVN_ARGS=
# if [ ! -z "${M2_EXT_ARGS}" ]; then
#   ADDTL_MVN_ARGS=$M2_EXT_ARGS
#   echo "using ADDTL_MVN_ARGS=$ADDTL_MVN_ARGS"
# fi

if ($build -eq "true") {
    docker volume create bindings
    $retVal=$?
    if ($retVal -ne $TRUE) {
        write-host "cannot create volume 'bindings', exiting"
        exit 1
    }

    mvn help:effective-settings replacer:replace -Partifactory -Psettings-replacer -DshowPasswords=true -Doutput="bindings/maven/settings.xml"
#     mvn help:effective-settings replacer:replace -Psettings-replacer -DshowPasswords=true -Doutput=bindings/maven/settings.xml $ADDTL_MVN_ARGS
    $retVal=$?
    if ($retVal -ne $TRUE) {
        write-host "cannot retrieve generate maven settings"
        docker volume rm bindings
        exit 1
    }

    $bindingsPath=($pwd.Path)+"\bindings:/source:rw"
    docker run --rm --volume bindings:/bindings:rw --volume $bindingsPath bash -c "cp -fr /source/* /bindings/"
    $retVal=$?
    if ($retVal -ne $TRUE) {
        write-host "cannot copy settings file to bindings volume"
        docker volume rm bindings
        exit 1
    }

#    Remove-Item .\bindings\maven\settings.xml
}
