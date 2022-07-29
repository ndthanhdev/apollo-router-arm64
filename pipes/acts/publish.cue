package acts

import (
    "dagger.io/dagger"
    // "dagger.io/dagger/core"
    // "encoding/yaml"
)


#Publish: {
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

        input: _deps.output

        #RunScript & {
            name: "build-meta"
        }

    }

    // _readingMeta: {
    //     _readFile: core.#ReadFile & {
    //         input: _buildMeta.output
    //         path: "/out/meta.yaml"
    //     }

    //     meta: yaml.Marshal(_readFile.contents)

    //     output: meta
    // }

    // _version: _readingMeta.output.nextBuild

    // if _version {
    //     _publishBin: #PublishBin & {
    //         workdir: _workdir
    //         version: _version
    //         ghToken: _ghToken
    //     }

    //     _publish: #PublishImage & {
    //         workdir: _workdir
    //         version: _version
    //         ghUsername: _ghUsername
    //         ghToken: _ghToken
    //     }
    // }

}
