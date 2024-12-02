#!bin/bash

B_GREEN="\033[0;32m"
RED="\033[0;31m"
B_RED="\033[1;31m"
RESET="\033[0m"

echo "${B_GREEN}. . . SERVER CONFIGURATION SCRIPT . . .${RESET}"

# Preinstall Config in the server node
if sudo DEBIAN_FRONTEND=noninteractive apt-get update -y && \
sudo apt-get upgrade -y && \
sudo apt-get install curl -y;
then
    echo "${B_GREEN}Preinstallation Succeded!${RESET}"
else
    echo "${B_RED}Error: Preinstallation Failed${RESET}"
    exit 1
fi

# Modify the K3s environment variables
if export INSTALL_K3S_EXEC="
--write-kubeconfig-mode=644 \
--bind-address=192.168.56.110 \
--node-ip 192.168.56.110 \
--tls-san $(hostname) \
--advertise-address=192.168.56.110"; then
    echo "${B_GREEN}K3s Environment Variables Set!${RESET}"
else
    echo "${B_RED}Error: K3s Environment Variables Not Set!${RESET}"
    exit 1
fi

# Install K3s Controller Plane
if curl -sfL https://get.k3s.io | sh -; then
    echo "${B_GREEN}K3s Controller Plane Installed!${RESET}"
else
    echo "${B_RED}Error: K3s Controller Plane Not Installed!${RESET}"
    exit 1
fi

if sudo mkdir -p ~/.kube && \
sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config && \
sudo chmod 600 ~/.kube/config && \
sudo chown $(id -u):$(id -g) ~/.kube/config; then
    echo "${B_GREEN}K3s Kubeconfig File Copied!${RESET}"
else
    echo "${B_RED}Error: K3s Kubeconfig File Not Copied!${RESET}"
    exit 1
fi

# Get the K3s server token
if sudo cp /var/lib/rancher/k3s/server/node-token /vagrant/scripts/; then
    echo "${B_GREEN}K3s Server Token Copied!${RESET}"
else
    echo "${B_RED}Error: K3s Server Token Not Copied!${RESET}"
    exit 1
fi

echo "${B_GREEN}. . . SERVER IS READY . . .${RESET}"
