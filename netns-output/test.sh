#!/bin/bash

source ../config.sh
source ../cleanup.sh

set -e
source ./setup.sh

$SSH_GW ebtables -F FORWARD 
$SSH_GW ebtables -P FORWARD ACCEPT
$SSH_GW ebtables -F INPUT 
$SSH_GW ebtables -P INPUT ACCEPT
$SSH_GW ebtables -F OUTPUT 
$SSH_GW ebtables -P OUTPUT DROP
$SSH_GW ebtables -A INPUT --log-level info --log-prefix EBFW

if $SSH_GW ip netns exec ns1 arping -c 3 -I veth1 10.0.0.254 &>/dev/null ; then
    echo "ARP is blocked, must fail"
    exit 1
fi

$SSH_GW ebtables -A OUTPUT -p ARP -j ACCEPT
if ! $SSH_GW ip netns exec ns1 arping -c 3 -I veth1 10.0.0.254 &>/dev/null ; then
    echo "ARP is allowed, must pass"
    exit 1
fi

if $SSH_GW ip netns exec ns1 ping -c 10 10.0.0.254 &>/dev/null ; then
    echo "Must be blocked by FW drop"
    exit 1
fi

$SSH_GW ebtables -A OUTPUT -p IPv4 -j ACCEPT
if !  $SSH_GW ip netns exec ns1 ping -c 10 10.0.0.254 &>/dev/null ; then
    echo "It is allowed, must pass"
    exit 1
fi


