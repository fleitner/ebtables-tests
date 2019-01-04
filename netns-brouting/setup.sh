#!/bin/bash

source ../config.sh

set -e
$SSH_GW ip netns add ns1 || :

$SSH_GW ip link add veth_ns1 type veth peer name veth1

$SSH_GW ip link add br_fw type bridge
#$SSH_GW ip link set veth_ns1 master br_fw
$SSH_GW ip link set br_fw up
$SSH_GW ip link set veth_ns1 up

$SSH_GW ip link set veth1 netns ns1

$SSH_GW ip netns exec ns1 ip link set veth1 up
