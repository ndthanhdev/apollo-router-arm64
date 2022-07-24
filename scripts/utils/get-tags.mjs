#!/usr/bin/env zx
import { $, cd } from "zx";
import { emptyDir } from "fs-extra";
import upath from "upath";
import { Paths } from "./paths.mjs";

let counter = 0;

export async function getTags(url) {
	const dir = upath.resolve(Paths.Temp, `get-tags-${counter++}`);

	await emptyDir(dir);

	await $`git clone ${url} ${dir}`;

	cd(dir);

	const tags = (
		await $`git tag -l --format="%(refname:short)" "v*"`.quiet()
	).stdout
		.split(/\r?\n/g)
		.filter((tag) => !!tag)
		.map((tag) => tag.replace(/\r?\n/g, "").trim());

	return tags;
}
