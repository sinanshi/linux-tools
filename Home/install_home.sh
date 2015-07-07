#!/bin/bash

function install
{
    echo "Install to loacal home..."
    sourcedir=$(dirname ${BASH_SOURCE[0]})
    echo $(ls $sourcedir)
    rsync -av $sourcedir $1 --exclude=install_home.sh
    echo "[successful]"
}

function backup
{
    echo backup s
}

if [ -z $1 ]
then
    install ../temp
else
    echo set
fi
