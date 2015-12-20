#!/bin/sh

username=$1
password=$2
ip=$3

sudo mkdir -p /mnt/WDMYCLOUDEX2
sudo mount -t cifs //WDMYCLOUDEX2/Private /mnt/WDMYCLOUDEX2 -o user=$username,password=$password,workgroup=WORKGROUP,ip=$ip

