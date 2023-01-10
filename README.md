# ia-ds-template

### Requirements for running the project


### Package managers for initial setup
Optional package managers to help installing dependencies:
* [Chocolatey package manager](https://chocolatey.org/install) - windows only
* [brew package manager](https://brew.sh) - MacOS


### Required software:
* IntelliJ
* Java 11 (verify that $JAVA_HOME is set otherwise export JAVA_HOME=\`/usr/libexec/java_home\`)
* Maven 
* [Skaffold package](https://community.chocolatey.org/packages/skaffold)
* [Docker desktop](https://www.docker.com/products/docker-desktop)
* [Helm](https://helm.sh/)
* Kubernetes cluster (docker desktop can be used until EOY 2021, activate using Preferences => Kubernetes => Enable Kubernetes)
* Istio.

### Setup:
Docker desktop should be installed and the bundled k8s cluster is up and running.
```shell
kubectl get pods -A
```
should show the pods in the kube-system namespace.

Java 11 - any jdk 11 will do. Our build process uses Bellsoft Liberica JDK, but any other dist will do.
maven, skaffold and helm can be installed with package managers:

```shell
brew install openjdk@11 maven skaffold helm
```

or similarly with choco on Windows, e.g.:

```powershell
choco install skaffold
```

#### Istio:
This will only work for *nix systems so, Macos, Linux or for Windows a running WSL distro will do (Ubuntu/Centos/fedora/etc..).
Follow the official installation guide and use 'default' profile: [Istio install - istioctl](https://istio.io/latest/docs/setup/install/istioctl/)

e.g:

download istio, then follow instructions printed by script (adding istio/bin folder to path is advised). then run istioctl install

```shell
curl -L https://istio.io/downloadIstio | sh -
```

in the istio directory that was just pulled, cd into the bin directory 
```shell
istioctl install --set profile=default
kubectl label namespace default istio-injection=enabled --overwrite
```

validate the deployment as described in the istio documentation

Optional: you can deploy the istio sample monitoring stack containing zipkin, grafana, prometheus and kiali;
In the istio folder run:
```shell
kubectl apply -f samples/addons
```


## One time setup for application repo:

### Bindings volume
In order to set up the bindings volume used by the buildpack called by skaffold:
```shell
./bootstrap.sh
```
check if docker volume exists:
```shell
docker volume ls -f name=bindings
```

### Helm repo
In order for the deployment to run we need to access the helm chart in our artifactory helm repo, with your artifactory credentials (replace $USERNAME by your username and $PASSWORD by your password).
```shell
helm repo add ia-helm https://intacct.jfrog.io/artifactory/ia-helm/ --username=$USERNAME --password=$PASSWORD
```

### Ingress gateway
We use a specific name for the ingress gw in our deployments, so we need to apply the resource:
```shell
kubectl apply -f ./k8s/ia-ds-gateway.yaml
```

## IntelliJ setup
The easiest way to use skaffold on a local environment is through the Google cloud code Intellij plugin [here](https://plugins.jetbrains.com/plugin/8079-cloud-code)

[Full plugin documentation](https://cloud.google.com/code/docs/intellij/how-to)


Normally intellij should prompt to generate the run configurations for you from the ./skaffold.yaml file. If this doesn't happen, you can add one manually:

1. Run -> Edit Configurations -> "+"

2. Select "Cloud Code: Kubernetes" to create a new configuration.

You can set up the following details:

Name: Develop on Kubernetes

On the Run tab:

Deployment
- Deploy to current context ( should be docker-desktop / minikube )
- Watch mode: On demand ( this will make skaffold run rebuild only when requested by the user )

On the Build/Deploy tab:

You should point it to the skaffold.yaml file and select the "Local" deployment profile. This will set up skaffold to deploy the required ia-ds-secret secret with the rest of the application.
No other changes should be required.

At this point you can select the configuration and either run or debug the application.


## Repo structure
Key files that are used for building/ deploying the application
./

- bootstrap.sh   - bootstrap script for *nix which creates a bindings volume containing the maven settings.xml from the user's settings
- bootstrap.ps1  - windows equivalent of the script above
- skaffold.yaml  - main skaffold config file; describes build and deploy process for the application
- src/*  - main source folder
- k8s/ia-ds-secret.yaml  - secret used for local deployments
- helm/values.yaml - values file used with helm chart; this is application specific

### skaffold.yaml contents
the key fields in this file are:
- metadata.name: &app-name ia-ds-template  -- specifies the applicaiton name; should be unique per domain service
- build -- section describing build recipes for all artifacts
- build.artifacts[0].image  -- specifies the applications ecr
- build.artifacts[0].buildpacks.builder -- buildpack image used for the application; [paketo buildpack for java](https://paketo.io/docs/howto/java/)
- deploy.helm.releases[0].version  -- specifies the version of the helm chart to be used; this could be upgraded in the future
One note: pay close attention to use the yaml anchors as they are set up in ds-template. they propagate the app name and image name across the skaffold config to reduce the risk of copy-paste errors/typos.

### helm values file
Main configuration file defining how the application is deployed on K8s; this file is also pushed by CI to do-applications for deployments to all dev and superior environments

the key fields/sections in this file are:
- appName -- the name of the application; also used in the deployment
- nameOverride -- should match above
- deployment.container  -- main section with deployment details used for the applicaiton's pod
- deployment.container.name  -- container name within the pod; ideally should match application name
- deployment.container.ports -- additional ports exposed by the application; a service is also generated from this array; normally should be empty. The chart exposes the http and management ports by default.
- deployment.container.resources -- cpu and memory resource requirements and limits for the applicaiton; defaults should suit most scenarios with a 200 threadpool
- rbac.create  -- enables creation of RBAC resoures; when working locally this can be switched off as we don't normally run RBAC
- gateway:   -- should match the name of the istio gateway; in our case it normally is set up as ia-ds-gateway in istio-system namespace
- ingress:   -- used in deployments from do-applications; locally we can have it set to false as skaffold automatically sets up port forwarding for the application
- hpa:       -- horizontal pod autoscaler; should always be off in local deployments
- prometheus:  -- enables annotations and config for metrics exporter; if prometheus is deloyed in the cluster it should scrape the metrics automatically

in order to see more details on how these values are used, you can look through the [ds-boot-chart](https://github.com/intacct/ia-helm-charts/tree/main/charts/ds-boot-chart)



## Code

Start by looking at the provided dummy object implementation:
* [Dummy object definition](src/main/resources/objects/dummy/dummy_object.json)
* [Supporting table definition](src/main/resources/tables/vendor_table.json)
* [Dummy object DTO](src/main/java/com/intacct/ds/model/Dummy.java)
* [Dummy service](src/main/java/com/intacct/ds/service/DummyService.java)
* [Unit test](src/test/java/com/intacct/ds/DsApplicationTests.java)
* [Dummy API schema](src/main/resources/api/openapispec/ap/models/dummy.s1.schema.json)
* [Dummy API schema history](src/main/resources/api/openapispec/ap/history/dummy.schema.history.json)

Simple API to test functionality: obtain a valid OAuth2 code for our API using the linked PHP sandbox, then execute:
```GET http://127.0.0.1:8090/api/v0/objects/dummy/1```. The default PHP sandbox, linked in application.yml, is ```https://dev20.intacct.com/users/vcrisan/git.ia-app/api```

We recommend deleting the Dummy files from the project after you have started creating your own objects and services.
