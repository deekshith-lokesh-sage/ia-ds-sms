#! /bin/bash

read -rp "IA DS Repo name (needs to be the same as the GitHub repo name): " repo_name
read -rp "IA DS Repo description: " repo_description
read -rp "Latest version of package 'ia-core' (example of format: 0.0.283): " ia_core_version

sed -i '' "s/# ia-ds-template/# ${repo_name}/g"                                                                                   README.md
sed -i '' "s/ia-ds-template/${repo_name}/g"                                                                                       pom.xml client/pom.xml service/pom.xml
sed -i '' "s/<description>.*<\/description>/<description>${repo_description}<\/description>/g"                                    pom.xml client/pom.xml service/pom.xml
sed -i '' "s/<ia.core.fmwk.version>.*<\/ia.core.fmwk.version>/<ia.core.fmwk.version>${ia_core_version}<\/ia.core.fmwk.version>/g" pom.xml
sed -i '' "s/ds-template/${repo_name:3}/g"                                                                                        helm/values.yaml

domain_service_name=${repo_name:6}
domain_service_folder="${domain_service_name//-//}"
domain_service_path="${domain_service_name//-/.}"

sed -i '' "s/\.template\./\.${domain_service_path}\./g"                                                                           service/src/main/java/com/intacct/ds/template/*/*
sed -i '' "s/directory = \"template\"/directory = \"$(echo "${domain_service_folder}" | sed 's/\//\\\//g')\"/g"                   service/src/main/java/com/intacct/ds/template/model/*
mkdir -p service/src/main/java/com/intacct/ds/"${domain_service_folder}"
mv -f service/src/main/java/com/intacct/ds/template/* service/src/main/java/com/intacct/ds/"${domain_service_folder}"
rm -rf service/src/main/java/com/intacct/ds/template

mkdir -p service/src/main/resources/objects/"${domain_service_folder}"
mv -f service/src/main/resources/objects/template/* service/src/main/resources/objects/"${domain_service_folder}"
rm -rf service/src/main/resources/objects/template

sub_folder_num=$(echo "$domain_service_folder" | grep -o "/" | wc -l)
common_model="..\/common\/models"
for (( i=0; i<sub_folder_num; i++ ))
do
   printf -v common_model "..\/%s" $common_model
done
sed -i '' "s/..\/common\/models/${common_model}/g"                                                                                service/src/main/resources/api/openapispec/template/paths/*

mkdir -p service/src/main/resources/api/openapispec/"${domain_service_folder}"
mv -f service/src/main/resources/api/openapispec/template/* service/src/main/resources/api/openapispec/"${domain_service_folder}"
rm -rf service/src/main/resources/api/openapispec/template/