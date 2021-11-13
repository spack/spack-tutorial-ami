#!/bin/bash
#
# Copyright 2013-2021 Lawrence Livermore National Security, LLC and other
# Spack Project Developers. See the top-level COPYRIGHT file for details.
#
# SPDX-License-Identifier: (Apache-2.0 OR MIT)

#
# This is a setup script for our Spack tutorial.
# It adds everything you need to a fresh ubuntu image.
#

# S3 URL for the binaries to be synced to /mirror
S3_TUTORIAL_BUILDCACHE_URL="s3://spack-binaries-develop/tutorial"

# directory containing this script
script_dir="$(dirname $0)"

echo "==> Doing apt updates"
apt update -y
apt upgrade -y


echo "==> Installing apt packages needed by the tutorial"
apt install -y --no-install-recommends \
    autoconf \
    build-essential \
    bsdmainutils \
    ca-certificates \
    curl \
    clang-7 \
    emacs \
    file \
    g++ g++-6 \
    gcc gcc-6 \
    gfortran gfortran-6 \
    git \
    gnupg2 \
    iproute2 \
    make \
    openssh-server \
    python3 \
    python3-pip \
    tcl \
    unzip \
    vim \
    wget

echo "==> Installing python3 packages needed by the tutorial"
python3 -m pip install --upgrade pip \
    setuptools \
    wheel \
    gnureadline \
    boto3 \
    awscli  # needed if we upgrdae boto3

update-alternatives --install /usr/bin/python python /usr/bin/python3 1

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
aws s3 sync --no-sign-request $S3_TUTORIAL_BUILDCACHE_URL /mirror
chmod -R go+r /mirror


echo "==> Copying tutorial config into place"
mkdir -p /etc/spack
cp $script_dir/config/*.yaml /etc/spack/
chmod -R go+r /etc/spack


echo "==> Add some aliases"
echo "alias e='emacs -nw'" >> /etc/bash.bashrc
