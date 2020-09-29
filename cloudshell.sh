#!/bin/bash
# gcloud auth revoke --all

# while [[ -z "$(gcloud config get-value core/account)" ]]; 
# do echo "waiting login" && sleep 2; 
# done

# while [[ -z "$(gcloud config get-value project)" ]]; 
# do echo "waiting project" && sleep 2; 
# done


# gcloud config set compute/zone us-central1-a 
# gcloud container clusters create echo-cluster \
# --num-nodes 2 \
# --machine-type n1-standard-2


gcloud container clusters get-credentials echo-cluster --zone=us-central1-a


kubectl create deployment echo-web --image=gcr.io/qwiklabs-resources/echo-app:v1

kubectl expose deployment echo-web --type=LoadBalancer --port 80 --target-port 8000


export PROJECT_ID=$(gcloud info --format='value(config.project)')

gsutil cp gs://${PROJECT_ID}/echo-web-v2.tar.gz .
tar -xvzf echo-web-v2.tar.gz
# cd echo

docker build -t echo-app:v2 .
docker tag echo-app:v2 gcr.io/${PROJECT_ID}/echo-app:v2
docker push gcr.io/${PROJECT_ID}/echo-app:v2


kubectl set image deployment/echo-web echo-app=gcr.io/${PROJECT_ID}/echo-app:v2

kubectl scale --replicas=2 deployment/echo-web

export EXTERNAL_IP=$(kubectl get service echo-web | awk 'BEGIN { cnt=0; } { cnt+=1; if (cnt > 1) print $4; }')
curl http://$EXTERNAL_IP








