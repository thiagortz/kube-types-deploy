# Minukube

### Create Minikube

```sh
    minikube start --memory=4096 --cpus=4
```

### Install Istio (Version 1.4.2)

```sh
    istioctl manifest apply --set profile=demo
```

### Enable Sidecard

```sh
   kubectl label namespace default istio-injection=enabled
```


### References

* Minikube [https://kubernetes.io/docs/tasks/tools/install-minikube/]
* Istio [https://istio.io/pt-br/docs/setup/getting-started/]
