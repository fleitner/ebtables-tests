#!/bin/bash

source ../config.sh

$SSH_GW ip address flush eth1
$SSH_GW ip address flush eth2
$SSH_CLIENT ip address flush eth1
$SSH_SERVER ip address flush eth1
$SSH_CLIENT arp -d 10.0.0.1 &> /dev/null || :
$SSH_SERVER arp -d 10.0.0.10 &> /dev/null || :
$SSH_GW ebtables -F INPUT &> /dev/null || :
$SSH_GW ebtables -F OUTPUT &> /dev/null || :
$SSH_GW ebtables -F FORWARD &> /dev/null || :
$SSH_GW ebtables -t nat -F  &> /dev/null || :
$SSH_GW ebtables -X MATCHING-MAC-IP-PAIR &> /dev/null || :
$SSH_GW ebtables -P INPUT ACCEPT &> /dev/null || :
$SSH_GW ebtables -P OUTPUT ACCEPT &> /dev/null || :
$SSH_GW ebtables -P FORWARD ACCEPT &> /dev/null || :
$SSH_GW ebtables -t nat -P PREROUTING ACCEPT  &> /dev/null || :
$SSH_GW ebtables -t nat -P POSTROUTING ACCEPT  &> /dev/null || :
$SSH_GW ebtables -t nat -P OUTPUT ACCEPT  &> /dev/null || :
$SSH_GW ebtables -t broute -F BROUTING &> /dev/null || :
$SSH_SERVER ip route del 10.2.0.0/24 &> /dev/null || :
$SSH_CLIENT ip route del 10.1.0.0/24 &> /dev/null || :
$SSH_CLIENT ip route del 10.10.10.0/24 &> /dev/null || :
$SSH_GW ip address del 10.10.10.10/24 dev eth0 &> /dev/null || :
$SSH_GW ip link del br_fw &> /dev/null || :
$SSH_GW ip link del veth_ns1 &> /dev/null || :
$SSH_GW ip link del veth_ns2 &> /dev/null || :
$SSH_GW ip netns del ns1 &> /dev/null || :
$SSH_GW ip netns del ns2 &> /dev/null || :

