#!/bin/bash

set -euo pipefail
source $(dirname $0)/var.sh

FLAGS=(
  "${FFMPEG_CONFIG_FLAGS_BASE[@]}"
  --enable-gpl            # required by x264
  --enable-nonfree        # required by fdk-aac
  --enable-zlib           # enable zlib
  --enable-libmp3lame     # enable libmp3lame
  --enable-libfdk-aac     # enable libfdk-aac
  --enable-libopus        # enable opus
)
echo "FFMPEG_CONFIG_FLAGS=${FLAGS[@]}"
EM_PKG_CONFIG_PATH=${EM_PKG_CONFIG_PATH} emconfigure ./configure "${FLAGS[@]}"
