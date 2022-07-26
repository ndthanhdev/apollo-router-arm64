#!/usr/bin/env zx

import { $, cd } from "zx";
import { Paths } from "./utils/paths.mjs";

const TARGET_VERSION = process.env.TARGET_VERSION;

if (!TARGET_VERSION) {
	throw new Error("TARGET_VERSION is not defined");
}

const REGISTRY_PASSWORD = process.env.REGISTRY_PASSWORD;

const USER = "Bot <ndthanhdev@outlook.com>";
const flags = [
	"--no-history",

	"--repo",
	`git@${REGISTRY_PASSWORD}@github.com:ndthanhdev/apollo-router-arm64.git`,

	"--silent",

	"--tag",
	`v${TARGET_VERSION}`,

	"--user",
	USER,

	"--src",
	`${Paths.getBinFolder(TARGET_VERSION)}`,
];

await $`yarn gh-pages ${flags}`;
