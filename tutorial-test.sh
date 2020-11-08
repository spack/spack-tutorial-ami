#!/bin/bash -e
#
# Copyright 2013-2020 Lawrence Livermore National Security, LLC and other
# Spack Project Developers. See the top-level COPYRIGHT file for details.
#
# SPDX-License-Identifier: (Apache-2.0 OR MIT)

working_dir=~/testing

# make working dir

echo started in `pwd`
rm -rf $working_dir
mkdir $working_dir
cd $working_dir

# clean up spack configuration

echo entered `pwd`
rm -rf ~/.spack/*

# clone a new spack

git clone https://github.com/spack/spack
cd spack
git checkout releases/v0.13

# shell init

. share/spack/setup-env.sh
which spack

# run tutorial commands

# For basic usage section

spack install zlib
spack mirror add tutorial /mirror
spack gpg trust /mirror/public.key
spack install zlib %clang
spack install zlib @1.2.8
spack install zlib %gcc@6.5.0
spack install zlib @1.2.8 cppflags=-O3
spack find
spack find -lf
spack install tcl
spack install tcl ^zlib @1.2.8 %clang
spack install tcl ^/hmvjty5
spack find -ldf
spack install hdf5
spack install hdf5~mpi
spack install hdf5+hl+mpi ^mpich
spack find -ldf
spack graph hdf5+hl+mpi ^mpich
spack install trilinos
spack install trilinos +hdf5 ^hdf5+hl+mpi ^mpich
spack find -d trilinos
spack graph trilinos
spack find -d tcl
spack find zlib
spack find -lf zlib
spack find ^mpich
spack find cppflags=-O3
spack find -px
spack install gcc@8.3.0
spack find -p gcc
spack compiler add `spack location -i gcc@8.3.0`
spack compiler remove gcc@8.3.0

# Packaging

spack install mpileaks

# Modules

spack install lmod
source `spack location -i lmod`/lmod/lmod/init/bash
. `spack location -r`/share/spack/setup-env.sh
spack load gcc
spack compiler add
spack install netlib-scalapack ^openmpi ^openblas %gcc@8.3.0
spack install netlib-scalapack ^openmpi ^netlib-lapack %gcc@8.3.0
spack install netlib-scalapack ^mpich ^openblas %gcc@8.3.0
spack install netlib-scalapack ^mpich ^netlib-lapack %gcc@8.3.0
spack install py-scipy ^openblas %gcc@8.3.0

# Advanced packaging

spack install netlib-lapack
spack install mpich
spack install openmpi
spack install --only=dependencies armadillo ^openblas
spack install --only=dependencies elpa

# remove this before env tutorial
spack compiler rm gcc@8.3.0

# Environments
spack env create myproject
spack env list
spack env activate myproject
spack find
spack env status
spack env deactivate
spack env status
spack find
spack env activate myproject
spack install tcl
spack install trilinos
spack find
which tclsh
tclsh <<EOF
echo "hello world!"
exit
EOF
which algebra
algebra || true

spack env deactivate
spack env create myproject2
spack env activate myproject2
spack install hdf5+hl
spack install trilinos
spack find
spack uninstall -y trilinos
spack find

spack env deactivate
spack env activate myproject
spack find
spack add hdf5+hl
spack add gmp
spack find
spack install
spack find

spack spec hypre
spack config get
> $(spack location -e myproject)/spack.yaml cat <<EOF
# This is a Spack Environment file.
#
# It describes a set of packages to be installed, along with
# configuration settings.
spack:
  packages:
    all:
      providers:
        mpi: [mpich]

  # add package specs to the `specs` list
  specs: [tcl, trilinos, hdf5, gmp]
EOF
spack concretize -f
spack find

spack env status
which mpicc
env | grep PATH=
> mpi-hello.c cat <<EOF
#include <stdio.h>
#include <mpi.h>
#include <zlib.h>

int main(int argc, char **argv) {
  int rank;
  MPI_Init(&argc, &argv);

  MPI_Comm_rank(MPI_COMM_WORLD, &rank);
  printf("Hello world from rank %d\n", rank);

  if (rank == 0) {
    printf("zlib version: %s\n", ZLIB_VERSION);
  }

  MPI_Finalize();
}
EOF
mpicc mpi-hello.c
mpirun -n 4 ./a.out

spack cd -e myproject
pwd
ls

mkdir code
cd code
spack env create -d .
ls
cat spack.yaml
> spack.yaml cat <<EOF
# This is a Spack Environment file.
#
# It describes a set of packages to be installed, along with
# configuration settings.
spack:
  # add package specs to the `specs` list
  specs:
  - boost
  - trilinos
  - openmpi
EOF
spack install

spack add hdf5@5.5.1
cat spack.yaml
spack remove hdf5
cat spack.yaml

head -30 spack.lock
spack env create abstract spack.yaml
spack env create concrete spack.lock
