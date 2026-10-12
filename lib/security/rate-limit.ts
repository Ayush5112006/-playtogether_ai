// =============================================================================
// PlayTogether AI — Server-Side Rate Limiter
// Sliding-window rate limiter protecting auth, session mutations, and AI requests.
// =============================================================================

interface RateLimitRecord {
  count: number;
  resetAt: number;
}

// In-memory sliding window bucket store with automatic cleanup
const buckets = new Map<string, RateLimitRecord>();

/**
 * Checks and increments rate limit for a client key and action type.
 * @param key Client IP, User ID, or identifier
 * @param action Namespace, e.g. 'auth:login', 'session:create', 'answer:submit'
 * @param maxRequests Maximum requests allowed within duration
 * @param windowSeconds Window length in seconds
 */
export function checkRateLimit(
  key: string,
  action: string,
  maxRequests = 30,
  windowSeconds = 60
): { allowed: boolean; remaining: number; resetInSeconds: number } {
  const bucketKey = `${action}:${key}`;
  const now = Date.now();
  const windowMs = windowSeconds * 1000;

  let record = buckets.get(bucketKey);

  if (!record || now > record.resetAt) {
    record = {
      count: 1,
      resetAt: now + windowMs,
    };
    buckets.set(bucketKey, record);
    return {
      allowed: true,
      remaining: maxRequests - 1,
      resetInSeconds: windowSeconds,
    };
  }

  if (record.count >= maxRequests) {
    const resetInSeconds = Math.max(1, Math.ceil((record.resetAt - now) / 1000));
    return {
      allowed: false,
      remaining: 0,
      resetInSeconds,
    };
  }

  record.count += 1;
  const remaining = maxRequests - record.count;
  const resetInSeconds = Math.max(1, Math.ceil((record.resetAt - now) / 1000));

  return {
    allowed: true,
    remaining,
    resetInSeconds,
  };
}

// Periodic cleanup of expired rate limit buckets to prevent memory accumulation
if (typeof setInterval !== 'undefined') {
  setInterval(() => {
    const now = Date.now();
    for (const [key, record] of buckets.entries()) {
      if (now > record.resetAt) {
        buckets.delete(key);
      }
    }
  }, 120000);
}
