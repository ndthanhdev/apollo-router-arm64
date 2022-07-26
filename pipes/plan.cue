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
			// REGISTRY_USERNAME: string
			REGISTRY_PASSWORD: dagger.#Secret
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
			env: {
				TARGET_VERSION: client.env.TARGET_VERSION
				REGISTRY_USERNAME: client.env.REGISTRY_USERNAME
				REGISTRY_PASSWORD: client.env.REGISTRY_PASSWORD
			}
		}
    }
}