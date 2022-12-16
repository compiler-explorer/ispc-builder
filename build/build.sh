#!/bin/bash

set -exo pipefail

ROOT=$PWD
VERSION=$1

URL=https://github.com/ispc/ispc.git
LLVM_VERSION=15.0

case $VERSION in
templates_new-trunk)
  URL=https://github.com/dbabokin/ispc.git
  BRANCH=templates_new
  VERSION=$VERSION-$(date +%Y%m%d)
  ;;
trunk)
  BRANCH=main
  VERSION=$VERSION-$(date +%Y%m%d)
  ;;
esac

FULLNAME=ispc-${VERSION}
OUTPUT=${ROOT}/${FULLNAME}.tar.xz
S3OUTPUT=
if [[ $2 =~ ^s3:// ]]; then
  S3OUTPUT=$2
else
  if [[ -d "${2}" ]]; then
    OUTPUT=$2/${FULLNAME}.tar.xz
  else
    OUTPUT=${2-$OUTPUT}
  fi
fi

REF=refs/heads/${BRANCH}

# determine build revision
ISPC_REVISION=$(git ls-remote "${URL}" "${REF}" | cut -f 1)
REVISION="ispc-${ISPC_REVISION}-llvm-${LLVM_VERSION}"
LAST_REVISION="${3}"

echo "ce-build-revision:${REVISION}"
echo "ce-build-output:${OUTPUT}"

if [[ "${REVISION}" == "${LAST_REVISION}" ]]; then
  echo "ce-build-status:SKIPPED"
  exit
fi

export LLVM_HOME=${ROOT}/llvm
export ISPC_HOME=${ROOT}/ispc

# Checkout
git clone --depth 1 --single-branch -b "${BRANCH}" "${URL}" "${ISPC_HOME}"

cd "${ISPC_HOME}"
./alloy.py -b --version="${LLVM_VERSION}" --verbose

PATH=${LLVM_HOME}/bin-${LLVM_VERSION}/bin:${PATH}

BUILD_DIR=${ROOT}/build
STAGING_DIR=${ROOT}/staging
mkdir -p "${BUILD_DIR}"
cd "${BUILD_DIR}"
cmake "${ISPC_HOME}" -DX86_ENABLED=ON -DARM_ENABLED=ON \
    -DCMAKE_BUILD_TYPE:STRING=Release \
    -DCMAKE_INSTALL_PREFIX:PATH="${STAGING_DIR}"

make -j"$(nproc)" install

export XZ_DEFAULTS="-T 0"
tar Jcf "${OUTPUT}" --transform "s,^./,./${FULLNAME}/," -C "${STAGING_DIR}" .

if [[ -n "${S3OUTPUT}" ]]; then
  aws s3 cp --storage-class REDUCED_REDUNDANCY "${OUTPUT}" "${S3OUTPUT}"
fi

echo "ce-build-status:OK"
