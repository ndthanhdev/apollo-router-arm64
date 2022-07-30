package acts

import (
    // "universe.dagger.io/alpine"
    "universe.dagger.io/docker"
    "dagger.io/dagger"
    "dagger.io/dagger/core"
    "encoding/json"
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

        label: {

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

    ghToken: dagger.#Secret

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
        dest: "/out/v\(_version)"
    }

    _publish: #RunScript & {
        input: _copyBin.output
        name: "publish-bin"
        env: {
            TARGET_VERSION: _version,
            GH_TOKEN: ghToken
        }
    }
}

#PublishImage: {
    workdir: dagger.#FS
    _workdir: workdir

    version: string
    _version: version

    ghUsername: string
    ghToken: dagger.#Secret

    _image: #BuildImage & {
        version: _version
        workdir: _workdir
    }

    _push: docker.#Push & {
        image: _image.output

        dest: "ghcr.io/ndthanhdev/apollo-router-arm64:\(_version)"

        auth: {
            username: ghUsername
            secret: ghToken
        }
    }
}


#PublishAll: {
    workdir: dagger.#FS
	_workdir: workdir

    ghUsername: string
    _ghUsername: ghUsername

    ghToken: dagger.#Secret
    _ghToken: ghToken

    _buildMeta: {
        _deps: #ScriptDeps & {
            workdir: _workdir
        }


        _build: #RunScript & {
            input: _deps.output
            name: "build-meta"

            export: files: "/out/meta.json": string
        }

        // output: _build.output

        contents: _build.export.files."/out/meta.json"
    }

    _meta: json.Unmarshal(_buildMeta.contents) & {
        missingVers: [...string]
        shouldBuild: bool | *false
        nextBuild?: string
    }

    _doPublish: {

        _shouldBuild: _meta.shouldBuild
        _version: _meta.nextBuild

        if _meta.shouldBuild {
            // "_publishBin": #PublishBin & {
            //     workdir: _workdir
            //     version: _version
            //     ghToken: _ghToken
            // }

            "_do": docker.#Run & {
                input: _buildMeta._deps.output
                command: {
                    name: "echo"
                    args: ["Publish bin..."]
                }
            }
        }
    }


    output: true & _meta.shouldBuild

    // _doPublish: {
    //     _version: string & _meta.nextBuild
    //     if _meta.shouldBuild {
    //         _publishImage: #PublishImage & {
    //             workdir: _workdir
    //             version: _version
    //             ghUsername: _ghUsername
    //             ghToken: _ghToken
    //         }
    //     }

    //     if !(bool & _meta.shouldBuild) {
    //         _skipPublish: docker.#Run & {
    //             input: _workdir
    //             command: {
    //                 name: "echo"
    //                 args: ["No version to build"]
    //             }
    //         }
    //     }
    // }
}
