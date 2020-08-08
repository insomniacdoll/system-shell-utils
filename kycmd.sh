#! /bin/sh
#
# kycmd.sh
# Copyright (C) 2016 hiyoru <insomniacdoll@gmail.com>
#
# Distributed under terms of the MIT license.
#


ps aux | grep YouCompleteMe | awk -F' ' '{print $2}' | xargs kill -SIGKILL
