#!/bin/bash

end=$((SECONDS+30))

apply_canary(){
    kubectl apply -f ./kubernetes/istio/canary/gateway.yaml
    kubectl apply -f ./kubernetes/api
    sleep 10
    kubectl apply -f ./kubernetes/istio/canary/destination-rules/destination-rule-release.yaml
    sleep 10
    kubectl apply -f ./kubernetes/istio/canary/virtual-services/virtual-service-release.yaml

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

        kubectl apply -f ./kubernetes/istio/canary/destination-rules/destination-rule-new.yaml
        kubectl apply -f ./kubernetes/istio/canary/virtual-services/virtual-service-new.yaml

        sleep 20
        kubectl delete deployment my-app-v1
    else
        roll_back
    fi

}

roll_back(){
    echo "  Rollback to stable version"
    kubectl apply -f ./kubernetes/istio/canary/destination-rules/destination-rule-rollback.yaml
    kubectl apply -f ./kubernetes/istio/canary/virtual-services/virtual-service-rollback.yaml
    sleep 20
    
    kubectl delete deployment my-app-v1-1
}

apply_canary
health_check
promote_release $ok
