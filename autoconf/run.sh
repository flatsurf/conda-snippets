#!/bin/bash

# ##################################################################
# Run ./configure with good defaults within conda-build
# ##################################################################

set -exo pipefail

if [ -z $PREFIX ]; then
        export PREFIX="$ASV_ENV_DIR"
fi

if [ -z $PREFIX ]; then
        echo '$PREFIX must be set. Aborting.'
        false
fi

if [[ "$action" == "style" ]]; then
        exit 0
fi

export CONFIGURE_FLAGS="$CONFIGURE_FLAGS --with-version-script"

if [[ "$action" == "release" ]]; then
        export CONFIGURE_FLAGS="$CONFIGURE_FLAGS --without-pytest --without-googletest --without-benchmark --without-sage"
fi

# Create Makefiles
./bootstrap
./configure --prefix="$PREFIX" CFLAGS="$CFLAGS" CXXFLAGS="$CXXFLAGS" CXX="$CXX" LDFLAGS="$LDFLAGS" CPPFLAGS="$CPPFLAGS" $CONFIGURE_FLAGS || (cat config.log; exit 1)
