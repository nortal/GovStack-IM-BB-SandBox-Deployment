# GovStack Sandbox - Information Mediator (X-Road with X-Road Metrics)

This is a _preconfigured_ setup of X-Road packaged as a Helm application, intended to be deployed 
into the Govstack Sandbox. The setup should not be exposed to public internet.

The setup consist of the following components:

- Preconfigured Docker images (in `images` directory) based on NIIS X-Road Central Server and X-Road Security 
  Server Sidecar 7.2.2
    - For more information about X-Road, see http://x-road.global
- Helm Chart (in `sandbox-im-x-road` directory) for deploying the X-Road security server applications to a 
  Kubernetes cluster
- Helm Chart (in `x-road-metrics` directory) for deploying the X-Road Metrics into a kubernetes cluster
  - For more information about X-Road Metrics, see 
  https://github.com/nordic-institute/X-Road-Metrics/tree/develop/docs

The application has the following components:

- X-Road Central Server (sandbox-xroad-cs)
    - X-Road instance id: SANDBOX
    - The Central Server includes a simple Test CA running in port 8888/HTTP
- Three X-Road Security Servers
    - sandbox-xroad-ss1 - management server
        - server id: SANDBOX/GOV/MANAGEMENT/SS1
    - sandbox-xroad-ss2 - consumer server
        - server id: SANDBOX/ORG/CLIENT/SS2
    - sandbox-xroad-ss3 - provider server
        - server  id: SANDBOX/GOV/PROVIDER/SS3
- Preconfigured subsystems:
    - SANDBOX/GOV/MGMT/MANAGEMENT (registered on SS1)
        - for management services
    - SANDBOX/ORG/CLIENT/TEST (registered on SS2)
    - SANDBOX/GOV/PROVIDER/TEST (registered on SS3)
- A single X-Road Metrics distributed application setup for collecting operational monitoring data from the 
  ss3 security server
  - The X-Road Metrics setup consists of the following components:
    - X-Road Metrics Collector
    - X-Road Metrics Corrector
    - X-Road Metrics Database

Admin interfaces have a preregistered admin user with username `xrd` and password `secret`. Software token 
pin code is `1234` in the packaged configuration.

## Quickstart

### Build preconfigured X-Road images 

Build and push images to a registry that can be accessed by the Sandbox. The build script creates several 
images and pushes those to `<registry base url>/im/x-road/(securty-server|central-server)`

```
images/docker-build.sh -r <registry base url> -p
```

The default preconfigured images use official X-Road images as base images. In order to build images with IAM
authentication support, the GovStack IM-BB X-Road git repository must be present. The `images/docker-build.sh` script
has an additional step for building the X-Road Security Server application jar file and injecting it into the
security-server ss1, ss2 and ss3 images at build time.

Download the GovStack IM-BB X-Road repository into your build environment. When executing the X-Road image build
script, provide the path to the x-road directory as the `-x` parameter.

```
images/docker-build.sh -p \
  -r <registry base url> \
  -t 7.2.2-IAM \ 
  -x /home/username/projects/X-Road-GovStack
```


### Install the X-Road chart to a Sandbox. 

The chart assumes that the cluster supports dynamic volume provisioning with sensible defaults. If that is 
not the case, the various volumes need to be manually provisioned.

```
helm install --atomic \
    --wait --timeout 15m \
    --create-namespace \
    --namespace "sandbox-im" \
    --set-string xroad-ss.tokenPin="1234" \
    --set-string xroad-cs.tokenPin="1234" \
    --set-string global.registry="<registry base url>" \
    sandbox-im-xroad ./x-road/sandbox-im-x-road
```

### Build X-Road Metrics images

The docker build files for Sandbox specific X-Road Metrics application are available in the GovStack IM-BB 
X-Road Metrics repository. The build script `build_images.sh` is used to push images to a registry that can be 
accessed by the Sandbox. 

```
./build_imbb_images.sh \ 
  --registry my-bb-docker-registry.com/im/xroad-metrics \
  --tag 1.0.0
```

### Install X-Road Metrics chart to a Sandbox

X-Road-Metrics helm chart has been created with the assumption that is will be deployed to the same namespace as the
X-Road chart. Access for X-Road-Metrics to the X-Road security and central servers is by default based on 
kubernetes service names. These urls can be overridden in chart configuration.

```
helm install --atomic \
    --wait --timeout 15m \
    --create-namespace \
    --namespace "sandbox-im" \
    x-road-metrics ./x-road/x-road-metrics
```

### After the X-Road install finishes

#### Access the installed interfaces 

One can access the interfaces e.g. with port forwarding.

```
kubectl port-forward \
    -n sandbox-im \
    service/sandbox-xroad-ss2 4000 8443
```

#### Query the test service

There is also a pre-defined test service which can be used to check that the deployment was successful. Assuming the previous port-forward:

```
curl --fail-with-body -k \
    -HX-Road-Client:SANDBOX/ORG/CLIENT/TEST \
    https:/localhost:8443/r1/SANDBOX/GOV/PROVIDER/TEST/health/
```
