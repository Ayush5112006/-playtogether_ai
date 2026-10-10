// =============================================================================
// PlayTogether AI — Health Routes
// =============================================================================

import { Router, Request, Response } from 'express';
import { checkSupabaseConnection } from '../config/supabase';

const router = Router();

// GET /api/health
router.get('/health', async (req: Request, res: Response) => {
  const dbHealth = await checkSupabaseConnection();

  res.json({
    status: 'ok',
    appName: 'PlayTogether AI Backend',
    timestamp: new Date().toISOString(),
    database: {
      provider: 'supabase',
      configured: dbHealth.configured,
      connected: dbHealth.connected,
      status: dbHealth.status,
      message: dbHealth.message,
    },
  });
});

export default router;
