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

# directory containing this script
script_dir="$(dirname $0)"

echo "==> Doing apt updates"
apt update -y
apt upgrade -y


echo "==> Installing apt packages needed by the tutorial"
apt install -y \
    git \
    gcc \
    g++ \
    gfortran  \
    graphviz \
    patch \
    bzip2 \
    findutils \
    automake \
    autoconf \
    make \
    m4 \
    unzip \
    vim \
    file \
    wget \
    curl \
    mercurial \
    cpio \
    gpg \
    zlib1g-dev \
    libffi-dev \
    libssl-dev \
    libxml2-dev \
    rsync \
    locate \
    pciutils \
    iputils-ping \
    iproute2 \
    emacs \
    gcc-6 \
    clang-6.0 \
    ncurses-dev \
    sudo \
    python3-pip \
    awscli


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


echo "==> Enabling password login"
sed -i~ 's/^PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
service sshd restart


echo "==> Cleaning up home directories"
sudo rm -rf /home/spack*/.spack
sudo rm -rf /home/spack*/.gnupg
sudo rm -rf /home/spack*/.bash_history
sudo rm -rf /home/spack*/.cache
sudo rm -rf /home/spack*/.emacs.d
sudo rm -rf /home/spack*/.viminfo


echo "==> Installing the backup mirror"
aws s3 sync --delete --no-sign-request s3://binaries.spack.io/releases/v0.19/tutorial /mirror
chmod -R go+r /mirror


echo "==> Copying tutorial config into place"
mkdir -p /etc/spack
cp $script_dir/config/*.yaml /etc/spack/
chmod -R go+r /etc/spack


echo "==> Add some aliases"
echo "alias e='emacs -nw'" >> /etc/bash.bashrc
