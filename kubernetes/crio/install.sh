#!/bin/bash



modprobe overlay
modprobe br_netfilter

cat > /etc/sysctl.d/99-kubernetes-cri.conf <<EOF
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

sysctl --system
add-apt-repository ppa:projectatomic/ppa -y && apt update

cat <<EOF > /etc/apt/sources.list.d/projectatomics.list

deb http://ppa.launchpad.net/projectatomic/ppa/ubuntu bionic main
deb-src http://ppa.launchpad.net/projectatomic/ppa/ubuntu bionic main

EOF

apt update

apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 8BECF1637AD8C79D

apt install cri-o-1.15 -y

sed 's|/usr/libexec/crio/conmon|/usr/bin/conmon|' -i /etc/crio/crio.conf
curl https://raw.githubusercontent.com/projectatomic/registries/master/registries.fedora -o /etc/containers/registries.conf

systemctl start crio

cat <<EOF > /etc/cni/net.d/100-crio-bridge.conf
{ 
    "cniVersion": "0.3.0", 
    "name": "crio-bridge", 
    "type": "bridge", 
    "bridge": "cni0", 
    "isGateway": true, 
    "ipMasq": true, 
    "ipam": { 
        "type": "host-local", 
        "subnet": "10.88.0.0/16", 
        "routes": [ 
            { "dst": "0.0.0.0/0" } 
        ] 
    } 
}
EOF

cat <<EOF > /etc/cni/net.d/200-loopback.conf
{ 
    "cniVersion": "0.3.0", 
    "type": "loopback" 
}
EOF

apt install curl -y && curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
cat <<EOF > /etc/apt/sources.list.d/kubernetes.list 
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF

apt update && apt install kubelet kubeadm kubectl -y
systemctl status kubelet

cat <<EOF > /etc/default/kubelet
KUBELET_EXTRA_ARGS=--cgroup-driver=systemd --container-runtime=remote --container-runtime-endpoint="unix:///var/run/crio/crio.sock"
EOF


#kubeadm init --apiserver-advertise-address= --pod-network-cidr=10.244.0.0/16 --ignore-preflight-errors=...

