#!/bin/bash

source ../config.sh

set -e
$SSH_GW ip netns add ns1 || :
$SSH_GW ip netns add ns2 || :

$SSH_GW ip link add veth_ns1 type veth peer name veth1
$SSH_GW ip link add veth_ns2 type veth peer name veth2

$SSH_GW ip link add br_fw type bridge
$SSH_GW ip link set veth_ns1 master br_fw
$SSH_GW ip link set veth_ns2 master br_fw
$SSH_GW ip link set br_fw up
$SSH_GW ip link set veth_ns1 up
$SSH_GW ip link set veth_ns2 up

$SSH_GW ip link set veth1 netns ns1
$SSH_GW ip link set veth2 netns ns2

$SSH_GW ip netns exec ns1 ip address add 10.0.0.1/24 dev veth1 
$SSH_GW ip netns exec ns2 ip address add 10.0.0.2/24 dev veth2 

$SSH_GW ip netns exec ns1 ip link set veth1 up
$SSH_GW ip netns exec ns2 ip link set veth2 up
