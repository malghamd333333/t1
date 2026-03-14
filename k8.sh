#!/bin/bash


# Common setup for all servers (Control Plane and Nodes)
# sudo hostnamectl set-hostname master-node
# sudo hostnamectl set-hostname node01


# Disable swap
sudo swapoff -a

# Keeps the swap off during reboot
(crontab -l 2>/dev/null; echo "@reboot /sbin/swapoff -a") | crontab - || true
sudo apt-get update -y

# Create the .conf file to load the modules at bootup
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# Sysctl params required by setup, params persist across reboots
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

# Apply sysctl params without reboot
sudo sysctl --system

sudo apt-get update -y
sudo apt-get install -y apt-transport-https ca-certificates curl gpg

#----------------------------------------------------------

#---Install containerd 
sudo apt install -y curl gnupg2 software-properties-common apt-transport-https ca-certificates
sudo apt install -y containerd

sudo mkdir -p /etc/containerd


# Generate the default containerd configuration
sudo containerd config default | sudo tee /etc/containerd/config.toml

# Enable SystemdCgroup clear
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml



sudo systemctl restart containerd
sudo systemctl enable containerd

echo "--------------------------------"
echo "---CPU type is-----------------"
dpkg --print-architecture
echo "--------------------------------"
echo "---k8s is used amd64------------" 
echo "--------------------------------"

VERSION="v1.35.0"
curl -LO https://github.com/kubernetes-sigs/cri-tools/releases/download/$VERSION/crictl-$VERSION-linux-amd64.tar.gz
sudo tar zxvf crictl-$VERSION-linux-amd64.tar.gz -C /usr/local/bin
rm -f tar zxvf crictl-$VERSION-linux-amd64.tar.gz



# Configure crictl to use containerd
cat <<EOF | sudo tee /etc/crictl.yaml
runtime-endpoint: unix:///run/containerd/containerd.sock
image-endpoint: unix:///run/containerd/containerd.sock
timeout: 10
debug: false
EOF

echo "crictl installed and configured successfully"



#---------------------------------------------------------------------------------


curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
sudo tee /etc/apt/sources.list.d/kubernetes.list <<EOF
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF

sudo apt update


#-----------------------------------------------------------
# Be Careful with version  ex. v1.35
#-----------------------------------------------------------

# Install kubelet, kubectl, and kubeadm
sudo apt install -y apt-transport-https ca-certificates curl gpg
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.35/deb/Release.key \
| sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg


#Add Kubernetes repository
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.35/deb/ /' \
| sudo tee /etc/apt/sources.list.d/kubernetes.list


sudo apt update


apt search kubeadm

sudo apt install -y kubelet kubeadm kubectl


kubeadm version
kubectl version --client
kubelet --version


# Prevent automatic updates for kubelet, kubeadm, and kubectl
sudo apt-mark hold kubelet kubeadm kubectl

sudo apt-get update -y




#-----------------------------------------------------------
# use ip addr to get name of interface that we will use to get ip address
#-----------------------------------------------------------
# Install jq, a command-line JSON processor
sudo apt-get install -y jq

# Retrieve the local IP address of the eth0 interface and set it for kubelet
local_ip="$(ip --json addr show enX0 | jq -r '.[0].addr_info[] | select(.family == "inet") | .local')"

# Write the local IP address to the kubelet default configuration file
sudo cat > sudo  /etc/default/kubelet << EOF
KUBELET_EXTRA_ARGS=--node-ip=$local_ip
EOF



#-----------------------------------------------------------
# FOR MASTER NODE ONLAY 
#-----------------------------------------------------------
#Initialize Kubernetes Cluster (MASTER NODE)
#Calico requires 192.168.0.0/16 network CIDR.
sudo kubeadm init --pod-network-cidr=192.168.0.0/16

mkdir -p $HOME/.kube

sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config

sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Node will show NotReady until CNI is installed.
kubectl get nodes


# Install Calico Network Plugin (MASTER)
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/calico.yaml


# Check system pods:
kubectl get pods -n kube-system

# Generate new token to join work node
kubeadm token create --print-join-command