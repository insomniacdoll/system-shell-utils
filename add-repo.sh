#!/bin/sh

# update system source index to latest
sudo apt-get update
sudo apt-get upgrade

# add repositories ppa
sudo add-apt-repository ppa:graphics-drivers/ppa
# sudo add-apt-repository ppa:mc3man/trusty-media
sudo add-apt-repository ppa:rvm/smplayer
sudo add-apt-repository ppa:numix/ppa
sudo add-apt-repository ppa:moka/stable
sudo add-apt-repository ppa:noobslab/themes
# sudo add-apt-repository ppa:tualatrix/ppa
sudo add-apt-repository ppa:hzwhuang/ss-qt5

# update source index
sudo apt-get update

# install nvidia drivers
sudo apt-get install nvidia-352
sudo nvidia-xconfig

# install other apps
sudo apt-get install mpv
sudo apt-get install smplayer
sudo apt-get install numix-gtk-theme numix-icon-theme-circle 
sudo apt-get install numix-wallpaper-notd
sudo apt-get install moka-icon-theme
sudo apt-get install zukitwo-dark-cinnamon zukitwo-dark-shell zukitwo zukiwi
# sudo apt-get install ubuntu-tweak
sudo apt-get install shadowsocks-qt5
