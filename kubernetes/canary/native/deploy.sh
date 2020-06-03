#!/bin/bash

end=$((SECONDS+30))

apply_canary(){
    kubectl apply -f ./kubernetes/canary/native/my-app.yaml
    kubectl rollout status deployment/my-app-canary
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

        kubectl delete deploy my-app-canary
    else
        roll_back
    fi

}

roll_back(){
    echo "  Rollback to stable version"
    kubectl delete deployment my-app-canary
}

apply_canary
health_check
promote_release $ok
