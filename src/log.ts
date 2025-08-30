import { createLogger, format, transports } from "winston";

const { combine, timestamp, json, colorize, simple } = format;

export const log = createLogger({
  level: 'info',
  format: combine(
    timestamp(),
    json()
  ),
  transports: [
    new transports.Console({
      format: process.env.NODE_ENV === 'development' 
        ? combine(colorize(), simple())
        : json()
    })
  ],
});
