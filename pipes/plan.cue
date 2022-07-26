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
		}
		env: {
			TARGET_VERSION?: string
			GH_USERNAME: string
			GH_TOKEN: dagger.#Secret
		}
	}

    _rootDir: client.filesystem."../"

	_version: client.env.TARGET_VERSION | *"0.11.0"

    actions: {
        buildBin: acts.#BuildBin & {
            workdir: _rootDir.read.contents

            version: _version
        }

		publishBin: acts.#PublishBin & {
			workdir: _rootDir.read.contents
			version: _version
			ghToken: client.env.GH_TOKEN
		}

		publishImage: acts.#PublishImage & {
			workdir: _rootDir.read.contents
			version: _version
			ghUsername: client.env.GH_USERNAME
			ghToken: client.env.GH_TOKEN
		}

		daily: {
			// find version to build
			// publish bin
			// publish image
		}
    }
}