import app from "./app";
import config from "./config";
import { log } from "./log";

app.listen(config.port, () => {
  log.info(`Server running on port ${config.port}`);
});
