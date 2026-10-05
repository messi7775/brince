import { PrismaClient } from '../src/generated/prisma';
import { PrismaPg } from '@prisma/adapter-pg';
import {
    DEFAULT_PACKAGES,
    DEFAULT_SETTINGS,
} from '@prince-net/config';

// ─── Helpers ──────────────────────────────────────────────────
function requireEnv(name: string): string {
    const value = process.env[name];
    if (!value || value.trim().length === 0) {
        throw new Error(`Missing required environment variable: ${name}`);
    }
    return value;
}

// ─── Main ─────────────────────────────────────────────────────
async function main(): Promise<void> {
    const connectionString = requireEnv('DATABASE_URL');
    const adminEmail = process.env.ADMIN_EMAIL?.trim() || 'admin@prince-net.local';

    const adapter = new PrismaPg({ connectionString });
    const prisma = new PrismaClient({ adapter });

    try {
        // ─── Packages ───
        for (const pkg of DEFAULT_PACKAGES) {
            await prisma.package.upsert({
                where: { name: pkg.name },
                update: {},
                create: {
                    name: pkg.name,
                    price: pkg.price,
                    dataSizeMb: pkg.dataSizeMb,
                    hours: pkg.hours,
                    color: pkg.color,
                    status: 'ACTIVE',
                },
            });
        }
        console.log(`✅ Packages seeded: ${DEFAULT_PACKAGES.length}`);

        // ─── Settings (singleton) ───
        await prisma.settings.upsert({
            where: { singletonKey: 'main' },
            update: {},
            create: {
                singletonKey: 'main',
                networkName: DEFAULT_SETTINGS.networkName,
                currencyName: DEFAULT_SETTINGS.currencyName,
                currencySymbol: DEFAULT_SETTINGS.currencySymbol,
                adminEmail,
                lowStockThreshold: DEFAULT_SETTINGS.lowStockThreshold,
            },
        });
        console.log(`✅ Settings initialized (singletonKey = "main")`);

        console.log('');
        console.log('🎉 Seed completed successfully.');
    } finally {
        await prisma.$disconnect();
    }
}

main().catch((err) => {
    console.error('❌ Seed failed:', err);
    process.exit(1);
});
