#! /bin/sh
#
# saria2.sh
# Copyright (C) 2016 hiyoru <insomniacdoll@gmail.com>
#
# Distributed under terms of the MIT license.
#

function start_aria()
{
    nohup aria2c --conf-path=/opt/webui-aria2/conf/aria2.conf &
    chrome /opt/webui-aria2/index.html
    return 0
}

function stop_aria()
{
    ps aux | grep aria2c | awk -F' ' '{print $2}' | xargs kill -SIGKILL
    rm -rf nohup.out
    return 0
}

function usage()
{
    echo "Usage: aria2 [start|stop|restart]"
    return 0
}

action=$1
if [ "$action"x = "start"x ]; then
    start_aria
    exit
elif [ "$action"x = "stop"x ]; then
    stop_aria
    exit
elif [ "$action"x = "restart"x ]; then
    stop_aria
    start_aria
    exit
else
    echo "Unknow action: $action"
    usage
    exit
fi
