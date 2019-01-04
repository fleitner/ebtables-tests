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
$SSH_GW ebtables -P OUTPUT ACCEPT

CLIENT_MAC="$( $SSH_GW ip netns exec ns1 ip -brief link show veth1 | awk '{ print $3 }' )"
SERVER_MAC="$( $SSH_GW ip netns exec ns2 ip -brief link show veth2 | awk '{ print $3 }' )"
$SSH_GW ip netns exec ns1 arp -s 10.0.0.2 52:54:00:DE:AD:BE 
if $SSH_GW ip netns exec ns1 ping -c 7 10.0.0.2 &>/dev/null ; then
    echo "ARP is not working, must fail"
    exit 1
fi

$SSH_GW ebtables -t nat -A PREROUTING -d 52:54:00:DE:AD:BE -i veth_ns1 -j dnat \
    --to-destination $SERVER_MAC
if ! $SSH_GW ip netns exec ns1 ping -c 7 10.0.0.2 &>/dev/null ; then
    echo "ARP is working, must pass"
    exit 1
fi

$SSH_GW ip netns exec ns1 arp -d 10.0.0.2 || :
$SSH_GW ebtables -t nat -P PREROUTING DROP
$SSH_GW ebtables -t nat -F PREROUTING
$SSH_GW ebtables -t nat -A PREROUTING -p IPv4 -j ACCEPT
$SSH_GW ebtables -t nat -A PREROUTING -p arp --arp-opcode Request -j arpreply \
    --arpreply-mac 52:54:00:DE:AD:BE
if $SSH_GW ip netns exec ns1 ping -c 7 10.0.0.2 &>/dev/null ; then
    echo "ARP is NOT working, must NOT pass"
    exit 1
fi

$SSH_GW ip netns exec ns1 arp -d 10.0.0.2 || :
$SSH_GW ebtables -t nat -P PREROUTING DROP
$SSH_GW ebtables -t nat -F PREROUTING
$SSH_GW ebtables -t nat -A PREROUTING -p IPv4 -j ACCEPT
$SSH_GW ebtables -t nat -A PREROUTING -p arp --arp-opcode Request -j arpreply \
    --arpreply-mac $SERVER_MAC
if ! $SSH_GW ip netns exec ns1 ping -c 7 10.0.0.2 &>/dev/null ; then
    echo "ARP is working, must pass"
    exit 1
fi
