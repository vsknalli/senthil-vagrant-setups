#!/bin/bash
#Disable Firewall
echo "Disabling firewall in centos7"
systemctl disable firewalld; systemctl stop firewalld

#Disable swap
echo "Disabling swap and comment in fstab file"
swapoff -a; sed -i '/swap/d' /etc/fstab

# Disable SELinux
echo "Disabling SELinux"
setenforce 0
sed -i --follow-symlinks 's/^SELINUX=enforcing/SELINUX=disabled/' /etc/sysconfig/selinux

#Update sysctl settings for Kubernetes networking
echo "Update sysctl settings for Kubernetes networking"
cat >>/etc/sysctl.d/kubernetes.conf<<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl --system

# Install docker engine
echo "Install docker engine"
yum install -y yum-utils device-mapper-persistent-data lvm2
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum install -y docker-ce-23.0 
systemctl enable --now docker

#Kubernetes Setup
echo "Add yum repository for Kubernetes setup"
cat >>/etc/yum.repos.d/kubernetes.repo<<EOF
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg
        https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF

# Install Kubernetes components
echo "Install Kubernetes components"
yum install -y kubeadm-1.25.0 kubelet-1.25.0 kubectl-1.25.0

# Enable kubernetes kubelet
echo "Enable kubelet service"
systemctl enable --now kubelet

