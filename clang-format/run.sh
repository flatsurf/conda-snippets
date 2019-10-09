#!/bin/bash
set -exo pipefail

# ##################################################################
# Make sure that the source is following our clang-format settings
# ##################################################################

if [[ "$target" != "style" ]]; then
  exit 0
fi

clang-format -i -style=file `git ls-files '*.cc' '*.hpp' '*.ipp' '*.h' '*.h.in' '*.hpp.in'`
