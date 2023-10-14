Deploys bitnami helm repository and creates LoadBalancer service for external kubernetes access.
See https://github.com/bitnami/charts/tree/main/bitnami/postgresql for possible configuration parameters

```
helm install im-msg-db bitnami/postgresql -f values.yaml
```

> NB! It may take up to a few minutes for the external access port to become available.
