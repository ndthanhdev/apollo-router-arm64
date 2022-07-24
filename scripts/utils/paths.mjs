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

	static get MissingTagsPath() {
		return upath.resolve(Paths.Out, "missing-tags.yaml");
	}
}
