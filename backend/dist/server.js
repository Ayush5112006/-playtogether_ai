"use strict";
// =============================================================================
// PlayTogether AI — Server Entry Point
// Initializes Express, registers routers, and starts the HTTP server.
// =============================================================================
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const cors_1 = __importDefault(require("cors"));
const dotenv_1 = __importDefault(require("dotenv"));
// Load environment variables before anything else
dotenv_1.default.config();
const health_routes_1 = __importDefault(require("./routes/health.routes"));
const session_routes_1 = __importDefault(require("./routes/session.routes"));
const error_middleware_1 = require("./middleware/error.middleware");
const app = (0, express_1.default)();
const PORT = process.env.PORT || 3000;
// ---------------------------------------------------------------------------
// Middleware
// ---------------------------------------------------------------------------
app.use((0, cors_1.default)());
app.use(express_1.default.json());
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
app.use('/api', health_routes_1.default); // GET /api/health
app.use('/api', session_routes_1.default); // POST /api/sessions, /api/sessions/:id/*
// ---------------------------------------------------------------------------
// Error Handlers (must be registered AFTER routes)
// ---------------------------------------------------------------------------
app.use(error_middleware_1.notFoundHandler);
app.use(error_middleware_1.globalErrorHandler);
// ---------------------------------------------------------------------------
// Start Server
// ---------------------------------------------------------------------------
app.listen(PORT, () => {
    console.log(`[PlayTogether AI Backend] Running on http://localhost:${PORT}`);
});
