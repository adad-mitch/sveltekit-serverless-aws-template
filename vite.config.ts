import { defineConfig, loadEnv } from "vite";
import { sveltekit } from "@sveltejs/kit/vite";

export default defineConfig(({ mode }) => {
	const env = loadEnv(mode, `${process.cwd()}/.env.dev`, "");
	return {
		plugins: [sveltekit()],
		test: {
			include: ["src/**/*.{test,spec}.{js,ts}"],
		},
		server: {
			host: "0.0.0.0",
			hmr: {
				clientPort: parseInt(env.SVELTEKIT_DEV_PORT) || 5173,
			},
			port: parseInt(env.SVELTEKIT_DEV_PORT) || 5173,
			watch: {
				usePolling: true,
			},
		},
	};
});
