import adapter from "@sveltejs/adapter-node";

import dotenv from "dotenv";
dotenv.config({ path: "./.env.dev" });

/** @type {import('@sveltejs/kit').Config} */
const config = {
	kit: {
		adapter: adapter({
			out: process.env.SVELTEKIT_BUILD_PATH || "build",
		}),
	},
};

export default config;
