package acts

import (
    // "universe.dagger.io/alpine"
    "universe.dagger.io/docker"
    "dagger.io/dagger"
    "dagger.io/dagger/core"
)

#BuildImage: {
    version: string

    workdir: dagger.#FS
	_workdir: workdir

    _image: docker.#Dockerfile & {
        source: _workdir

        // dockerfile: path: "./Dockerfile"
        dockerfile: path: "./Mock.Dockerfile"

        platforms: ["linux/arm64"]

        buildArg: {
            router_version: version
        }
    }

    output: _image.output
}

#BuildBin: {
    workdir: dagger.#FS
    _workdir: workdir

    version: string
    _version: version


    _image: #BuildImage & {
        version: _version
        workdir: _workdir
    }

    _outdir: core.#Subdir & {
        input: _image.output.rootfs
        path:  "/router"
    }

    _prepareVerDir: core.#Copy & {
        input: _outdir.output
        contents: _outdir.output

        dest: "/v\(_version)"
    }

    _verDir: core.#Subdir & {
        input: _prepareVerDir.output
        path:  "/"
    }

    output: _verDir.output
}

#PublishBin: {
    workdir: dagger.#FS
    _workdir: workdir

    version: string
    _version: version

    _image: #BuildImage & {
        version: _version
        workdir: _workdir
    }

    _scriptDeps: #ScriptDeps & {
        workdir: _workdir
    }

    _copyBin: docker.#Copy & {
        input: _scriptDeps.output
        contents: _image.output.rootfs
        source: "/router"
        dest: "/bin"
    }

    _publish: #RunScript & {
        input: _copyBin.output
        name: "publish-bin"
    }
}
