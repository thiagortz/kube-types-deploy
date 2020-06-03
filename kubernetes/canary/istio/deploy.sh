#!/bin/bash

end=$((SECONDS+30))

apply_canary(){
    kubectl apply -f ./kubernetes/istio/canary/api.yaml
    kubectl rollout status deployment/my-app-canary

    kubectl apply -f ./kubernetes/istio/canary/destination-rules/destination-rule-release.yaml
    kubectl rollout status destinationrule/my-app

    kubectl apply -f ./kubernetes/istio/canary/virtual-services/virtual-service-release.yaml
    kubectl rollout status virtualservice/my-app
}

health_check(){
    while [ $SECONDS -lt $end ]; do
        status_code=$(curl --write-out %{http_code} --silent --output /dev/null $HOST)

        if [ "$status_code" == 200 ] ; then
            echo "  Return of health validation $status_code"
            ok=true
        else
            echo "  New version integrity validation failed :  StatusCode $status_code"
            ok=false
            break
        fi
    done
}

promote_release(){
    if [ "$1" = true ] ; then
        echo "  Promoting new version of the api"

        kubectl set image deployment/my-app-production my-app=myapp:$VERSION
        kubectl rollout status deployment/my-app-production

        kubectl apply -f ./kubernetes/istio/canary/destination-rules/destination-rule.yaml
        kubectl rollout status destinationrule/my-app

        kubectl apply -f ./kubernetes/istio/canary/virtual-services/virtual-service.yaml
        kubectl rollout status virtualservice/my-app

        kubectl delete deployment my-app-canary
    else
        roll_back
    fi

}

roll_back(){
    echo "  Rollback to stable version"
    kubectl apply -f ./kubernetes/istio/canary/destination-rules/destination-rule.yaml
    kubectl rollout status destinationrule/my-app

    kubectl apply -f ./kubernetes/istio/canary/virtual-services/virtual-service.yaml
    kubectl rollout status virtualservice/my-app

    kubectl delete deployment my-app-canary
}

apply_canary
health_check
promote_release $ok
