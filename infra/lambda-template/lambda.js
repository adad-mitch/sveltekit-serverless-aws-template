import { createServer, proxy } from "aws-serverless-express";
import express from "express";

import { handler as svelteHandler } from "./handler.js";

const app = express();
app.use(svelteHandler);

const binaryMimeTypes = [
	'application/javascript',
	'application/json',
	'application/octet-stream',
	'application/xml',
	'font/eot',
	'font/opentype',
	'font/otf',
	'image/jpeg',
	'image/png',
	'image/svg+xml',
	'text/comma-separated-values',
	'text/css',
	'text/html',
	'text/javascript',
	'text/plain',
	'text/text',
	'text/xml'
]

const server = createServer(app, null, binaryMimeTypes);

export const handler = async (event, context) => {
	console.log(JSON.stringify(event));
	const res = await proxy(server, event, context, 'PROMISE').promise;

	// Browsers won't decode 4xx and 5xx responses, so we need to decode them here
	if (res.statusCode >= 400) {
		res.body = Buffer.from(res.body, 'base64').toString('utf8');
	}

	return res;
};
