#!/usr/bin/env zx

import { $, cd } from "zx";

const TAG_TO_BUILD = process.env.TAG_TO_BUILD;

if (!TAG_TO_BUILD) {
	throw new Error("TAG_TO_BUILD is not defined");
}
