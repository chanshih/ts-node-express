import express from "express";
import routes from "./routes/routes";
import { errorHandler } from "./middlewares/errorHandler";

const app = express();

app.use(express.json());

// Routes
app.use("/", routes);
const path_prefixes = process.env.PATH_PREFIXES?.split(",") || [];
for (const prefix of path_prefixes) {
  app.use(prefix, routes);
}

// Global error handler (should be after routes)
app.use(errorHandler);

export default app;
