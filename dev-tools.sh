#!/bin/sh

# extract vim files to home folder
# tar zxvf dotvim.tar.gz
# mv .vim .vimrc ~/
# rm -rf .vim .vimrc

# add dependencies of vim plugins
echo "[DEBUG] INSTALLING BUILD TOOLS"
sudo apt-get install vim vim-nox zsh
sudo apt-get install build-essential cmake automake autoconf libtool libtool-bin ctags cscope llvm llvm-dev clang
sudo apt-get install python-dev python3-dev python3-pip ruby ruby-dev gems nodejs npm libxml2 libxml2-dev libxslt1.1 libxslt-dev 
sudo apt-get install astyle tidy
sudo ln -s /usr/bin/nodejs /usr/bin/node
sudo npm install -g js-beautify typescript-formatter
gem sources --add https://mirrors.tuna.tsinghua.edu.cn/rubygems/ --remove https://rubygems.org/
sudo gem install sass rails sciruby
mkdir -p ~/.pip
rm -rf ~/.pip/pip.conf
cp pip.conf ~/.pip 
sudo pip3 install virtualenv
# sudo pip install autopep8 django flask flask-restful uwsgi gunicorn twisted tornado scrapy PyYAML poster numpy scipy scikit-learn statsmodels pyodps
# sudo apt-get install chromium-browser firefox browser-plugin-freshplayer-pepperflash pepperflashplugin-nonfree
# sudo apt-get install terminator
sudo apt-get install git subversion
sudo apt-get install tsocks cifs-utils
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
git clone https://github.com/scrooloose/nerdtree.git ~/.vim/bundle/nerdtree
echo "[DEBUG] INSTALL BUILD TOOLS FINISHED"
