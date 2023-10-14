# 1. Information Mediator Building Block deploy to AWS

**Note: Current implementation is not ready for production-grade environments, only for development!!!**

## 1.1. Introduction

- Deployment orchestration is made using the GitLab pipelines.
- Deployment is built for the AWS EKS (managed Kubernetes)
- Solution implementation consists of two pillars:
  - Preconfigured a X-Road stack with the Central Server (CS), the three Security Servers (SS) and pubsub components
  - Standalone vanilla Security Server (SS) with pubsub components. We could deploy a few instances of it.
- Deployment pipeline supports two separate environments for development out of the box

## 1.2. Initial environment prerequisites

- Create AWS ECR Registry repositories:

  ```bash
  ${AWS_ACCOUNT}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/im/pubsub/management-api
  ${AWS_ACCOUNT}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/im/pubsub/management-ui
  ${AWS_ACCOUNT}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/im/pubsub/messaging-api
  ${AWS_ACCOUNT}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/im/pubsub/schema
  ${AWS_ACCOUNT}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/im/x-road/central-server
  ${AWS_ACCOUNT}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/im/x-road/security-server
  ${AWS_ACCOUNT}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/im/xroad-metrics/collector
  ${AWS_ACCOUNT}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/im/xroad-metrics/corrector
  ${AWS_ACCOUNT}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/im/xroad-metrics/init-db
  ```

- Push Docker images to the AWS ECR repository
  - management-api, management-ui, messaging-api and schema can be built and pushed using `GovStack IM-BB PubSub Component CI/CD pipeline`.
  - For other services the Docker image build and push is done manually.
- Install external-dns utility to AWS EKS cluster.
- Hosted DNS zone (TLD) in Route53.
- Wildcard certificate issued by AWS ACM for TLD in Route53.
- Pipeline expects to see some environment specific variables defined in GitLab WEB interface (Settings -> CI/CD -> Variables):

  | Name                        | Value example                                                                          |
  | --------------------------- | -------------------------------------------------------------------------------------- |
  | AWS_DEFAULT_REGION          | eu-central-1                                                                           |
  | AWS_EKS_CLUSTER_NAME        | GStack-sb-eks-plg                                                                      |
  | AWS_ROLE_ARN                | arn:aws:iam::111111111111:role/GitlabCIRole                                            |
  | K8S_AWS_ACM_CERTIFICATE_ARN | arn:aws:acm:eu-central-1:111111111111:certificate/0d4532d4-ae8e-4b06-a42c-15f95a082b52 |
  | K8S_SUBNET_ALLOW_LIST       | 1.1.1.1/32\,2.2.2.2/32\,3.3.3.3/32                                                     |

  **Note: we should duplicate these environment variables for each env. with it own values**
- Update env. specific parameters (`ENV_NAME` and `K8S_TLD_NAME`) mentioned in workflow rules logic in `.gitlab-ci.yml` file.
- Modify `pubsub/keycloak/config/pubsub-realm-${ENV_NAME}.json` file and replace `${STACK_PREFIX}`, `${K8S_TLD_NAME}` with needed values.
- Pipeline access to AWS accounts organized leveraging OIDC technology.

## 1.3. Deployment

The Deploying is done using this repo GitLab pipeline. The pipeline has input parameters to control where to deploy, to which environment, and which Docker images to use. Out of the box, a deployment to two separate independent environments which could be in separate AWS accounts is supported. There is an option to deploy preconfigured the X-Road stack with the Central Server (CS), the three Security Servers (SS), and pubsub components or a few vanilla SS standalone instances with pubsub as well.

## 1.4. Application endpoints

Please note we use the IP allow list to allow access to all application endpoints only from certain IP addresses defined in `K8S_SUBNET_ALLOW_LIS` variable.

### 1.4.1. Main stack DNS names pattern

```bash
- https://cs.${K8S_TLD_NAME}:4000/
- https://ss1.${K8S_TLD_NAME}:4000/
- https://ss2.${K8S_TLD_NAME}:4000/
- https://ss3.${K8S_TLD_NAME}:4000/
- http://iam.${K8S_TLD_NAME}:8089/
- http://artemis.${K8S_TLD_NAME}:8161/
- http://management-api.${K8S_TLD_NAME}:8080/actuator/health/
- http://management-api.${K8S_TLD_NAME}:8080/swagger-ui/index.html#/
- http://management-ui.${K8S_TLD_NAME}:8080/
- http://messaging-api.${K8S_TLD_NAME}:9000/management/health/
- http://messaging-api.${K8S_TLD_NAME}:8090/swagger-ui/
```

### 1.4.2. Standalone Security Server DNS names pattern

```bash
- https://niis-ss.${$STACK_PREFIX}.${K8S_TLD_NAME}:4000/
- http://iam.${$STACK_PREFIX}.${K8S_TLD_NAME}:8089/
- http://artemis.${$STACK_PREFIX}.${K8S_TLD_NAME}:8161/
- http://management-api.${$STACK_PREFIX}.${K8S_TLD_NAME}:8080/actuator/health/
- http://management-api.${$STACK_PREFIX}.${K8S_TLD_NAME}:8080/swagger-ui/index.html#/
- http://management-ui.${$STACK_PREFIX}.${K8S_TLD_NAME}:8080/
- http://messaging-api.${$STACK_PREFIX}.${K8S_TLD_NAME}:9000/management/health/
- http://messaging-api.${$STACK_PREFIX}.${K8S_TLD_NAME}:8090/swagger-ui/
```
