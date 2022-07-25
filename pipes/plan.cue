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

			"../out": write: contents: actions.binary.output
		}
		// env: {
		// 	REGISTRY_USERNAME: string
		// 	REGISTRY_PASSWORD: dagger.#Secret
		// }
	}

    _rootDir: client.filesystem."../"

    actions: {
        build: acts.#BuildVersion & {
            workdir: _rootDir.read.contents

            version: "0.12.0"
        }
    }
}