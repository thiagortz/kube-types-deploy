# Canary

### Get ip ingress gateway and set env

```sh
    minikube ip && kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].nodePort}'
```

```sh
export HOST={http://IP:PORT}

```

### Build image

set docker env 

```sh 
    eval $(minikube docker-env)
```

build image 1.0

```sh
    docker build -t myapp:1.0 .
```


change file /api/run.py and build release image 1.1

```sh
    docker build -t myapp:1.1 .
```


### Deploy

```sh
    ./kubernetes/istio/canary/deploy.sh

```
