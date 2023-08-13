export default {
	"*.{js,ts,svelte}": "eslint",
	"*.{md,html,css,scss,js,json,ts,svelte}": [
		"prettier --write --plugin-search-dir=.",
		"prettier --check --plugin-search-dir=.",
	],
	"**/*.tf?(x)": (filenames) => filenames.map((filename) => `terraform fmt '${filename}'`),
};
