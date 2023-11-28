#!/bin/bash

set -e

echo "system user"
eco "...................................................................................................................................................."

echo "Remove old clusters."
k3d registry delete --all && k3d cluster delete --all

echo "Kubernetes k3s cluster"
k3d cluster create k3s --registry-create k3s.localhost:5001 --servers 1 --api-port 6551 --agents 1 -p "30100-30199:30100-30199@server:0"
k3d kubeconfig merge -s k3s
kubectl config get-contexts
kubectl config use-context k3d-k3s

echo "Setup Multi Tenency !!! \n"
helm repo add projectcapsule https://projectcapsule.github.io/charts
downlaod this file https://github.com/projectcapsule/capsule/blob/master/hack/create-user.sh

echo 'manager:
  options:
    forceTenantPrefix: false
    capsuleUserGroups: ["capsule.clastix.io","team1-users","team2-users"]' > values.yaml

helm install capsule projectcapsule/capsule -n capsule-system --create-namespace -f values.yaml

echo "Team1-working space"
kubectl create -f - << EOF
apiVersion: capsule.clastix.io/v1beta2
kind: Tenant
metadata:
  name: team1
spec:
  owners:
  - name: team1-users
    kind: Group
EOF
./create-user.sh krishna team1 team1-users
export KUBECONFIG=krishna-team1.kubeconfig
kubectl create namespace team1-dev
kubectl create namespace team1-stg
kubectl get pods -n team1-dev
kubectl get pods -n team1-stg


echo "Team2-working space"
kubectl create -f - << EOF
apiVersion: capsule.clastix.io/v1beta2
kind: Tenant
metadata:
  name: team2
spec:
  owners:
  - name: team2-users
    kind: Group
EOF
./create-user.sh krishna.km team2 team2-users
export KUBECONFIG=krishna.km-team2.kubeconfig
kubectl create namespace team2-dev
kubectl create namespace team2-stg
kubectl get pods -n team2-dev
kubectl get pods -n team2-stg

echo "oidc user"
eco "...................................................................................................................................................."
echo "setting up keycloak for kubernetes sso"
echo "Kubernetes sso cluster"
k3d cluster create sso --registry-create sso.localhost:5001 --servers 1 --api-port 6551 --agents 1 -p "30100-30199:30100-30199@server:0"
k3d kubeconfig merge -s sso
kubectl config get-contexts
kubectl config use-context k3d-sso

cd keycloak
docker build --build-arg="keycloakVersion=22.0.5" --no-cache -t sso.localhost:5001/keycloak:v0.1 .
docker push sso.localhost:5001/keycloak:v0.1
helm install keycloak chart --set postgres.persistence.enabled=true --set image.registry=sso.localhost:5001 --set image.tag=v0.1 --set service.nodePort="30100"
access keycloak at : http://localhost:30100/sso

client:
k3sKubernetesCluster

https://localhost:8000
https://localhost:6550
https://localhost:18000

k3sKubernetesCluster-audience
groups

curl -k -s http://localhost:30100/sso/realms/K3D/protocol/openid-connect/token \
  -d grant_type=password \
  -d response_type=id_token \
  -d scope=openid \
  -d client_id=k3sKubernetesCluster \
  -d client_secret=6llLRumiFbPku5qEYRsPT1SVdtSpDP6b \
  -d username=admin \
  -d password=Password1 | jq

curl -k -s http://localhost:30100/sso/realms/K3D/protocol/openid-connect/token/introspect \
     -d token=eyJhbGciOiJSUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICJmNDljeW9KNmtkQmc0UnRCeU5EVHQ5Z1A1VnhzbzdaWk9uZlJNY3B4U1o0In0.eyJleHAiOjE3MDExNDc3NDAsImlhdCI6MTcwMTE0NzQ0MCwiYXV0aF90aW1lIjowLCJqdGkiOiIzZmY3MWQ5MS00ZTYwLTQ2NmMtOGVmMi04Y2JjZTA2OTAwMzkiLCJpc3MiOiJodHRwOi8vbG9jYWxob3N0OjMwMTAwL3Nzby9yZWFsbXMvSzNEIiwiYXVkIjoiazNzS3ViZXJuZXRlc0NsdXN0ZXIiLCJzdWIiOiI5NjFkNzZlZi0zOWNjLTRmMTctYTE4Ny0yOWE1NzdjYmQzZDEiLCJ0eXAiOiJJRCIsImF6cCI6Imszc0t1YmVybmV0ZXNDbHVzdGVyIiwic2Vzc2lvbl9zdGF0ZSI6ImVkNTU5ZjM2LWQzOGYtNDVjNS1hOTFhLTg1YTQyNjI4NmZlMSIsImF0X2hhc2giOiJSdVJwcTc1aGhuUzBSRC01Y005UDJ3IiwiYWNyIjoiMSIsInNpZCI6ImVkNTU5ZjM2LWQzOGYtNDVjNS1hOTFhLTg1YTQyNjI4NmZlMSIsImVtYWlsX3ZlcmlmaWVkIjpmYWxzZSwiZ3JvdXBzIjpbImNhcHN1bGUuY2xhc3RpeC5pbyJdLCJwcmVmZXJyZWRfdXNlcm5hbWUiOiJhZG1pbiJ9.LY_0-Ef6J-c2YGaGc4oEMFp9I6PvNsUYTeGiU4Dki6xHZrVtV7oHzRxThKtJ-X0VvP2xa5bSw5XWXnFblddrgaNOA49ZeOtWPGAvsum61ZQLoo4LoWMeWcSgyZiNwrNF-aNjc--4PP4dNultclqhWdIcI7ZKD2pW7das6He5jBFTNqKc2PdhuOhgqElWHWFujpThRtcn2izQU4G5W8hgf1JUtEJifCIps1ecDp0OUqriDx6HxN505x25NjIKTz6ISSop8osn4vsC_xWKEW42kfL9W1N1-qF9GWQtRMoNeMeoyLMbcIhoSp04fPu1SUytbo_BGdldnvLvd2paZJPHyg \
     --user k3sKubernetesCluster:6llLRumiFbPku5qEYRsPT1SVdtSpDP6b | jq


kubectl oidc-login setup \
--oidc-issuer-url=http://localhost:30100/sso/realms/K3D \
--oidc-client-id=k3sKubernetesCluster \
--oidc-client-secret=6llLRumiFbPku5qEYRsPT1SVdtSpDP6b


echo "Kubernetes k3s cluster"
k3d cluster create k3s --servers 1 --api-port 0.0.0.0:6550 --agents 1 --registry-create k3s.localhost:0.0.0.0:5000 --k3s-arg "--kube-apiserver-arg=oidc-issuer-url=http://localhost:30100/sso/realms/K3D@server:0" --k3s-arg "--kube-apiserver-arg=oidc-client-id=k3sKubernetesCluster@server:0" --k3s-arg "--kube-apiserver-arg=oidc-username-claim=email@server:0" --k3s-arg "--kube-apiserver-arg=oidc-groups-claim=groups@server:0" --port "30201-30299:30201-30299@server:0" --port "80:80@loadbalancer" --port "443:443@loadbalancer"

k3d kubeconfig merge -s k3s
kubectl config get-contexts
kubectl config use-context k3d-k3s



