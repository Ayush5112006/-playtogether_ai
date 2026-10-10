// =============================================================================
// PlayTogether AI — Server Entry Point
// Initializes Express, registers routers, and starts the HTTP server.
// =============================================================================

import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';

// Load environment variables before anything else
dotenv.config();

import healthRoutes from './routes/health.routes';
import sessionRoutes from './routes/session.routes';
import { notFoundHandler, globalErrorHandler } from './middleware/error.middleware';

const app = express();
const PORT = process.env.PORT || 3000;

// ---------------------------------------------------------------------------
// Middleware
// ---------------------------------------------------------------------------
app.use(cors());
app.use(express.json());

// Root route handler
app.get('/', (_req, res) => {
  res.json({
    success: true,
    message: 'PlayTogether AI Backend API',
    healthCheck: '/api/health',
    version: '1.0.0'
  });
});

// ---------------------------------------------------------------------------
// Routes — all under /api prefix
// ---------------------------------------------------------------------------
app.use('/api', healthRoutes);     // GET /api/health
app.use('/api', sessionRoutes);    // POST /api/sessions, /api/sessions/:id/*

// ---------------------------------------------------------------------------
// Error Handlers (must be registered AFTER routes)
// ---------------------------------------------------------------------------
app.use(notFoundHandler);
app.use(globalErrorHandler);

// ---------------------------------------------------------------------------
// Start Server
// ---------------------------------------------------------------------------
app.listen(PORT, () => {
  console.log(`[PlayTogether AI Backend] Running on http://localhost:${PORT}`);
});
