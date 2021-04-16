#!/bin/sh
#
# Copyright 2013-2020 Lawrence Livermore National Security, LLC and other
# Spack Project Developers. See the top-level COPYRIGHT file for details.
#
# SPDX-License-Identifier: (Apache-2.0 OR MIT)

# clean out any spack directories in home directories of spack* accounts
for i in `seq 1 10`; do
    user="spack${i}"
    sudo rm -rf /home/${user}/.spack
    sudo rm -rf /home/${user}/.gnupg
    sudo rm -rf /home/${user}/.bash_history
    sudo rm -rf /home/${user}/.bash_logout
    sudo rm -rf /home/${user}/.cache
    sudo rm -rf /home/${user}/.emacs.d
    sudo rm -rf /home/${user}/.viminfo
    sudo rm -rf /home/${user}/.Xauthority
    sudo rm -rf /home/${user}/spack
    sudo rm -rf /home/${user}/spack-tutorial
    sudo rm -rf /home/${user}/.local
done
