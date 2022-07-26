import upath from "upath";

export class Paths {
	static get WorkDir() {
		return upath.resolve(__dirname, "../");
	}

	static get Temp() {
		return upath.resolve(Paths.WorkDir, "temp");
	}

	static get Out() {
		return upath.resolve(Paths.WorkDir, "out");
	}

	static getBinFolder(version) {
		return upath.resolve(Paths.Out, `v${version}`);
	}

	static get MetaPath() {
		return upath.resolve(Paths.Out, "meta.yaml");
	}

	static get ScriptsDir() {
		return upath.resolve(Paths.WorkDir, "scripts");
	}
}
