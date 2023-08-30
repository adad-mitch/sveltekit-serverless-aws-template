import type { PlaywrightTestConfig } from "@playwright/test";

import dotenv from "dotenv";
dotenv.config({ path: "./.env.dev" });

const config: PlaywrightTestConfig = {
	webServer: {
		command: "npm run build && npm run preview",
		port: parseInt(process.env.SVELTEKIT_BUILD_PORT || "4173"),
	},
	testDir: "tests",
	testMatch: /(.+\.)?(test|spec)\.[jt]s/,
};

export default config;
