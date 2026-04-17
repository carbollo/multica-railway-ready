# Deploying Multica on Railway

This setup uses two Railway services from the same repository:

1. `multica-backend` using `Dockerfile`
2. `multica-frontend` using `Dockerfile.web`

You can also add a Railway PostgreSQL service, then connect it to the backend with `DATABASE_URL`.

## 1) Backend service (`multica-backend`)

- Create a new service from this repo.
- Set the Dockerfile path to `Dockerfile`.
- Set these environment variables:
  - `DATABASE_URL=${{Postgres.DATABASE_URL}}` (from Railway Postgres)
  - `DATABASE_SSLMODE=require`
  - `JWT_SECRET=<random-long-secret>`
  - `PORT=8080`
  - `FRONTEND_ORIGIN=https://<your-frontend-domain>`
  - `MULTICA_APP_URL=https://<your-frontend-domain>`
  - `GOOGLE_REDIRECT_URI=https://<your-frontend-domain>/auth/callback`

Notes:
- Migrations run automatically in container startup (`docker/entrypoint.sh`).
- If your `DATABASE_URL` already contains `sslmode=...`, it is respected as-is.

## 2) Frontend service (`multica-frontend`)

- Create a second Railway service from this repo.
- Set the Dockerfile path to `Dockerfile.web`.
- Add build arg:
  - `REMOTE_API_URL=https://<your-backend-domain>`
- Set runtime env:
  - `HOSTNAME=0.0.0.0`
  - `NEXT_PUBLIC_WS_URL=wss://<your-backend-domain>/ws` (optional but recommended)
  - `NEXT_PUBLIC_GOOGLE_CLIENT_ID=<if using Google OAuth>`

## 3) Quick verification

After deployment:

- Open frontend URL, create/login user.
- Verify backend health:
  - `GET https://<your-backend-domain>/api/health`
- Confirm auth callback URL matches Railway frontend domain.

## 4) Minimum env-only DB connection

The backend only needs `DATABASE_URL` to connect to Postgres.
When running in Railway, if `DATABASE_URL` lacks `sslmode`, Multica auto-adds `sslmode=require`.
