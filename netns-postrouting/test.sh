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

MAC_CLIENT="$( $SSH_GW ip netns exec ns1 ip -brief link show veth1 | awk '{ print $3 }' )"
MAC_SERVER="$( $SSH_GW ip netns exec ns2 ip -brief link show veth2 | awk '{ print $3 }' )"
MAC_VIRTUAL="52:54:00:DE:AD:BE"

$SSH_GW ebtables -t nat -A PREROUTING -i veth_ns2 -d $MAC_VIRTUAL -j dnat \
    --to-destination $MAC_CLIENT
$SSH_GW ebtables -t nat -A POSTROUTING -o veth_ns2 -j snat \
    --to-source $MAC_VIRTUAL --snat-arp
if ! $SSH_GW ip netns exec ns1 ping -c 7 10.0.0.2 &>/dev/null ; then
    echo "Special MAC is NATed, must pass"
    exit 1
fi

# Make sure the MAC seen in the server is the virtual one.
MAC_USED="$( $SSH_GW ip netns exec ns2 arp 10.0.0.1 -n | \
               awk '/^10.0.0.1/ { print $3 }' )"
if [[ "${MAC_USED^^}" != "$MAC_VIRTUAL" ]]; then
    echo "Server used the wrong MAC"
    echo "Used: ${MAC_USED^^}"
    echo "Virtual: $MAC_VIRTUAL"
    exit 1
fi
