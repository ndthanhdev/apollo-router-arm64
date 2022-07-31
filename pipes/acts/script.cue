package acts


import (
    "universe.dagger.io/alpine"
    "universe.dagger.io/docker"
    "dagger.io/dagger"
)


#ScriptDeps: {
	workdir: dagger.#FS
	_workdir: workdir

    _buildImage: docker.#Build & {
        steps: [
            alpine.#Build & {
                version: "3.16"
                packages: {
                    git: {}
                    nodejs: {}
                    npm: {}
                    bash: {}
                    yarn: {}
                    openssh: {}
                }
            },
            docker.#Copy & {
                contents: _workdir
            },
            docker.#Run & {
                command: {
                    name: "npm"
                    args: ["install", "-g", "zx"]
                }
            },
            docker.#Run & {
                workdir: "./scripts"
                command: {
                    name: "yarn"
                    args: ["install"]
                }
            }
        ]
    }

    output: _buildImage.output
}

#RunScript: {
    name: string
    _name: name

    args: [...string]
    _args: args

    docker.#Run & {
        command: {
            name: "zx",
            args: ["./scripts/\(_name).mjs"] + _args
        }
    }
}
