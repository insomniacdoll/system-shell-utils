#!/bin/sh

# extract vim files to home folder
# tar zxvf dotvim.tar.gz
# mv .vim .vimrc ~/
# rm -rf .vim .vimrc

# add dependencies of vim plugins
echo "[DEBUG] INSTALLING BUILD TOOLS"
sudo apt-get install vim vim-nox zsh
sudo apt-get install build-essential cmake automake ctags cscope llvm llvm-dev clang
sudo apt-get install python-dev python-pip ruby ruby-dev gems nodejs npm libxml2 libxml2-dev libxslt1.1
sudo apt-get install astyle tidy
sudo ln -s /usr/bin/nodejs /usr/bin/node
sudo npm install -g js-beautify typescript-formatter
gem sources --add https://ruby.taobao.org/ --remove https://rubygems.org/
sudo gem install sass rails
sudo pip install autopep8 Django flask twisted tornado scrapy PyYAML poster
sudo apt-get install chromium-browser firefox browser-plugin-freshplayer-pepperflash pepperflashplugin-nonfree
sudo apt-get install terminator
sudo apt-get install git subversion
echo "[DEBUG] INSTALL BUILD TOOLS FINISHED"
