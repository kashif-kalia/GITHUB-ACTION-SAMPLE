#!/bin/bash

# Pre-requiste   - docker, aws cli, kubectl etc. 
# Post-execution - update image tags in devops repo - overlays/uat and update any config change and commit and push devops repo. 

tag=$1
repo_server="209258198235.dkr.ecr.ap-south-1.amazonaws.com"
region="ap-south-1"

# build and push - core image
repo_uri="$repo_server/mhb_app/uat/mhb_core"
image_tag="$repo_uri:$tag"
context="./services/core"

cd $context
docker build -t $image_tag . -f ./../../k8s/uat/core/Dockerfile
aws ecr get-login-password --region $region | docker login --username AWS --password-stdin $repo_server
docker push $image_tag

cd ./../../

# build and push - auth image
repo_uri="$repo_server/mhb_app/uat/mhb_auth"
image_tag="$repo_uri:$tag"
context="./services/auth"

cd $context
docker build -t $image_tag . -f ./../../k8s/uat/auth/Dockerfile
aws ecr get-login-password --region $region | docker login --username AWS --password-stdin $repo_server
docker push $image_tag


cd ./../../

# build and push - mongo client with dump
repo_uri="$repo_server/mhb_app/uat/clients/mongo"
image_tag="$repo_uri:5.0.9_$tag"
context="./k8s/uat/mongodb"

cd $context
docker build -t $image_tag . -f ./Dockerfile
docker push $image_tag

cd ./../../../

# build and push - mysql client with dump
repo_uri="$repo_server/mhb_app/uat/clients/mysql"
image_tag="$repo_uri:8.0.30_$tag"
context="./k8s/uat/mysql"

cd $context
docker build -t $image_tag . -f ./Dockerfile
docker push $image_tag
