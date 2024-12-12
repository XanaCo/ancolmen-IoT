#!/bin/sh

B_YELLOW="\033[1;33m"
B_GREEN="\033[1;32m"
B_GREY="\033[1;30m"
B_RED="\033[1;31m"
RESET="\033[0m"

SERVER="cbernazeS"
WORKER="cbernazeSW"

SETGREY="echo -n "${RESET}${B_GREY}""

result_message() {
    if [ $? -eq 0 ]; then
        echo "${B_GREEN}$1${RESET}"
    else
        echo "${B_RED}$2${RESET}"
        exit 1
    fi
}

# Testing the status of both the server and the agent VM
echo -n "${B_YELLOW}Do you want to check if the two VMs are running? Y/N:"
read yesno
if [ "$yesno" = "y" ] || [ "$yesno" = "Y" ]; then
    $SETGREY
   
    vagrant global-status | grep "${SERVER} " | grep "running"
    result_message "${SERVER} is up and running" "${SERVER} is not running"
   
    $SETGREY
    vagrant global-status | grep "${WORKER}" | grep "running"
    result_message "${WORKER} is up and running" "${WORKER} is not running"
fi

# Testing the status of k3s in the server VM
echo -n "${B_YELLOW}Do you want to check ${SERVER}? Y/N:"
read yesno
if [ "$yesno" = "y" ] || [ "$yesno" = "Y" ]; then
    $SETGREY
    vagrant ssh $SERVER -c 'sudo kubectl get nodes -o wide | grep "cbernazes " | grep "Ready"'
    result_message "k3S server cbernazes is ready" "k3S server cbernazes is not ready"

    $SETGREY
    vagrant ssh $SERVER -c 'sudo kubectl get nodes -o wide | grep "cbernazesw" | grep "Ready"'
    result_message "k3S agent cbernazesw is ready" "k3S agent cbernazesw is not ready"
    
    $SETGREY
    vagrant ssh $SERVER -c 'ip a show eth1  | grep "inet 192.168.56.110"'
    result_message "correct ip address for the server" "server: incorrect ip address: ip expected: 192.168.56.110"
fi

# Testing the status of k3s in the worker VM
echo -n "${B_YELLOW}Do you want to check ${WORKER}? Y/N:"
read yesno
if [ "$yesno" = "y" ] || [ "$yesno" = "Y" ]; then
    $SETGREY
    vagrant ssh $WORKER -c 'sudo kubectl get nodes -o wide'
    if [ $? -eq 1 ]; then
        echo "${B_GREEN}Connection refused as expected${RESET}"
    else
        echo "${B_RED}Unexpected behavior${RESET}"
    fi
    
    $SETGREY
    vagrant ssh $WORKER -c 'ip a show eth1  | grep "inet 192.168.56.111"'
    result_message "correct ip address for the agent" "agent: incorrect ip address: ip expected: 192.168.56.111"
fi