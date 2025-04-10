#! /bin/sh
#
# add-wps-fonts.sh
# Copyright (C) 2016 hiyoru <insomniacdoll@gmail.com>
#
# Distributed under terms of the MIT license.
#


tar -zxvf wps_fonts.tar.gz
sudo cp *.ttf /usr/share/fonts
sudo cp *.TTF /usr/share/fonts
sudo mkfontscale
sudo mkfontdir
sudo fc-cache
sudo rm -rf *.ttf
sudo rm -rf *.TTF
