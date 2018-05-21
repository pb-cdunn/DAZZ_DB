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

case "${bamboo_planRepository_branchName}" in
  develop|master)
    export PREFIX_ARG="/mnt/software/d/dazzdb/${bamboo_planRepository_branchName}"
    export BUILD_NUMBER="${bamboo_globalBuildNumber:-0}"
    DESTDIR=/
    ;;
  *)
    export PREFIX_ARG=/PREFIX
    export BUILD_NUMBER="0"
    DESTDIR="$(pwd)/install"
    rm -rf "${DESTDIR}"
    ;;
esac

# rm -rf ./build
meson --buildtype=release --strip --libdir=lib --prefix="${PREFIX_ARG}" -Dtests=false --wrap-mode nofallback ./build .

TERM='dumb' ninja -C ./build -v

# TODO: Add test here.

case "${bamboo_planRepository_branchName}" in
  develop|master)
    TERM='dumb' DESTDIR="${DESTDIR}" ninja -C ./build -v install
    chmod -R a+rwx "${DESTDIR}${PREFIX_ARG}"/*
    module load dazzdb/${bamboo_planRepository_branchName}
    ldd -r $(which DBshow)
    ;;
esac
