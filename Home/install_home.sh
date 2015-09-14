#!/bin/bash

function backup
{
    echo backup s
}

function install
{
    sourcedir=$(dirname ${BASH_SOURCE[0]})
    rsync -a $sourcedir $1 --exclude=install_home.sh
    echo "[successful]"
}


if [ $# -gt 0 ]
then
    if [ $1 = "-h" ]
    then
        echo Usage:
        echo "-h                  print this help text"
        echo "local install       ./install_home"
        echo "remote install      ./install_home uname@host.ucl.ac.uk"
        exit 0
    else
        host_name=$(ssh $1 'echo $MYID')
        echo -n "Install remote host home ($host_name)......"
        install $1:
    fi
else
    echo -n "Install local home ($MYID)......"
    install $HOME
fi
