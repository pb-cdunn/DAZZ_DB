#!/bin/bash -xe
THISDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
type module >& /dev/null || source /mnt/software/Modules/current/init/bash

set -vex

PREFIX=$PWD/build
cd ${THISDIR}
source bamboo_make.sh
cd -
cd ${PREFIX}
tar zcf DAZZ_DB-SNAPSHOT.tgz bin lib include
NEXUS_BASEURL=http://ossnexus.pacificbiosciences.com/repository
NEXUS_URL=$NEXUS_BASEURL/unsupported/gcc-4.9.2
curl -v -n --upload-file DAZZ_DB-SNAPSHOT.tgz $NEXUS_URL/DAZZ_DB-SNAPSHOT.tgz
cd -
