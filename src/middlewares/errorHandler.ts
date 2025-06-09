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
  log.error(err.message);
  res.status(err.status || 500).json({
    error: err.message || "Internal Server Error",
  });
};
