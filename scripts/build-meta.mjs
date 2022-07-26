#!/usr/bin/env zx

import { $, cd } from "zx";

import Semver from "semver";

import Yaml from "yaml";

import fs from "fs-extra";

import { getTags } from "./utils/get-tags.mjs";
import { Paths } from "./utils/paths.mjs";

const RouterRepoUrl = "git@github.com:apollographql/router.git";

const routerTags = await getTags(RouterRepoUrl);

console.log({ routerTags });

const ArmRepoUrl = "git@github.com:ndthanhdev/apollo-router-arm64.git";

const armTags = await getTags(ArmRepoUrl);

console.log({ armTags });

let missingVers = routerTags.filter((tag) => !armTags.includes(tag));

missingVers = missingVers
	.filter((tag) => Semver.valid(tag))
	.filter((tag) => Semver.satisfies(tag, ">=0.9.0"));

missingVers = Semver.rsort(missingVers);

const nextBuild = missingVers[0];

const fContent = Yaml.stringify({ missingVers, nextBuild });

console.log(fContent);

await fs.mkdirp(Paths.Out);

await fs.writeFile(Paths.MetaPath, fContent, {
	flag: "w+",
});