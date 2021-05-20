function createStdDevice(path, num) {
    if (!FS.createDevice.major) FS.createDevice.major = 64;
    var dev = FS.makedev(FS.createDevice.major++, 0);
    var mode = num === 0 ? 0o444 : 0o222;
    FS.registerDevice(dev, {
        open(stream) {
            stream.seekable = false
        },
        close(stream) {},
        read(stream, buffer, offset, length) {
            const ret = global.wasmStdin(buffer, offset, length);
            if (ret > 0) {
                stream.node.timestamp = Date.now();
            }
            return ret;
        },
        write(stream, buffer, offset, length) {
            if (length) {
                stream.node.timestamp = Date.now();
                if (num === 2) {
                    global.wasmStderr(buffer, offset, length)
                } else {
                    global.wasmStdout(buffer, offset, length)
                }
            }
            return length;
        }
    });

    return FS.mkdev(path, mode, dev)
}

function createStandardStreamsUseful() {
    createStdDevice("/dev/stdin", 0);
    createStdDevice("/dev/stdout", 1);
    createStdDevice("/dev/stderr", 2);
    var stdin = FS.open('/dev/stdin', 0);
    var stdout = FS.open('/dev/stdout', 1);
    var stderr = FS.open('/dev/stderr', 1);
    console.log("standard streams:", stdin.fd, stdout.fd, stderr.fd)
}

var Module = {
  preInit() {
    FS.createStandardStreams = createStandardStreamsUseful;
  },
  preRun() {
    FS.createStandardStreams = createStandardStreamsUseful;
    FS.init();
    for (const mount of global.fsMounts) {
        FS.mkdir(mount.input)
        FS.mount(NODEFS, mount.output, mount.input);
    }
  }
};
