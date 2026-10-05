import { z } from 'zod';

const envSchema = z
    .object({
        NODE_ENV: z
            .enum(['development', 'test', 'production'])
            .default('development'),

        PORT: z
            .coerce
            .number()
            .int()
            .min(1)
            .max(65535)
            .default(3000),

        // Optional — empty means reflect origin (works on any domain)
        CORS_ORIGIN: z
            .union([z.string().url(), z.literal('')])
            .default(''),

        BACKUP_DIR: z
            .string()
            .min(1)
            .default('/tmp'),
    })
    .superRefine((env, ctx) => {
        if (
            !env.BACKUP_DIR.startsWith('/') &&
            !/^[A-Za-z]:[\\/]/.test(env.BACKUP_DIR)
        ) {
            ctx.addIssue({
                code: z.ZodIssueCode.custom,
                path: ['BACKUP_DIR'],
                message: 'BACKUP_DIR must be an absolute path',
            });
        }
    });

export function validateEnv(
    config: Record<string, unknown>,
): Record<string, unknown> {
    const result = envSchema.safeParse(config);

    if (!result.success) {
        const details = result.error.issues
            .map((issue) => `${issue.path.join('.')}: ${issue.message}`)
            .join('; ');

        throw new Error(`Invalid environment configuration: ${details}`);
    }

    return result.data;
}
