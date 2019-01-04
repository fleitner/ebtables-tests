#!/bin/bash

source ../config.sh
source ../cleanup.sh

set -e
source ./setup.sh

$SSH_GW ebtables -F FORWARD 
$SSH_GW ebtables -P FORWARD DROP
$SSH_GW ebtables -A FORWARD --log-level info --log-prefix EBFW
$SSH_GW ebtables -F INPUT 
$SSH_GW ebtables -P INPUT ACCEPT
$SSH_GW ebtables -F OUTPUT 
$SSH_GW ebtables -P OUTPUT ACCEPT

if $SSH_GW ip netns exec ns1 arping -c 3 -I veth1 10.0.0.2 &> /dev/null; then
    echo "ARP is blocked, must fail"
    exit 1
fi

$SSH_GW ebtables -A FORWARD -p ARP -j ACCEPT
if ! $SSH_GW ip netns exec ns1 arping -c 3 -I veth1 10.0.0.2 &> /dev/null; then
    echo "ARP is allowed, must pass"
    exit 1
fi

if $SSH_GW ip netns exec ns1 ping -c 10 10.0.0.2 &>/dev/null ; then
    echo "Must be blocked by FW drop"
    exit 1
fi

$SSH_GW ebtables -A FORWARD -p IPv4 -j ACCEPT
if ! $SSH_GW ip netns exec ns1 ping -c 10 10.0.0.2 &>/dev/null ; then
    echo "It is allowed, must pass"
    exit 1
fi

CLIENT_MAC="$( $SSH_GW ip netns exec ns1 ip -brief link show veth1 | awk '{ print $3 }' )"
SERVER_MAC="$( $SSH_GW ip netns exec ns2 ip -brief link show veth2 | awk '{ print $3 }' )"
$SSH_GW ebtables -F FORWARD
$SSH_GW ebtables -A FORWARD -p ARP -j ACCEPT
$SSH_GW ebtables -A FORWARD -p IPv4 --ip-src 10.0.0.1 -s $CLIENT_MAC -j ACCEPT
$SSH_GW ebtables -A FORWARD -p IPv4 --ip-src 10.0.0.2 -s $SERVER_MAC -j ACCEPT
if ! $SSH_GW ip netns exec ns1 ping -c 10 10.0.0.2 &>/dev/null ; then
    echo "It is allowed, must pass"
    exit 1
fi

$SSH_GW ebtables -F FORWARD
$SSH_GW ebtables -A FORWARD -p ARP -j ACCEPT
$SSH_GW ebtables -N MATCHING-MAC-IP-PAIR
if $SSH_GW ip netns exec ns1 ping -c 10 10.0.0.2 &>/dev/null ; then
    echo "It is NOT allowed, must NOT pass"
    exit 1
fi

$SSH_GW ebtables -A FORWARD -p IPv4 --among-dst \
    $SERVER_MAC=10.0.0.2,$CLIENT_MAC=10.0.0.1 -j MATCHING-MAC-IP-PAIR
if ! $SSH_GW ip netns exec ns1 ping -c 10 10.0.0.2 &>/dev/null ; then
    echo "It is allowed, must pass"
    exit 1
fi

