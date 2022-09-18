#!/usr/bin/env zx

import { $, cd } from "zx";

import Semver from "semver";

import Yaml from "yaml";

import fs from "fs-extra";

import { getTags } from "./utils/get-tags.mjs";
import { Paths } from "./utils/paths.mjs";

let oMeta;

if (false) {
	oMeta = {
		missingVers: [
			"v0.12.1-alpha-defer",
			"v0.12.1-alpha-defer2",
			"v0.12.1-alpha-defer3",
			"v0.12.1-alpha-defer4",
			"v1.0.0-alpha.0",
			"v1.0.0-alpha.1",
			"v1.0.0-alpha.2",
			"v1.0.0-alpha.3",
			"v1.0.0-rc.0",
			"v1.0.0-rc.1",
		],
		shouldBuild: true,
		nextBuild: "v0.12.1-alpha-defer",
	};
} else {
	oMeta = await buildMeta();
}

let fContent = JSON.stringify(oMeta);

console.log(fContent);

await fs.emptyDir(Paths.MetaFolder);

await fs.writeFile(Paths.MetaPath, fContent, {
	flag: "w+",
});

async function buildMeta() {
	const RouterRepoUrl = "https://github.com/apollographql/router.git";

	const routerTags = await getTags(RouterRepoUrl);

	console.log({ routerTags });

	const ArmRepoUrl = "https://github.com/ndthanhdev/apollo-router-arm64.git";

	const armTags = await getTags(ArmRepoUrl);

	console.log({ armTags });

	let missingVers = routerTags.filter((tag) => !armTags.includes(tag));

	missingVers = missingVers.filter((tag) => Semver.valid(tag, {}));

	missingVers = Semver.sort(missingVers);

	console.log("valid", missingVers);

	missingVers = missingVers.filter((tag) =>
		Semver.satisfies(tag, ">=0.9.0", {
			includePrerelease: true,
		})
	);

	console.log("missing", missingVers);

	const ExcludeVersions = new Set([
		"v0.12.1-alpha-defer",
		"v0.12.1-alpha-defer2",
		"v0.12.1-alpha-defer3",
		"v0.12.1-alpha-defer4",
	]);

	missingVers = missingVers.filter((tag) => !ExcludeVersions.has(tag));

	console.log("excluded", missingVers);

	const nextBuild = missingVers[0];

	return {
		missingVers,
		shouldBuild: !!nextBuild,
		nextBuild,
	};
}
