#!/bin/bash

function backup
{
    echo backup s
}

function install
{
    echo "Install to loacal home..."
    sourcedir=$(dirname ${BASH_SOURCE[0]})
    echo $(ls $sourcedir)
    rsync -av $sourcedir $1 --exclude=install_home.sh
    echo "[successful]"
}


if [ -z $1 ]
then
    install $HOME
else
    install $1
fi
