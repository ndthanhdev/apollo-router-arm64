package acts


import (
    "universe.dagger.io/dagger/alpine"
    "dagger.io/core"
)


#ScriptDeps: {
	workdir: dagger.#FS
	_workdir: workdir

    _pkgs: alpine.#Build & {
        packages: {
            git: {}
            nodejs: {}
            bash: {}
        }
    }

    _cp: core.#Copy & {
        src: _workdir
        dst: _workdir
    }

    _zx: docker.#Run & {

    }
}

#RunScript: {
    deps: #ScriptDeps & {}

    name: string
    _name: name

    args: [...string]
    _args: args

    docker.#Run & {
        workdir: "/src"
        name: "zx",
        args: ["./misc/scripts/src/\(_name).mjs"] + _args
    }
}
