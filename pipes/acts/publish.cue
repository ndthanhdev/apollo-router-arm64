package acts

import (
    "dagger.io/dagger"
    "dagger.io/dagger/core"
    "encoding/yaml"
    "universe.dagger.io/docker"
    // "strings"
)


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
        }

        output: _build.output
    }

    _readingMeta: {
        _readFile: core.#ReadFile & {
            input: _buildMeta.output.rootfs
            path: "/out/meta.yaml"
        }

        _debugContent: docker.#Run & {
            input: _buildMeta.output
            command: {
                name: "echo"
                args: [_readFile.contents]
            }
        }

        meta: yaml.Unmarshal(_readFile.contents)

        output: meta
    }

    _version: _readingMeta.output.nextBuild

    _foundVersion: docker.#Run & {
        input: _buildMeta.output
        command: {
            name: "echo"
            args: [_version]
        }
    }

    _doPublish: {

        _donePublish: docker.#Run & {
            input: _buildMeta.output
            command: {
                name: "echo"
                args: ["start publishing"]
            }
        }

        if _version != _|_ {
            _publishBin: #PublishBin & {
                workdir: _workdir
                version: _version
                ghToken: _ghToken
            }

            _publishImage: #PublishImage & {
                workdir: _workdir
                version: _version
                ghUsername: _ghUsername
                ghToken: _ghToken
            }
        }

        if _version == _|_ {
            _skipPublish: docker.#Run & {
                input: _buildMeta.output
                command: {
                    name: "echo"
                    args: ["No version to build"]
                }
            }
        }
    }
}
