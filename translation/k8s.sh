#!/bin/bash
#Module: Containers in the Cloud
#GCP Fundamentals: Getting Started with Kubernetes Engine - 

#Task 3: Start a Kubernetes Engine cluster

gcloud alpha cloud-shell ssh # ssh to cloud shell

export MY_ZONE=us-central1-a
gcloud container clusters create webfrontend --zone $MY_ZONE --num-nodes 2
kubectl version

#Task 4: Run and deploy a container

kubectl create deploy nginx --image=nginx:1.17.10
kubectl get pods
kubectl expose deployment nginx --port 80 --type LoadBalancer
kubectl expose deployment nginx --port 80 --type LoadBalancer
kubectl scale deployment nginx --replicas 3
kubectl get pods
kubectl get services

