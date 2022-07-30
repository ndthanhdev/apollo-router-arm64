package acts

import (
    "dagger.io/dagger"
    // "dagger.io/dagger/core"
    "encoding/json"
    "universe.dagger.io/docker"
    // "strings"
)

#Meta: {
    missingVers: [...string]
    shouldBuild: bool
    nextBuild: string
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

    _meta: #Meta & json.Unmarshal(_buildMeta.contents)

    _doPublish: {
        _version: string & _meta.nextBuild

        if bool & _meta.shouldBuild {
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

        if !(bool & _meta.shouldBuild) {
            _skipPublish: docker.#Run & {
                input: _workdir
                command: {
                    name: "echo"
                    args: ["No version to build"]
                }
            }
        }
    }
}
