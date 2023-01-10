# ia-ds-template

## Requirements for running the project

Optional package managers to help installing dependencies:
* [Chocolatey package manager](https://chocolatey.org/install) - windows only
* [brew package manager](https://brew.sh) - MacOS

Required software:
* Java 11 (verify that $JAVA_HOME is set otherwise export JAVA_HOME=\`/usr/libexec/java_home\`)
* Maven (brew install mvn)
* [Skaffold package](https://community.chocolatey.org/packages/skaffold)
* [Docker desktop](https://www.docker.com/products/docker-desktop)
* [Helm](https://helm.sh/)
* Kubernetes cluster (docker desktop can be used until EOY 2021, activate using Preferences => Kubernetes => Enable Kubernetes)
* Istio. See [instructions below](#istio-setup)
* metrics server deployed on the cluster [instructions here](https://github.com/kubernetes-sigs/metrics-server)
* openapi-generator-cli (only  for api generation ) - [official instructions](https://openapi-generator.tech/docs/installation) 

## Project contents - dependencies

* ia-core-fmwk
* Spring Boot, Spring boot starter actuator / web / devtools / test
    * web MVC used as application container
    * actuator for probes, metrics, jmx, etc.
    * devtools for live class reloading in debug
    * test standard Junit 5 test runner
* Spring cloud kubernetes client
  * kubernetes API interaction - used for pulling configuration from configMaps and secrets; discovery should be disabled
* Lombok
* Jolokia
  * enable JMX over HTTP through actuator
* SpringDoc
  * OpenAPI 3 documentation for exposed APIs
* Micrometer
  * metrics framework to expose through actuator or push to metric server (depending on target metric platform)
* k8s config files `k8s/config.yml`, `k8s/deploy.yml`, ...
* skaffold config file `skaffold.yml`
* dummy endpoint `http://localhost:8090/ia/api/v0/objects/dummy`

## Steps to start from the template

### forking git repo and renaming application
all occurrences of ds-template or ds application should be replaced to match the new domain service name:
* pom.xml - artifact id, name, description
  * src/main/resources/application.yml -> 
  `spring.application.name` should be updated with the application name; this should be == to helm.yaml  `nameOverride`
  
  `spring.messages.basename` should be filled with a comma separated list of paths 
  to internationalized messages (if you have a `langFolder` like described in the next bullet, then you should add
  `langFolder.messages`; also, if you want to use messages from 
  `ia-core-framework`, then you should add `lang.messages` since 
  they are stored in `lang` folder)
* src/main/resources/langFolder -> `langFolder` can be renamed
according to user preferences; it is the folder that
points to the bundle of `messages.properties` files
(coupled to the internationalized messages used
in the project); the folder should contain
files with different endings (`_en`, `_de`, `_fr`, 
`_ro` etc.) that express messages in different languages
* source code: rename DsApplication to your preffered domainService name and add a package inside `com.intacct.ds` for your domain. Your service structure should reside under this package.
* source code: Add a package inside `com.intacct.ds` for your domain. Your service structure should reside under this package.
* skaffold.yml - image name
* k8s/*.yaml - ALL occurrences. The Deployment, Horizontal Pod Autoscaler, Service manifests (names + image references) should be unique to the application and consistent. The config map should have the same name as `spring.application.name`
* shell scripts: rename the ds-template by the name of your app

### Github & maven

At this step we are setting up the project, and the maven modules where we will develop our domain service and its client.

* Copy the template files into your new project. Make sure to copy the .gitignore file too!  (TODO: the core team will set up the template as Github repository template from which the specific domain projects would be crated)
* Edit `pom.xml` and replace all occurrences of `ia-ds-template` with the name of your domain service which should match the Github repository name. For example, `ia-ds-ap`, `ia-ds-fa`, ...
* Search for the `<description>` tags in the above pom file and update the text to match your project's description.
* Update the version of `ia-core` dependency in project's `pom.xml` file to the latest available in our maven repository.

At this point you should be able to refresh the maven project in your IDE and also to run `mvn compile` or `mvn package` on your new domain service project.

### Skaffold

Official docs [here](https://skaffold.dev/docs/)

The fastest way to get the app running is by executing `skaffold dev --port-forward` in a terminal. This option enables continuous local development where changing a file will trigger an image build. If you're using Windows OS you need to use the following workaround
- delete bindings volume from Doker
- run bootstrap.sh1 in terminal
- execute skaffold dev --port-forward in a terminal

For debugging we will use [Cloud Code](https://plugins.jetbrains.com/plugin/8079-cloud-code) plugin for Intellij.
Select the "Develop on Kubernetes" run configuration and hit the Debug button.
Similary hitting the run option will start the application in continuous local development mode.

#### skaffold.yaml contents
The template file specifies the following:
* metadata - name of the application
* tag policy is set up to use tags and will fall back to commit id if not on a tag
    * skaffold 'hydrates' the manifest with the generated image name: so if you see `827126933480.dkr.ecr.us-west-2.amazonaws.com/ia-ds-template` in the k8s manifests, skaffold will generate an image, tag it with the commit id and update the manifest for deployment (render phase)
    * typical image naming: `registry/image:<tag/commit id>[-dirty]` where:
        * registry and image name should be set up before development and kept in sync with ./k8s/*.yaml contents
        * tag or commit id is chosen based on the current git status
        * the optional `-dirty` suffix is added when there are uncommitted changes in the repo
* images section defines the OCI artifacts the project produces and the recipes to build them. In our case it's just one image:
    * ds-template image definition
    * pre-build hook is needed to populate a container volume with the maven authentication details. See: `./bootstrap.sh`
    * build section defines how the image is built: in our case using base paketo buildpack, with the volume generated at the prior step mounted for maven auth. The buildpack runs with default settings, hence it will have a jar launcher helper that computes memory spit for current # of classes, an assumed 250 threads. The memory ceiling is set up as equal to the container's max resources
* local section define parameters for local builds. Current setup is to optimize build speed on docker using buildkit
* the deployment section defines all kubernetes manifests to scan, render and apply

### helm
This folder contains the 2 files:
* values.yaml - contains all the details customized for our application template based on [this helm chart](https://github.com/ManagedKube/helm-charts/tree/master/charts/standard-application)
  this file is produced directly as a build artifact

### istio setup
* Go to a directory where you feel comfortable to install the program.
* Download the program and execute it: `curl -L https://istio.io/downloadIstio | sh -`
* Enter in the folder created: `cd istio-X.XX.X` (replace the X by your version)
* Add the path to the Istio binary to your PATH variable: `export PATH=$PWD/bin:$PATH`. Also, add the istio bin folder to the user profile path, in ~/.bash_profile or similar.
* Install istio: `istioctl install --set profile=demo -y`
* Add istio flags and components to kubernetes:
  * Enable the istio sidecar injection on the cluaster/default namespace: `kubectl label namespace default istio-injection=enabled`
  * Install the monitoring addons: `kubectl apply -f samples/addons`
  * Enable kiali in the cluster: `kubectl rollout status deployment/kiali -n istio-system`
* When running services, start the kiali dashboard with : `istioctl dashboard kiali`

### General development workflow:
The application template should run both straight out of maven for tests or just spring-boot:run, but the usual workflow should be through skaffold dev or debug.
Development should not need any skaffold phases outside build, dev and run, but generally dev should be used.

## API client generation:
In order to circumvent a direct framework/jar dependency between projects and force us into complicating release management, we're offering the posibility to generate the rest clients using [OpenApi generator](https://openapi-generator.tech/). 

The files required to generate clients are:
* /target/ia-resources/openapi.json - produced with springdoc maven plugin during integration-test phase of the build
* /etc/client_gen/ - contains scripts, templates and configuration to generate clients
  * feign/ - folder containing the custom openapi-generator templates for spring cloud openfeign
  * ia-feign.yml - configuration file we use for openapi-generator with our default parameters
  * generate_client_files.sh - bash script to generate client (if no parameters specified, it uses defaults)
* /generated_client - target folder including a .ignore file specific to openapi generator  
 
In order to produce the openapi spec and Intacct resources in ```${project.build.directory}/ia-resources``` the ```gen-ext-resources``` profile must be active

The generator will produce a complete file structure in the generated_client folder, containing all the api interfaces, a feing client configuration with Java11 http client set up, as well as all the model classes as defined in the api spec.
Consequently, you should see a folder structure similar to the following output:
```
└── src
    └── main
        └── java
            └── com
                └── intacct
                    └── ds
                        └── client
                            └── dummy
                                ├── api
                                │   ├── DummyControllerApi.java
                                │   └── DummyControllerApiClient.java
                                ├── conf
                                │   └── ClientConfiguration.java
                                └── model
                                    ├── AccountType.java
                                    ├── BooleanType.java
                                    ├── Contact.java
                                    ├── Dummy.java
                                    ├── GLAccount.java
                                    ├── MailAddress.java
                                    ├── SOPriceList.java
                                    ├── SalePurchaseType.java
                                    ├── StatusType.java
                                    ├── TaxGroup.java
                                    ├── TaxGroupType.java
                                    └── TaxSolution.java

11 directories, 15 files
```
#### Client code strucutre:
There are 3 main sets of files generated:
* api - contains an interface with methods corresponding to the REST endpoints defined in the spec, and its paired ApiClient class which is annotated with ```@FeignClient```, with configurable name, url and pre-set configuration class. It should be ready to be ```@Autowired``` as is
* conf - contains the client specific configuration class. Given our requirement for PATCH verbs, a Client bean has been set up from the template to use the Java11 HttpClient
* model - all the model classes as defined in the api spec. These are already set up with Jackson annotations. They should be ready to use as is, but they can be Lombok'd in IntelliJ easily if needed.

All these files are generated in packages specified via config ( defaulted in the script ), and can be overridden with script parameters.

#### Generating feign client code
Scripts must be run from the /etc/client_gen folder:

Running ```./generate_client_files.sh```:

The script can be run as is and will  generate the three pacakges under ```com.intacct.ds.client```
In order to customize the api, model and conf packages.
```shell
./generate_client_files.sh -a com.intacct.ds.client.dummy.api -m com.intacct.ds.client.dummy.model -c com.intacct.ds.client.dummy.conf -s ../../target/ia-resources/openapi.json
```
openapi-generator should be able to work with remote api specs in the form of url to the -s parameter of the script, but it was not tested at the time of writing. 

#### Using the output
After the generation, the files can be copied directly over the service code, similar to doing a 
```cp ./generated_client/src/* ../../src/```
. This is not done automatically since we want to give devs a chance to review; also, the aim is to pick up an api spec from an existing service and generate the client locally and use it in another ds service.
The code should already be organized in the right structure, and should not overwrite existing code. (adjust via script params as needed)
The whole process is based on a "share-nothing" approach commonly used in microservices, so each client of service A will have its copy of the model beans. This is done to prevent breaking changes on API changes.

#### Details on the default settings and how it's set up:
We are using locally kept feign templates to allow customizations specific to our usage, such as the Java11 http client for starters. In order to have them run this way, we currently had to duplicate even the unmodified templates in /etc/client_gen/feign.
In order to edit the templates, these are mustache files and documentation/samples is available in the openapi-gen [customiztion docs](https://openapi-generator.tech/docs/templating) as well as their [github repo](https://github.com/OpenAPITools/openapi-generator) 
Our defaults:
/etc/client_gen/ia-feign.yml is set up to produce clients as close as possible to the shape we want:
- spring cloud feign, not openfeign directly
- using java8 datetime libraries 
- jackson serialization is implicit
- avoid using swagger/openapi/Jackson annotations for nullable, etc.
- generate Java validation annotations, but do not force validation. In the future we'll be able to validate beans vs schema.


### Remaining improvements:
* github action to produce openapi spec and resources as artifact
* adapt Nullable and other contract specifications to our needs  
* move to either .jar openapi generator or docker, in order to lock in the version
* TBD: package generator as a build artifact, so it's "runnable" without having the whole repo.


## CI

At this step we will set up the CI jobs for our domain service project.
There are 2 types of jobs that we are setting up:
1. PR and branch level job. The job will build (and test) each PR submitted. It is also enabled on branches, but the Jenkinsfile is a no-op on branches for now.
2. Main/release level job. This job will build after each commit is pushed to main. It will generate a release-level artifact in artifactory, and it will increment the build number in the snapshot version in main.
3. Github workflow defined in .github/workflows/main.yaml
### Setup the PR & branch job
* Navigate to https://usw-ci-m01.intacct-dev.com/view/NEXTGEN/
* Create a view named as your Github project
* Option 1: In the new view create a multibranch pipeline job. Use the name of the Github project for your job. Follow the model of https://usw-ci-m01.intacct-dev.com/view/NEXTGEN/view/ia-ds-ap/job/ia-ds-ap/configure to configure the new job
* Option 2: 
  * In a separate tab disable the job ia-ds-ap/ia-ds-ap
  * In the newly created view, create a new job as a copy of ia-ds-ap. Update the repository URL to your project's URL.
  * Enable the new job
  * Enable back ia-ds-ap/ia-ds-ap job

### Setup the main/release job
* Navigate to https://usw-ci-m01.intacct-dev.com/view/NEXTGEN/
* Select the same view as for the above step
* In the same view, create a job by copying the job ia-ds-ap-main. Use the name of your Github project followed by the suffix `-main` for the new job name.
In the job's configuration, find the parameter named `APP_NAME` and change its value to match your Github project name.
* Enable both jobs.

### Github PRs status checks

At this step we are enabling Github to block the PR merges until they are successfully built (and tested) in CI.

* Create a (dummy) PR on your project. Don't approve it or merge it yet.
* Manually run a build for the first job, the one named as your Github project. It should find and build the PR.
* Make sure that the job on the PR runs successfully. Troubleshoot as necessary.
* (You might need to require an administrator of your repository to perform this step) Go to Github -> Settings -> Branches.
Edit the `Branch protectino rules` for `main` branch. Check the box `Require status checks to pass before merging` and `Require branches to be up to date before merging`. 
In the search box below these two boxes, find and select the status check named `continuous-integration/jenkins/pr-merge`. Save changes.  
  

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


