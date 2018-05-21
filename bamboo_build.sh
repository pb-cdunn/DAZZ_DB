#!/bin/bash -e
THISDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
type module >& /dev/null || source /mnt/software/Modules/current/init/bash

module load gcc
module load git
module load meson
module load ninja
module load ccache

set -vex
cd ${THISDIR}

export CCACHE_COMPILERCHECK='%compiler% -dumpversion'

#export CPPFLAGS=-D_GNU_SOURCE

# rm -rf ./build
meson --buildtype=release --strip --libdir=lib --prefix='/PREFIX' -Dtests=false --wrap-mode nofallback ./build .

TERM='dumb' ninja -C ./build -v

DESTDIR="$(pwd)/DESTDIR"
rm -rf "${DESTDIR}"

TERM='dumb' DESTDIR="${DESTDIR}" ninja -C ./build -v install

cd "${DESTDIR}/PREFIX"
LD_LIBRARY_PATH=lib ldd -r bin/DBshow
tar vzcf DAZZ_DB-SNAPSHOT.tgz bin lib include

if [[ $bamboo_planRepository_branchName == "develop" ]]; then
  NEXUS_BASEURL=http://ossnexus.pacificbiosciences.com/repository
  NEXUS_URL=$NEXUS_BASEURL/unsupported/gcc-6.4.0
  curl -v -n --upload-file DAZZ_DB-SNAPSHOT.tgz $NEXUS_URL/DAZZ_DB-SNAPSHOT.tgz
fi

cd -
