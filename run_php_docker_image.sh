#! /bin/bash

function getContainerID() {
	printf "$(docker ps -a | grep $1 | awk '{print $1}' | sed -e 's|^[0-9]\+:||')"
}

function getContainerIP() {
	containerId=$(getContainerID $1)
	containerLineStart=$(docker network inspect bridge | grep -in $containerId | sed -e 's|^\([0-9]\+\):.*$|\1|')
	(((containerLineStop=$containerLineStart+5)))
	data=$(docker network inspect bridge | sed -n ${containerLineStart},${containerLineStop}p)
	ip=$(echo $data | grep 'IPv4Address' | sed -e 's|.*"IPv4Address": "\([^""]\+\)".*|\1|')
	ip=$(echo $ip | sed -e 's|/[0-9]\+$||')
	printf $ip
}


MYSQL=$(getContainerIP mysql)

exec /usr/bin/docker run --rm --name php7 -p 80:80 -p 8000:8000 -e MYSQL_IP=${MYSQL} -v /home/prokvk/dev/Usertech/app/:/data php7
