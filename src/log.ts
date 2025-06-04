import { createLogger, format, transports } from "winston";

const { combine, timestamp } = format;
const timezoned = () => {
  return new Date().toLocaleString("en-SG");
};

export const log = createLogger({
  format: combine(timestamp({ format: timezoned }), format.prettyPrint()),
  transports: [new transports.Console()],
});
