# Deploying local ActiveMQ Artemis in Kubernetes via helm

### Prerequisites

* Local registry must be running (im-bb-registry.localhost:5000)
* Local cluster must be running(im-bb-dev-cluster), with port forwarded for the service (8161:8161)
  * For setting up both, see [dev/README.md](../README.md)

### Installing and running ActiveMQ Artemis

1. Install ActiveMQ Artemis via helm
```sh
  helm install artemis .
```

2. Wait for the service to be available, for checking the status these commands help:
```sh
  kubectl get deployments
```
```sh
  kubectl describe deployment artemis
```
```sh
  kubectl describe pod artemis
```

3. Access via http://127.0.0.1:8161 (or http://pubsub.test:8161 if you have it set up in your hosts file) (user: admin, password: admin)

4. To uninstall, run
```sh
  helm uninstall artemis
```
