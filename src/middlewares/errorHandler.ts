import { Request, Response } from "express";
import { log } from "../log";

export interface AppError extends Error {
  status?: number;
}

export const errorHandler = (err: AppError, req: Request, res: Response) => {
  log.error(err);
  res.status(err.status || 500).json({
    message: err.message || "Internal Server Error",
  });
};
