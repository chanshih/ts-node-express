import express from "express";
import routes from "./routes/routes";
import { errorHandler } from "./middlewares/errorHandler";
import { log } from "./log";
import AWSXRay from "aws-xray-sdk-core";
import XRayExpress from "aws-xray-sdk-express";

// Configure X-Ray
AWSXRay.config([
  AWSXRay.plugins.EKSPlugin,
  AWSXRay.plugins.EC2Plugin
]);

// Capture AWS SDK calls
const AWS = AWSXRay.captureAWS(require('aws-sdk'));

const app = express();

// X-Ray tracing middleware (must be first)
app.use(XRayExpress.openSegment(process.env.SERVICE_NAME || 'microservice'));

app.use(express.json());

// Request logging middleware
app.use((req, res, next) => {
  const start = Date.now();
  
  res.on('finish', () => {
    const duration = Date.now() - start;
    log.info('HTTP Request', {
      method: req.method,
      url: req.url,
      status: res.statusCode,
      duration: `${duration}ms`,
      userAgent: req.get('User-Agent'),
      service: process.env.SERVICE_NAME || 'unknown'
    });
  });
  
  next();
});

// Routes
app.use("/", routes);
const path_prefixes = process.env.PATH_PREFIXES?.split(",") || [];
for (const prefix of path_prefixes) {
  app.use(prefix, routes);
}

// Global error handler (should be after routes)
app.use(errorHandler);

// X-Ray close segment (must be last)
app.use(XRayExpress.closeSegment());

export default app;
