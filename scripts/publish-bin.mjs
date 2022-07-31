#!/usr/bin/env zx

import { $, cd } from "zx";
import { Paths } from "./utils/paths.mjs";

const TARGET_VERSION = process.env.TARGET_VERSION;

if (!TARGET_VERSION) {
	throw new Error("TARGET_VERSION is not defined");
}

cd(Paths.ScriptsDir);

const GH_TOKEN = process.env.GH_TOKEN;

const USER = "Bot <ndthanhdev@outlook.com>";
const flags = [
	"--no-history",

	"--repo",
	`https://${GH_TOKEN}@github.com/ndthanhdev/apollo-router-arm64.git`,

	"--tag",
	`${TARGET_VERSION}`,

	"--message",
	`Publish ${TARGET_VERSION}`,

	"--user",
	USER,

	"--dist",
	`${Paths.getBinFolder(TARGET_VERSION)}`,
];

await $`yarn gh-pages ${flags}`;
