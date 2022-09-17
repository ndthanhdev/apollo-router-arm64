import upath from "upath";

export class Paths {
	static get WorkDir() {
		return upath.resolve(__dirname, "../");
	}

	static get PipesPath() {
		return upath.resolve(this.WorkDir, "pipes");
	}

	static get Temp() {
		return upath.resolve(this.WorkDir, "temp");
	}

	static get Out() {
		return upath.resolve(this.WorkDir, "out");
	}

	static getBinFolder(version) {
		return upath.resolve(this.Out, `v${version}`);
	}

	static get MetaFolder() {
		return upath.resolve(this.Out, "meta");
	}

	static get MetaPath() {
		return upath.resolve(this.MetaFolder, "meta.json");
	}

	static get ScriptsDir() {
		return upath.resolve(this.WorkDir, "scripts");
	}
}
