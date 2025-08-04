#!/bin/bash
#
# Copyright 2013-2020 Lawrence Livermore National Security, LLC and other
# Spack Project Developers. See the top-level COPYRIGHT file for details.
#
# SPDX-License-Identifier: (Apache-2.0 OR MIT)

#
# This is a setup script for our Spack tutorial.
# It adds everything you need to a fresh ubuntu image.
#

#------------------------------------------------------------------------
# !! UPDATE BEFORE NEXT TUTORIAL !!
#------------------------------------------------------------------------
# URL for buildcache to copy into AMI
REMOTE_BUILDCACHE_URL="spack-binaries/v2025.07.0/tutorial"

# directory containing this script
script_dir="$(dirname $0)"

echo "==> Doing apt updates"
apt update -y
apt upgrade -y


echo "==> Installing apt packages needed by the tutorial"
apt install -y \
    autoconf \
    automake \
    bash-completion \
    bzip2 \
    clang \
    cpio \
    curl \
    docker.io \
    emacs \
    file \
    findutils \
    fish \
    gcc g++ gfortran \
    gcc-10 gfortran-10 g++-10 \
    git \
    git \
    gpg \
    graphviz \
    iproute2 \
    iputils-ping \
    jq \
    libc-dev \
    libffi-dev \
    libssl-dev \
    libxml2-dev \
    locate \
    m4 \
    make \
    mercurial \
    mpich \
    ncurses-dev \
    patch \
    pciutils \
    python3-pip \
    rclone \
    rsync \
    sudo \
    tree \
    unzip \
    vim \
    wget \
    zlib1g-dev

echo "==> Cleaning up old apt files"
apt autoremove --purge && apt clean

echo "==> Ensuring spack can detect gpg"
ln -s /usr/bin/gpg /usr/bin/gpg2

echo "==> Creating tutorial users"
for i in `seq 0 10`; do
    echo "    creating $username"
    username="spack${i}"
    password=$(openssl passwd -6 $username)
    useradd \
    --create-home \
    --password $password \
    --shell /bin/bash \
    $username
done

echo "== Creating a group of docker users"
sudo groupadd docker
for i in `seq 0 10`; do
    sudo usermod -aG docker "spack${i}"
done

echo "== Starting Docker services"
sudo systemctl enable --now docker.service
sudo systemctl enable --now containerd.service

echo "==> Enabling password login"
perl -i~ -pe 's/^\#?PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
perl -i~ -pe 's/^\#?PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config.d/*.conf
systemctl restart ssh

echo "==> Cleaning up home directories"
sudo rm -rf /home/spack*/.spack
sudo rm -rf /home/spack*/.gnupg
sudo rm -rf /home/spack*/.bash_history
sudo rm -rf /home/spack*/.cache
sudo rm -rf /home/spack*/.emacs.d
sudo rm -rf /home/spack*/.viminfo

echo "==> Installing the backup mirror"
rclone copy :s3:$REMOTE_BUILDCACHE_URL /mirror
chmod -R go+r /mirror

echo "==> Copying tutorial config into place"
mkdir -p /etc/spack
cp $script_dir/config/*.yaml /etc/spack/
chmod -R go+r /etc/spack

echo "==> Add some aliases"
echo "alias e='emacs -nw'" >> /etc/bash.bashrc
