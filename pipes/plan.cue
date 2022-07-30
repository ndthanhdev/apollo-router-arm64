package main

import (
    "dagger.io/dagger"
    "pipes.local/acts"
)


dagger.#Plan & {
    client: {
		filesystem: {
			"../": read: {
				contents: dagger.#FS,
				exclude: [
					"node_modules",
					"out/",
					"temp/",
				]
			}

			"../out/": write: contents: actions.buildBin.output

			// "../out/": write: contents: actions.publishAll.output
		}
		env: {
			TARGET_VERSION?: string
			GH_USERNAME: string
			GH_TOKEN: dagger.#Secret
		}
	}

    _rootDir: client.filesystem."../"

	_workdir: _rootDir.read.contents
	_version: client.env.TARGET_VERSION | *"0.11.0"
	_ghUsername: client.env.GH_USERNAME
	_ghToken: client.env.GH_TOKEN

    actions: {
        buildBin: acts.#BuildBin & {
            workdir: _workdir

            version: _version
        }

		publishBin: acts.#PublishBin & {
			workdir: _workdir
			version: _version
			ghToken: _ghToken
		}

		publishImage: acts.#PublishImage & {
			workdir: _workdir
			version: _version
			ghUsername: _ghUsername
			ghToken: _ghToken
		}

		publishAll: acts.#PublishAll & {
			workdir: _workdir
			ghUsername: _ghUsername
			ghToken: _ghToken
		}
	}
}
