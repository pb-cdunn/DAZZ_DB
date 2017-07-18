#!/bin/bash -xe
# Always run this in repo root directory.
# $PREFIX can override where this builds.
type module >& /dev/null || source /mnt/software/Modules/current/init/bash

module load gcc/4.9.2
module load git/2.8.3
module load ccache

export CPPFLAGS=-D_GNU_SOURCE
DEFAULT_PREFIX=$PWD/build
PREFIX=${PREFIX:-${DEFAULT_PREFIX}}
rm -rf ${PREFIX}
mkdir -p ${PREFIX}/lib ${PREFIX}/bin ${PREFIX}/include
make clean
make -j
make PREFIX=${PREFIX} install
cp *.h ${PREFIX}/include
