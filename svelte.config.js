import adapter from "@sveltejs/adapter-node";
import { vitePreprocess } from "@sveltejs/kit/vite";

import dotenv from "dotenv";
dotenv.config({ path: "./.env.dev" });

/** @type {import('@sveltejs/kit').Config} */
const config = {
	preprocess: vitePreprocess(),

	kit: {
		adapter: adapter({
			out: process.env.SVELTEKIT_BUILD_PATH || "build",
		}),
	},
};

export default config;
