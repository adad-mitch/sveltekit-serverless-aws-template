import { createServer, proxy } from "aws-serverless-express";
import express from "express";

import { handler as svelteHandler } from "./handler.js";

const app = express();
app.use(svelteHandler);

const server = createServer(app);

export const handler = (event, context) => {
	proxy(server, event, context);
};
