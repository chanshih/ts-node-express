import { NextFunction, Request, Response } from "express";
import { log } from "../log";

export interface AppError extends Error {
  status?: number;
}

export const errorHandler = (
  err: AppError,
  req: Request,
  res: Response,
  next: NextFunction,
) => {
  const errorLog = {
    message: err.message || "Internal Server Error",
    stack: err.stack,
    status: err.status || 500,
    method: req.method,
    url: req.url,
    userAgent: req.get('User-Agent'),
    timestamp: new Date().toISOString(),
    service: process.env.SERVICE_NAME || 'unknown'
  };
  
  log.error('Application Error', errorLog);
  
  res.status(err.status || 500).json({
    error: err.message || "Internal Server Error",
  });
};
