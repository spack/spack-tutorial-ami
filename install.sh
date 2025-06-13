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
REMOTE_BUILDCACHE_URL="s3://spack-binaries/releases/v0.23/tutorial"

# directory containing this script
script_dir="$(dirname $0)"

echo "==> Doing apt updates"
apt update -y
apt upgrade -y


echo "==> Installing apt packages needed by the tutorial"
apt install -y \
    autoconf \
    automake \
    awscli \
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
    rsync \
    rsync \
    sudo \
    tree \
    unzip \
    vim \
    wget \
    zlib1g-dev

echo "==> Installing python3 packages needed by the tutorial"
python3 -m pip install --upgrade pip \
    setuptools \
    wheel \
    gnureadline \
    boto3 \
    awscli  # needed if we upgrdae boto3


echo "==> Cleaning up old apt files"
apt autoremove --purge && apt clean


echo "==> Ensuring spack can detect gpg"
ln -s /usr/bin/gpg /usr/bin/gpg2


echo "==> Creating tutorial users"
for i in `seq 1 10`; do
    echo "    creating $username"
    username="spack${i}"
    password=$(python3 -c "import crypt; print(crypt.crypt('${username}'))")
    useradd \
    --create-home \
    --password $password \
    --shell /bin/bash \
    $username
done

echo "== Creating a group of docker users"
sudo groupadd docker
for i in `seq 1 10`; do
    sudo usermod -aG docker "spack${i}"
done

echo "== Creating a group of spack users"
sudo groupadd spack
for i in `seq 1 10`; do
    sudo usermod -aG spack "spack${i}"
done

echo "== Starting Docker services"
sudo systemctl enable docker.service
sudo systemctl enable containerd.service
sudo services docker start
sudo services containerd start

echo "==> Enabling password login"
perl -i~ -pe 's/^\#?PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
perl -i~ -pe 's/^\#?PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config.d/*.conf
service sshd restart


echo "==> Cleaning up home directories"
sudo rm -rf /home/spack*/.spack
sudo rm -rf /home/spack*/.gnupg
sudo rm -rf /home/spack*/.bash_history
sudo rm -rf /home/spack*/.cache
sudo rm -rf /home/spack*/.emacs.d
sudo rm -rf /home/spack*/.viminfo


echo "==> Installing the backup mirror"
aws s3 sync --delete --no-sign-request $REMOTE_BUILDCACHE_URL /mirror
chmod -R go+r /mirror


echo "==> Copying tutorial config into place"
mkdir -p /etc/spack
cp $script_dir/config/*.yaml /etc/spack/
chmod -R go+r /etc/spack


echo "==> Add some aliases"
echo "alias e='emacs -nw'" >> /etc/bash.bashrc
