#!/bin/bash

function valid_ip()
{
    local  ip=$1
    local  stat=1

    if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        OIFS=$IFS
        IFS='.'
        ip=($ip)
        IFS=$OIFS
        [[ ${ip[0]} -le 255 && ${ip[1]} -le 255 \
            && ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]
        stat=$?
    fi
    return $stat
}

cqlsh -e "select peer from system.peers"
peers=$(cqlsh -e "select peer from system.peers")

for peer in $peers
do
   if valid_ip $peer; then
       echo "delete from system.peers where peer = '$peer'"
       cqlsh -e "delete from system.peers where peer = '$peer'"
       sleep 1
   fi

done

cqlsh -e "select peer from system.peers"
