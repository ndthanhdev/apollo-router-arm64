package acts


import (
    "universe.dagger.io/alpine"
    "universe.dagger.io/docker"
    "dagger.io/dagger"
)


#ScriptDeps: {
	workdir: dagger.#FS
	_workdir: workdir

    _image: docker.#Build & {
        steps: [
            alpine.#Build & {
                version: "3.16"
                packages: {
                    git: {}
                    nodejs: {}
                    npm: {}
                    bash: {}
                    yarn: {}
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

    output: _image.output
}

#RunScript: {

    workdir: dagger.#FS
    _workdir: workdir

    deps: #ScriptDeps & {
        workdir: _workdir
    }

    name: string
    _name: name

    args: [...string]
    _args: args

    _run: docker.#Run & {
        input: deps.output
        command: {
            name: "zx",
            args: ["./scripts/src/\(_name).mjs"] + _args
        }
    }

    output: _run.output
}
