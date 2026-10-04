import { z } from 'zod';

const envSchema = z
  .object({
    NODE_ENV: z.enum(['development', 'test', 'production']).default('development'),
    PORT: z.coerce.number().int().min(1).max(65535).default(3000),
    JWT_SECRET: z.string().min(32),
    JWT_EXPIRES_IN: z.string().regex(/^\d+[smhd]$/).default('7d'),
    JWT_COOKIE_NAME: z.string().min(1).default('prince_net_token'),
    COOKIE_SECURE: z.enum(['true', 'false']).default('false'),
    COOKIE_SAME_SITE: z.enum(['lax', 'strict', 'none']).default('lax'),
    CSRF_SECRET: z.string().min(16),
    // Optional on Vercel (same-origin via services) — empty means reflect origin
    CORS_ORIGIN: z.union([z.string().url(), z.literal('')]).default(''),
    BACKUP_DIR: z.string().min(1).default('/tmp'),
  })
  .superRefine((env, ctx) => {
    if (!env.BACKUP_DIR.startsWith('/') && !/^[A-Za-z]:[\\/]/.test(env.BACKUP_DIR)) {
      ctx.addIssue({
        code: z.ZodIssueCode.custom,
        path: ['BACKUP_DIR'],
        message: 'BACKUP_DIR must be an absolute path',
      });
    }

    // Note: In production, cookies are always secure (handled in auth.service.ts
    // and csrf.service.ts via isProduction checks), so we don't enforce
    // COOKIE_SECURE=true here — it would block startup on Vercel where
    // the user may not have set it explicitly.

    if (env.COOKIE_SAME_SITE === 'none' && env.COOKIE_SECURE !== 'true') {
      ctx.addIssue({
        code: z.ZodIssueCode.custom,
        path: ['COOKIE_SAME_SITE'],
        message: 'SameSite=None requires COOKIE_SECURE=true',
      });
    }
  });

export function validateEnv(config: Record<string, unknown>): Record<string, unknown> {
  const result = envSchema.safeParse(config);

  if (!result.success) {
    const details = result.error.issues
      .map((issue) => `${issue.path.join('.')}: ${issue.message}`)
      .join('; ');

    throw new Error(`Invalid environment configuration: ${details}`);
  }

  return result.data;
}
