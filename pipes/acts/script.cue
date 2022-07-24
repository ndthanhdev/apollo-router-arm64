package acts


import (
    "universe.dagger.io/dagger/alpine"
)


#ScriptDeps: {
    alpine.#Build & {
        packages: {
            git: {}
            
        }
    }
}