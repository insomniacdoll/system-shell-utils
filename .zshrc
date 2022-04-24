# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
#ZSH_THEME="robbyrussell"
ZSH_THEME="ys"

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git)

source $ZSH/oh-my-zsh.sh

# User configuration

export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games"
# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/dsa_id"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"


# =========global envs settings start=============
export LANG=zh_CN.UTF-8
export LANGUAGE=zh_CN:en_US
export LC_CTYPE=en_US.UTF-8

export ENV_HOME=/opt
export SCRIPT_HOME=$HOME/scripts

# =========global envs settings start=============


# =========build tools envs settings start=============

## for build tools
export ANT_HOME=$ENV_HOME/apache-ant
export IVY_HOME=$ENV_HOME/apache-ivy

## for ant and ivy
export PATH=$ANT_HOME/bin:$IVY_HOME:$PATH
export CLASSPATH=$IVY_HOME:$IVY_HOME/lib:$CLASSPATH

## for maven 
export M2_HOME=$ENV_HOME/apache-maven
export PATH=$M2_HOME/bin:$PATH

## for custom git
# export GIT_PATH=$ENV_HOME/git
# export PATH=$GIT_PATH/bin:$PATH

# =========build tools envs settings end=============


# =========language envs settings start=============

## for lampp
export LAMPP_HOME=$ENV_HOME/lampp
export PATH=$LAMPP_HOME/bin:$PATH

## for java 
# export JAVA_HOME=$ENV_HOME/jdk1.7.0_80
export JAVA_HOME=$ENV_HOME/jdk1.8.0
export JRE_HOME=$JAVA_HOME/jre
export PATH=$JAVA_HOME/bin:$JRE_HOME/bin:$PATH

## for custom groovy
export GROOVY_HOME=$ENV_HOME/groovy
export PATH=$GROOVY_HOME/bin:$PATH

## for custom scala
export SCALA_HOME=$ENV_HOME/scala
export PATH=$SCALA_HOME/bin:$PATH

## for custom jython
export JYTHON_HOME=$ENV_HOME/jython
export PATH=$JYTHON_HOME:$PATH

## for custom jruby
# export JRUBY_HOME=$ENV_HOME/jruby-9.1.2.0
# export PATH=$JRUBY_HOME/bin:$PATH

## for custom python
#export PYTHON_PATH=$ENV_HOME/python2
#export PATH=$PYTHON_PATH/bin:$PATH

## for custom ruby
# export RUBY_HOME=$ENV_HOME/ruby
# export PATH=$RUBY_HOME/bin:$PATH

## for custom nodejs
# export NODEJS_PATH=$ENV_HOME/nodejs
# export PATH=$NODEJS_PATH/bin:$PATH

## for custom golang
export GOROOT=$ENV_HOME/golang
export PATH=$GOROOT/bin:$PATH
export GOPATH=$HOME/workspace/golangtest

# export LLVM=/usr/lib/llvm-3.4
# export PATH=$LLVM/bin:$PATH

# =========language envs settings end=============


# =========library envs settings start=============

## for tblib
export TBLIB_ROOT=$ENV_HOME/tb-common-utils

## for ld_library
export LD_LIBRARY_PATH=$JRE_HOME/lib/amd64:$JRE_HOME/lib/amd64/server:$LD_LIBRARY_PATH

# =========library envs settings end=============


# =========command tools envs settings start=============
# export some tools path
export ODPS_CLT_HOME=$ENV_HOME/odps-clt
export RODPS_CONFIG=$ENV_HOME/odps-clt/conf/odps_config.ini
export PATH=$ODPS_CLT_HOME/bin:$PATH

# =========command tools envs settings end=============


# =========alias settings start=============

# alias def

alias ll="ls -la"
alias cnpm="npm --registry=https://registry.npm.taobao.org \
--cache=$HOME/.npm/.cache/cnpm \
--disturl=https://npm.taobao.org/dist \
--userconfig=$HOME/.cnpmrc"
alias odpsconfd2p="$SCRIPT_HOME/odpsconfd2p.sh"
alias odpsconfd2g="$SCRIPT_HOME/odpsconfd2g.sh"
alias odpsconfd1="$SCRIPT_HOME/odpsconfd1.sh"
alias ossget="$SCRIPT_HOME/ossget.sh"
alias ossput="$SCRIPT_HOME/ossput.sh"
alias mvnali="$SCRIPT_HOME/mvnali.sh"
alias mvnosc="$SCRIPT_HOME/mvnosc.sh"
alias kycmd="$SCRIPT_HOME/kycmd.sh"

# =========alias settings start=============

