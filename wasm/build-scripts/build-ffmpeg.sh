#!/bin/bash

set -eo pipefail
source $(dirname $0)/var.sh

mkdir -p wasm/dist
emmake make -j
FLAGS=(
  -I. -I./fftools -I$BUILD_DIR/include
  -Llibavcodec -Llibavdevice -Llibavfilter -Llibavformat -Llibavresample -Llibavutil -Llibpostproc -Llibswscale -Llibswresample -L$BUILD_DIR/lib
  -Wno-deprecated-declarations -Wno-pointer-sign -Wno-implicit-int-float-conversion -Wno-switch -Wno-parentheses -Qunused-arguments
  -lavdevice -lavfilter -lavformat -lavcodec -lswresample -lswscale -lavutil -lpostproc -lm -lmp3lame -lfdk-aac -lopus
  fftools/ffmpeg_opt.c fftools/ffmpeg_filter.c fftools/ffmpeg_hw.c fftools/cmdutils.c fftools/ffmpeg.c
  -o wasm/dist/ffmpeg-core.js
  -lnodefs.js
  -s USE_SDL=2                                  # use SDL2
  -s USE_PTHREADS=0                             # enable pthreads support
  -s PROXY_TO_PTHREAD=0                         # detach main() from browser/UI main thread
  -s INVOKE_RUN=0                               # not to run the main() in the beginning
  -s EXIT_RUNTIME=1                             # exit runtime after execution
  -s MODULARIZE=1                               # use modularized version to be more flexible
  -s EXPORT_NAME="createFFmpegCore"             # assign export name for browser
  -s EXPORTED_FUNCTIONS="[_main, _proxy_main]"  # export main and proxy_main funcs
  -s EXTRA_EXPORTED_RUNTIME_METHODS="[FS, cwrap, ccall, setValue, writeAsciiToMemory]"   # export preamble funcs
  -s INITIAL_MEMORY=209715200                  # 200MB
  --post-js wasm/post-js.js
  --pre-js wasm/pre-js.js
  $OPTIM_FLAGS
)
echo "FFMPEG_EM_FLAGS=${FLAGS[@]}"
emcc "${FLAGS[@]}"
