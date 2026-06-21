#!/bin/bash
set -e

# Basics
git clone --depth=2 --branch=releases/v1.2 https://github.com/spack/spack.git ~/spack
. share/spack/setup-env.sh
spack list
spack list 'py-*'
spack install gmake
spack compilers
spack mirror add --unsigned tutorial /mirror

spack versions zlib-ng
spack install zlib-ng@2.0.7
spack info --no-dependencies --no-versions zlib-ng
spack install zlib-ng +ipo
spack install zlib-ng build_type=Debug

spack install zlib-ng %clang
spack install zlib-ng %gcc@14
spack spec -l tcl ^zlib-ng@2.0.7 %clang
spack install tcl ^zlib-ng@2.0.7 %clang
spack spec tcl ^/kie
spack graph tcl

spack install hdf5
spack providers mpi
spack install hdf5 ^mpich
spack spec hdf5 %c,cxx=clang %fortran=gcc

spack find
spack find -l
spack find -d tcl
spack find ^mpich
spack find -px

spack install trilinos
spack install trilinos +hdf5 ^mpich
spack find ^mpich

spack find zlib-ng
spack uninstall -y zlib-ng %gcc@14
spack find -lf zlib-ng
# spack uninstall zlib-ng/kie fails as expected
spack uninstall -y -R zlib-ng/kie
# spack uninstall trilinos fails as expected
spack uninstall /u43

spack install gcc@16
spack compilers
spack spec zziplib %gcc@16
spack uninstall -y gcc@16


# Environments
spack find

spack env create myproject
spack env list
spack env activate myproject
spack find
spack env status
despacktivate
spack env status
spack find

spack add tcl
spack add trilinos
spack find
spack concretize
spack find -c
spack install
spack find

which tclsh
spack env activate myproject
spack env status
which mpicc
cat <<EOF > mpi-hello.c
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
    printf("zlib-ng version: %s\n", ZLIBNG_VERSION);
  }

  MPI_Finalize();
}
EOF
mpicc ./mpi-hello.c -I$(spack location -i zlib-ng)/include
mpirun -n 2 ./a.out
env | grep PATH=

spack env create myproject2
spack env activate myproject2
spack add scr trilinos
spack concretize
spack install
spack find
spack remove scr
spack find
spack concretize
spack find
# spack uninstall -y trilinos fails as expected
spack remove trilinos
spack env activate myproject
spack find

spack cd -e myproject
jq < spack.lock | head -30
spack env list

spack config add "packages:mpi:require:[mpich]"
spack concretize
spack concretize --force

cd
mkdir code
cd code
spack env create -d .
cat <<EOF > spack.yaml
# This is a Spack Environment file.
#
# It describes a set of packages to be installed, along with
# configuration settings.
spack:
  # add package specs to the `specs` list
  specs:
  - trilinos
  - openmpi
  view: true
  concretizer:
    unify: true
EOF
spack env activate .
spack install

spack env create abstract spack.yaml
spack env activate abstract
spack find

spack env create concrete spack.lock
spack env activate concrete
spack find

spack env deactivate
spack env rm myproject myproject2 abstract concrete
