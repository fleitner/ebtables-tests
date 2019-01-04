#!/bin/bash

source ../config.sh
source ../cleanup.sh

set -e
source ./setup.sh

$SSH_GW ebtables -F FORWARD 
$SSH_GW ebtables -P FORWARD ACCEPT
$SSH_GW ebtables -F INPUT 
$SSH_GW ebtables -P INPUT DROP
$SSH_GW ebtables -A INPUT --log-level info --log-prefix EBFW
$SSH_GW ebtables -F OUTPUT 
$SSH_GW ebtables -P OUTPUT ACCEPT

if $SSH_CLIENT arping -c 3 -I eth1 10.0.0.254 &>/dev/null ; then
    echo "ARP is blocked, must fail"
    exit 1
fi

$SSH_GW ebtables -A INPUT -p ARP -j ACCEPT
if ! $SSH_CLIENT arping -c 3 -I eth1 10.0.0.254 &>/dev/null ; then
    echo "ARP is allowed, must pass"
    exit 1
fi

if $SSH_CLIENT ping -c 10 10.0.0.254 &>/dev/null ; then
    echo "Must be blocked by FW drop"
    exit 1
fi

$SSH_GW ebtables -A INPUT -p IPv4 -j ACCEPT
if ! $SSH_CLIENT ping -c 10 10.0.0.254 &>/dev/null ; then
    echo "It is allowed, must pass"
    exit 1
fi


