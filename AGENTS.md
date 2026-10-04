# Prince Net — Base44 Development Notes

## Architecture

pnpm monorepo (Node 22, pnpm 11):
- `apps/api` — NestJS API (Prisma + PostgreSQL), runs on internal port 3001
- `apps/web` — Vite + React SPA, runs on port 5173 (mapped to host port 3000)
- `packages/{types,validation,config}` — shared TypeScript packages (CJS, built to `dist/`)

**Single-origin wiring:** Vite proxies `/api` → `http://api:3001` (set via `API_PROXY_TARGET`).
The web app uses a relative `/api/v1` base URL, so all API calls go through the Vite proxy.

## Database

The app connects to a **remote Neon PostgreSQL database** via `DATABASE_URL` (stored in `/run/base44/app.env`).
The local `db` service (PostgreSQL 16) is still defined in compose but nothing depends on it — it's a fallback for local-only development.

**Neon IPv4 workaround:** The Prisma schema engine (Rust binary) cannot connect to Neon via IPv6. The `scripts/force-ipv4.sh` script resolves the DB hostname to IPv4 and pins it in `/etc/hosts` before running Prisma commands. Both `migrate` and `api` services source this script.

**Neon cold start:** Neon scales to zero when idle. The first `prisma migrate deploy` may time out on the advisory lock (P1002). Retry after a few seconds — the database warms up.

## Compose Services (`docker-compose.base44.yml`)

- `db` — PostgreSQL 16 (local fallback, nothing depends on it)
- `migrate` — one-shot: forces IPv4, builds packages, generates Prisma client, applies migrations, seeds. Must complete before API starts.
- `api` — NestJS dev (`nest start --watch --path tsconfig.dev.json`), depends on `migrate` completing
- API watch output is isolated in `apps/api/.dev-dist`; normal `nest build` uses `dist`. Do not share these directories: a concurrent build cleans `dist` while the watcher restarts, which can leave the watcher alive but the API child dead (`Cannot find module dist/main`). Verify both a cold restart and a normal API build while watch is running, then confirm `/api/v1/health` and Compose health remain healthy.
- `web` — Vite dev, depends on `api` being healthy

## Key Setup Details

**Stack versions (Oct 2026 maintenance pass):** NestJS 11 (Express 5, `@types/express` 5), Prisma 6.19, TypeScript 5.9, Vite 7 + `@vitejs/plugin-react` 5, React 18, Tailwind 3, ESLint 8. Deliberately NOT upgraded (breaking): Prisma 7, Tailwind 4, ESLint 9+, React 19, zod 4, react-router 7.

**Running pnpm inside the container:** use `CI=true` (non-TTY, allows module purge) — the store lives at `/app/.pnpm-store/v11`. After dependency changes run `pnpm install` in one container, then `docker compose restart api web`.

- **Shared packages must be built** (`pnpm build:packages`) before the API or seed can use them — they're CJS packages consumed via `workspace:*` symlinks.
- **Prisma client must be generated** (`pnpm prisma:generate`) on each startup — the generated client lives in `apps/api/src/generated/prisma` which is on the bind mount.
- The `migrate` service runs `. /app/scripts/force-ipv4.sh && pnpm build:packages && pnpm prisma:generate && pnpm prisma:deploy && pnpm prisma:seed` — this ordering is required (seed imports from built packages + generated Prisma client).
- `apps/api/.env` exists locally (gitignored) but Docker env vars take precedence (dotenv doesn't override `process.env`).
- `CORS_ORIGIN` must be a valid URL (Zod validation in `apps/api/src/config/env.validation.ts`).
- `.env.base44-defaults` provides non-secret config values (cookie names, CORS origin, backup dir, admin email, etc.). Real secrets in `/run/base44/app.env` override these.

## Auth Flow

- JWT in HttpOnly cookies + CSRF double-submit cookie (`csrf-csrf` package).
- Web app fetches CSRF token from `GET /api/v1/auth/csrf` before mutations.
- Admin login: `ibrabra651@gmail.com` + `ADMIN_PASSWORD` (real user-provided secret).

## Secrets (in `/run/base44/app.env`)

- `DATABASE_URL` — Neon PostgreSQL connection string (remote managed database)
- `JWT_SECRET` — min 32 chars (generated dev placeholder)
- `CSRF_SECRET` — min 16 chars (generated dev placeholder)
- `ADMIN_PASSWORD` — min 12 chars (real user-provided value)

## Verification

- Web: `curl -sf http://localhost:3000` returns Vite-served HTML
- API health: `curl -sf http://localhost:3000/api/v1/health` → `{"status":"ok","database":"ok"}`
- CSRF: `curl -sf http://localhost:3000/api/v1/auth/csrf` returns a token
- Login: POST to `/api/v1/auth/login` with `ibrabra651@gmail.com` + `ADMIN_PASSWORD`
- DB consistency (sale totals) — run via psql against the Neon database (not the local `db` service). The amount column is `total_price` (there is no `line_total`):
  `SELECT s.id FROM sales s JOIN sale_items si ON si.sale_id = s.id GROUP BY s.id, s.total_amount HAVING SUM(si.total_price) <> s.total_amount;`
