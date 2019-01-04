#!/bin/bash

source ../config.sh

set -e
$SSH_CLIENT ip address add 10.0.0.10/24 dev eth1
$SSH_SERVER ip address add 10.0.0.1/24 dev eth1

$SSH_GW ip link add br_fw type bridge
$SSH_GW ip link set eth1 master br_fw
$SSH_GW ip link set eth2 master br_fw
$SSH_GW ip link set br_fw up
$SSH_GW ip link set eth1 up
$SSH_GW ip link set eth2 up
