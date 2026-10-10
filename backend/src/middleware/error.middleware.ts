// =============================================================================
// PlayTogether AI — Error Handling Middleware
// Centralized error handlers for Express pipeline.
// =============================================================================

import { Request, Response, NextFunction } from 'express';

/**
 * 404 handler — catches requests that don't match any registered route.
 */
export function notFoundHandler(req: Request, res: Response, _next: NextFunction): void {
  res.status(404).json({
    success: false,
    error: 'Not Found',
    message: `Route ${req.method} ${req.originalUrl} does not exist`,
  });
}

/**
 * Global error handler — catches unhandled errors from route handlers.
 * Never exposes stack traces, credentials, or internal details to clients.
 */
export function globalErrorHandler(
  err: Error,
  req: Request,
  res: Response,
  _next: NextFunction
): void {
  // Log internally for debugging (but don't log sensitive env vars)
  console.error(`[PlayTogether AI Error] ${req.method} ${req.originalUrl}:`, err.message);

  // Handle JSON parse errors from express.json()
  if ((err as any).type === 'entity.parse.failed') {
    res.status(400).json({
      success: false,
      error: 'Bad Request',
      message: 'Invalid JSON in request body',
    });
    return;
  }

  // Generic server error — never expose internals
  res.status(500).json({
    success: false,
    error: 'Internal Server Error',
    message: 'An unexpected error occurred. Please try again.',
  });
}
