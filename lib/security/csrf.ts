// =============================================================================
// PlayTogether AI — CSRF & Cross-Origin Mutation Protection
// Validates Origin, Host, and Content-Type on state-changing API Route Handlers.
// =============================================================================

import { NextRequest } from 'next/server';

/**
 * Validates that a state-changing POST/PUT/DELETE request originated from a trusted source.
 */
export function validateMutationOrigin(req: NextRequest): { valid: boolean; reason?: string } {
  const method = req.method.toUpperCase();
  if (['GET', 'HEAD', 'OPTIONS'].includes(method)) {
    return { valid: true };
  }

  // Enforce application/json for mutations
  const contentType = req.headers.get('content-type');
  if (!contentType || !contentType.toLowerCase().includes('application/json')) {
    return { valid: false, reason: 'Invalid or missing Content-Type (must be application/json)' };
  }

  // Verify Origin / Referer matches host in production
  const origin = req.headers.get('origin');
  const host = req.headers.get('host');

  if (origin && host) {
    try {
      const originHost = new URL(origin).host;
      if (originHost !== host && !originHost.includes('localhost') && !originHost.includes('127.0.0.1')) {
        return { valid: false, reason: 'Cross-origin mutation rejected' };
      }
    } catch {
      return { valid: false, reason: 'Malformed origin header' };
    }
  }

  return { valid: true };
}
