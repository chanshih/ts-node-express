import { NodeSDK } from '@opentelemetry/sdk-node';
import { getNodeAutoInstrumentations } from '@opentelemetry/auto-instrumentations-node';
import { OTLPTraceExporter } from '@opentelemetry/exporter-otlp-http';

// Configure OTLP exporter for AWS X-Ray
const traceExporter = new OTLPTraceExporter({
  url: process.env.OTEL_EXPORTER_OTLP_ENDPOINT || 'http://localhost:4318/v1/traces',
});

// Initialize OpenTelemetry SDK
const sdk = new NodeSDK({
  traceExporter,
  instrumentations: [getNodeAutoInstrumentations({
    '@opentelemetry/instrumentation-fs': {
      enabled: false, // Disable file system instrumentation
    },
  })],
  serviceName: process.env.SERVICE_NAME || 'microservice',
  serviceVersion: process.env.SERVICE_VERSION || '1.0.0',
});

// Start tracing
sdk.start();

export default sdk;