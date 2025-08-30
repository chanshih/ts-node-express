import app from "./app";
import config from "./config";
import { log } from "./log";

app.listen(config.port, () => {
  log.info('Service started', {
    service: process.env.SERVICE_NAME || 'unknown',
    port: config.port,
    nodeEnv: process.env.NODE_ENV || 'development',
    timestamp: new Date().toISOString()
  });
});
