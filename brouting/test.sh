#!/bin/bash

source ../config.sh
source ../cleanup.sh

set -e
source ./setup.sh


IPADDR_VIRTUAL="10.10.10.10"
NETMASK_VIRTUAL="10.10.10.0/24"

$SSH_GW ip address add ${IPADDR_VIRTUAL}/24 dev eth0
$SSH_GW ip address add 10.0.0.254/24 dev eth1
$SSH_CLIENT ip address add 10.0.0.1/24 dev eth1
$SSH_CLIENT ip route add $NETMASK_VIRTUAL via 10.0.0.254

# Manual ARP resolution
MAC_GW="$( $SSH_GW ip -brief link show eth1 | awk '{ print $3 }' )"
$SSH_CLIENT arp -s 10.0.0.254 $MAC_GW
MAC_CLIENT="$( $SSH_CLIENT ip -brief link show eth1 | awk '{ print $3 }' )"
$SSH_GW arp -s 10.0.0.1 $MAC_CLIENT

if ! $SSH_CLIENT ping -c 10 $IPADDR_VIRTUAL &>/dev/null ; then
    echo "Traffic should go directly"
    exit 1
fi

$SSH_GW ip link set eth1 master br_fw
if $SSH_CLIENT ping -c 10 $IPADDR_VIRTUAL &>/dev/null ; then
    echo "Traffic should not pass when port is added to the br"
    exit 1
fi

# Enable routing for the Virtual IP
$SSH_GW ebtables -t broute -A BROUTING -p IPv4 --ip-destination $IPADDR_VIRTUAL \
    -j redirect --redirect-target DROP
if ! $SSH_CLIENT ping -c 10 $IPADDR_VIRTUAL &>/dev/null ; then
    echo "Traffic should go directly to the stack"
    exit 1
fi

