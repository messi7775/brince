import { NestFactory } from '@nestjs/core';
import { ValidationPipe, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import helmet from 'helmet';
import { AppModule } from './app.module';

async function bootstrap(): Promise<void> {
    const logger = new Logger('Bootstrap');

    const app = await NestFactory.create(AppModule, {
        logger: ['error', 'warn', 'log'],
    });

    const config = app.get(ConfigService);

    const port = config.get<number>('PORT', 3000);
    const apiPrefix = config.get<string>('API_PREFIX', 'api/v1');
    const corsOriginRaw = config.get<string>('CORS_ORIGIN', '');
    // When CORS_ORIGIN is empty, reflect the request origin so the API works on any domain.
    const corsOrigin: string | true = corsOriginRaw || true;

    // Security headers
    app.use(helmet());

    // CORS
    app.enableCors({
        origin: corsOrigin,
        credentials: true,
        methods: ['GET', 'POST', 'PATCH', 'PUT', 'DELETE', 'OPTIONS'],
        allowedHeaders: ['Content-Type', 'Authorization', 'x-csrf-token'],
        exposedHeaders: [],
    });

    // Global prefix
    app.setGlobalPrefix(apiPrefix);

    // Validation (class-validator)
    app.useGlobalPipes(
        new ValidationPipe({
            whitelist: true,
            forbidNonWhitelisted: true,
            transform: true,
            transformOptions: { enableImplicitConversion: false },
        }),
    );

    app.enableShutdownHooks();

    await app.listen(port);

    logger.log(`Prince Net API running on http://localhost:${port}/${apiPrefix}`);
    logger.log(`CORS origin: ${corsOrigin === true ? 'reflect (any)' : corsOrigin}`);
    logger.log(`Environment: ${config.get<string>('NODE_ENV', 'development')}`);
}

bootstrap().catch((err) => {
    console.error('Fatal bootstrap error:', err);
    process.exit(1);
});
