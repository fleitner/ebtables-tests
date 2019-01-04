#!/bin/bash

source ../config.sh

set -e
$SSH_GW ip link add br_fw type bridge
#$SSH_GW ip link set eth1 master br_fw
$SSH_GW ip link set eth2 master br_fw
$SSH_GW ip link set br_fw up
$SSH_GW ip link set eth1 up
$SSH_GW ip link set eth2 up
