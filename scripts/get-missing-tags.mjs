#!/usr/bin/env zx

import { $, cd } from "zx";

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

const missingTags = routerTags.filter((tag) => !armTags.includes(tag));

console.log({ missingTags });

await fs.mkdirp(Paths.Out);

const value = Yaml.stringify({ value: missingTags });

await fs.writeFile(Paths.MissingTagsPath, value, {
	flag: "w+",
});
