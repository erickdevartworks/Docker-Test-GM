#!/bin/bash
#
# Configure broken host machine to run correctly
#
set -ex

GMCN_IMAGE=${GMCN_IMAGE:-erickdev/gamblecoind}

distro=$1
shift

memtotal=$(grep ^MemTotal /proc/meminfo | awk '{print int($2/1024) }')

#
# Only do swap hack if needed
#
if [ $memtotal -lt 2048 -a $(swapon -s | wc -l) -lt 2 ]; then
    fallocate -l 2048M /swap || dd if=/dev/zero of=/swap bs=1M count=2048
    mkswap /swap
    grep -q "^/swap" /etc/fstab || echo "/swap swap swap defaults 0 0" >> /etc/fstab
    swapon -a
fi

free -m

if [ "$distro" = "trusty" -o "$distro" = "ubuntu:14.04" ]; then
    curl https://get.docker.io/gpg | apt-key add -
    echo deb http://get.docker.io/ubuntu docker main > /etc/apt/sources.list.d/docker.list

    # Handle other parallel cloud init scripts that may lock the package database
    # TODO: Add timeout
    while ! apt-get update; do sleep 10; done

    while ! apt-get install -y lxc-docker; do sleep 10; done
fi

# Always clean-up, but fail successfully
docker kill gamblecoind-node 2>/dev/null || true
docker rm gamblecoind-node 2>/dev/null || true
stop docker-gamblecoind 2>/dev/null || true

if [ -z "${GMCN_IMAGE##*/*}" ]; then
    docker pull $GMCN_IMAGE
fi

docker volume create --name=gamblecoind-data
docker run -v gamblecoind-data:/root --rm $GMCN_IMAGE gmcn_init

curl https://raw.githubusercontent.com/Gamblecoin-Project/GambleCoin-Docker/master/upstart.init > /etc/init/docker-gamblecoind.conf
start docker-gamblecoind

set +ex
echo "Resuolting gamblecoin.conf:"
docker run -v gamblecoind-data:/root --rm $GMCN_IMAGE cat /root/.Gamblecoin/gamblecoin.conf
