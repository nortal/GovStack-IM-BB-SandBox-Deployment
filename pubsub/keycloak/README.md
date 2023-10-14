## Keycloak Setup with Kubernetes

### Prerequisites

- A local Kubernetes cluster running (im-bb-dev-cluster, set up in shown in ../README.md

### Package and install the Keycloak Helm chart
```sh
helm install keycloak-chart .
```

### Accessing Keycloak
Monitor the Keycloak pod until it's running (takes a while):

```sh
kubectl describe pod -l app=keycloak
```

#### Uninstalling Keycloak
```sh
helm uninstall keycloak-chart
```


## Accessing the Keycloak Admin Console
To access the UI, you need to have an entry in your hosts file for localhost
Once the pod is running, you can access the Keycloak Admin Console from your browser at `http://127.0.0.1:8089/admin/` using the credentials `admin` / `admin`.

Alternatively, put an entry to your hosts file pointing to 127.0.0.1, for example
```sh
127.0.0.1 pubsub.test
```
and access the Admin Console from `http://pubsub.test:8089/admin/`


Example login flow through endpoints:
```
GET (in browser) http://pubsub.test:8089/realms/pubsub-realm/protocol/openid-connect/auth?response_type=code&client_id=pubsub-component
```
Example username `registration-officer`, password `registration-officer`. More example users can be found in `config/pubsub-realm.json` under "users"

You will be redirected to a localhost page where there is probably no service yet, but from the URI, copy the code parameter and use it in the following request:
```
POST http://pubsub.test:8089/realms/pubsub-realm/protocol/openid-connect/token

with body (type x-www-form-urlencoded):
x-www-form-urlencoded
code:{{COPIED_CODE_FROM_URI}}
client_id:pubsub-component
client_secret:pubsub-component-secret
redirect_uri:http://localhost:8081
grant_type:authorization_code
```
