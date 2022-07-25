package acts

import (
    // "universe.dagger.io/alpine"
    "universe.dagger.io/docker"
    "dagger.io/dagger"
)

#BuildVersion: {
    version: string

    workdir: dagger.#FS
	_workdir: workdir

    _image: docker.#Dockerfile & {
        source: _workdir
        dockerfile: path: "./Dockerfile"

        platforms: ["linux/arm64"]

        buildArg: {
            router_version: version
        }
    }

    ouput: _image
}

#Binary: {
    version: string
    _version: version

    workdir: dagger.#FS
	_workdir: workdir

    _image: #BuildVersion & {
        version: _version
        workdir: _workdir
    }

    _outdir: core.#Subdir & {
        input: _image.output.rootfs
        path:  "/router"
    }

    _prepareVerDir: core.#Copy & {
        input: _outdir.output.rootfs
        contents: _outdir.output.rootfs

        dest: "/"
    }


    _verDir: core.#Subdir & {
        input: _prepareVerDir.output
        path:  "/"
    }

    output: _verDir.output
}

