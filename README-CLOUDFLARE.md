# Pureoe Lab — Cloudflare-native rebuild

This branch replaces the Express/PostgreSQL runtime with Cloudflare Workers, D1, R2, Queues and Cron Triggers. The existing Railway branch and production database are intentionally left unchanged.

## Architecture
- Workers: API, authentication, storefront routing and admin/member endpoints.
- Workers Static Assets: responsive storefront served from public/.
- D1: relational users, sponsor tree, products, orders, rank configuration, commission/wallet ledgers, withdrawals, settings and audit trail.
- R2: product images; the API accepts existing JPG/PNG/WebP base64 uploads and stores the binary object in R2.
- Queues: paid-order commission processing with retry and idempotent commission ledger keys.
- Cron: daily retention maintenance. Cloudflare Cron uses UTC.

## Cloudflare resources to create
Run from this repository after installing Node.js 22:
```sh
npm install
npx wrangler login
npx wrangler d1 create pureoe-lab
npx wrangler r2 bucket create pureoe-lab-products
npx wrangler queues create pureoe-lab-events
```
Copy the D1 database_id returned by Wrangler into wrangler.jsonc replacing REPLACE_WITH_D1_DATABASE_ID.

Apply the schema and deploy:
```sh
npx wrangler d1 migrations apply pureoe-lab --remote
npx wrangler secret put JWT_SECRET
npx wrangler secret put BOOTSTRAP_ADMIN_KEY
npx wrangler deploy
```
Use unique, randomly generated secrets. Never commit secrets or paste them into source files.

## GitHub Actions deployment
Add these repository Actions secrets:
- CLOUDFLARE_API_TOKEN — token with Workers Scripts edit, D1 edit and R2 edit permissions for this account.
- CLOUDFLARE_ACCOUNT_ID — Cloudflare account ID.

The workflow deploys on pushes to cloudflare-native. The D1 database ID must be configured before the first deployment. Set the Worker secrets once with Wrangler.

## First administrator
After deployment, open the storefront, choose Sign in / Join → First admin setup, and supply the private BOOTSTRAP_ADMIN_KEY, administrator name, email and a unique password of at least 12 characters. The endpoint refuses further bootstrap after an administrator exists. Remove/rotate the bootstrap secret after setup.

## Safety defaults
Orders, commissions, withdrawals, inventory tracking and monthly activation remain OFF. The seeded catalogue is hidden and prices are placeholders. Verify supplier authorisation, product details, pricing, stock, bank/EFT instructions and all programme terms before enabling commerce.

## Important release gates
1. Review and test authentication, registration, referral links, product image uploads, orders, EFT confirmation, cancellation/refund, rank changes, commission idempotency, wallet approvals and withdrawals.
2. Conduct South African legal/accounting review of direct-selling/MLM structure, consumer protection, POPIA, tax, marketing claims and payment processes.
3. Configure custom domain, backups/export procedures, monitoring, alerting and incident response.
4. Migrate existing production records only after an explicit data mapping, backup and reconciliation plan. No Railway data is automatically copied by this branch.

This is a staging foundation, not an approved production financial platform. Do not enable payouts or commissions until independent testing and compliance review are complete.
