#!/bin/bash
#Module: Infrastructure Automation
#Automating the Deployment of Infrastructure Using Deployment Manager - 

#Task 1. Configure the network
#Task 2. Configure the firewall rule


gcloud alpha cloud-shell ssh # ssh to cloud shell
mkdir dminfra
cd dminfra
touch config.yaml
echo "resources:
# Create the auto-mode network
- name: mynetwork
  type: compute.v1.network
  properties:
    autoCreateSubnetworks: true

# Create the firewall rule
- name: mynetwork-allow-http-ssh-rdp-icmp
  type: compute.v1.firewall
  properties:
    network: $(ref.mynetwork.selfLink)
    sourceRanges: ["0.0.0.0/0"]
    allowed:
    - IPProtocol: TCP
      ports: [22, 80, 3389]
    - IPProtocol: ICMP" > config.yaml
touch instance-template.jinja

echo "resources:
- name: {{ env["name"] }}
  type: compute.v1.instance  
  properties:
     machineType: zones/{{ properties["zone"] }}/machineTypes/{{ properties["machineType"] }}
     zone: {{ properties["zone"] }}
     networkInterfaces:
      - network: {{ properties["network"] }}
        subnetwork: {{ properties["subnetwork"] }}
        accessConfigs:
        - name: External NAT
          type: ONE_TO_ONE_NAT
     disks:
      - deviceName: {{ env["name"] }}
        type: PERSISTENT
        boot: true
        autoDelete: true
        initializeParams:
          sourceImage: https://www.googleapis.com/compute/v1/projects/debian-cloud/global/images/family/debian-9" > instance-template.jinja

#Prepend import in config.yaml
echo "imports:
- path: instance-template.jinja" | cat - config.yaml > /tmp/out && mv /tmp/out config.yaml

echo "# Create the mynet-us-vm instance
- name: mynet-us-vm
  type: instance-template.jinja
  properties:
    zone: us-central1-a
    machineType: n1-standard-1
    network: $(ref.mynetwork.selfLink)
    subnetwork: regions/us-central1/subnetworks/mynetwork" >> config.yaml


echo "# Create the mynet-eu-vm instance
- name: mynet-eu-vm
  type: instance-template.jinja
  properties:
    zone: europe-west1-d
    machineType: n1-standard-1
    network: $(ref.mynetwork.selfLink)  
    subnetwork: regions/europe-west1/subnetworks/mynetwork" >> config.yaml


#Deploy
gcloud deployment-manager deployments create dminfra --config=config.yaml --preview
gcloud deployment-manager deployments update dminfra

gcloud compute ssh mynet-us-vm
ping -c 3 mynet-eu-vm

