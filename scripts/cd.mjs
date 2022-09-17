#!/usr/bin/env zx

import { $, cd, echo } from "zx";
import { loadJsonFile } from "load-json-file";

import { Paths } from "./utils/paths.mjs";

cd(Paths.PipesPath);

echo("Dagger updating...");

await $`dagger project update`;

echo("Dagger updated.");

echo("Metadata building...");

await $`dagger do buildMeta -l=debug --log-format=plain`;

echo("Metadata built.");

echo("Meta reading...");

const meta = await loadJsonFile(Paths.MetaPath);

echo("Meta read.");

if (!meta?.shouldBuild) {
	echo("No jobs to do.");
	process.exit(0);
}

echo("Build start...");

await $`dagger do publishAll -l=debug --log-format=plain`;

echo("Build done.");

process.exit(0);
