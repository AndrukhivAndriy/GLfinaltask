#!/bin/bash

# Update OS
apt update -y
apt upgrade -y

# Install requirements for Ansible to start Kubespray
apt install python3-pip -y
cd /home/ubuntu
git clone https://github.com/kubernetes-sigs/kubespray.git
cd kubespray
git checkout release-2.20
pip3 install -r requirements.txt
pip3 install -r contrib/inventory_builder/requirements.txt
cp -rfp inventory/sample inventory/mycluster

# Find External IP
export EXIP=`curl https://ipecho.net/plain`

# Let's config Kubespray 
cd inventory/mycluster
sed -i "s/# node1 ansible_host=95.54.0.12  # ip=10.3.0.1 etcd_member_name=etcd1/node1 ansible_host=$EXIP/" inventory.ini
sed -i "s/# node2/node1/g" inventory.ini
sed -i "s/node1 ansible_host=95.54.0.13  # ip=10.3.0.2 etcd_member_name=etcd2/# node1 ansible_host=95.54.0.13  # ip=10.3.0.2 etcd_member_name=etcd2/" inventory.ini
cd group_vars/k8s_cluster 
sed -i "s/kube_proxy_strict_arp: false/kube_proxy_strict_arp: true/" k8s-cluster.yml
cd /home/ubuntu/.ssh/

# Generate and Deploy Key Pair for Ansible 

yes y | ssh-keygen -t rsa -N '' -C 'ubuntu' -f /home/ubuntu/.ssh/id_rsa -q > /dev/null
echo "#Add key for Ansible" >> authorized_keys
cat id_rsa.pub >> authorized_keys
chmod 600 /home/ubuntu/.ssh/id_rsa

# Deploy K8s Cluster via Kubespray
cd /home/ubuntu/kubespray
ansible-playbook -i inventory/mycluster/inventory.ini -u ubuntu -b -v --private-key=/home/ubuntu/.ssh/id_rsa cluster.yml

# Install MetalLB

kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.13.7/config/manifests/metallb-native.yaml
wget https://raw.githubusercontent.com/AndrukhivAndriy/DevOps-BaseCamp/main/k8s/metallbconf.yaml
# To find local IP - uncomment next line
export INIP=`hostname -I | cut -d' ' -f1`
sed -i "s/localip/$INIP\/32/" metallbconf.yaml
kubectl create -f metallbconf.yaml

# Install Helm

curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh

