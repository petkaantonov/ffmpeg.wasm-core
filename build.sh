#!/bin/bash

set -eo pipefail

SCRIPT_ROOT=$(dirname $0)/wasm/build-scripts

# verify Emscripten version
emcc -v
# install dependencies
$SCRIPT_ROOT/install-deps.sh
# build zlib
$SCRIPT_ROOT/build-zlib.sh
# build lame
$SCRIPT_ROOT/build-lame.sh
# build fdk-aac
$SCRIPT_ROOT/build-fdk-aac.sh
# build opus
$SCRIPT_ROOT/build-opus.sh
# configure FFmpeg with Emscripten
$SCRIPT_ROOT/configure-ffmpeg.sh
# build ffmpeg.wasm core
$SCRIPT_ROOT/build-ffmpeg.sh
