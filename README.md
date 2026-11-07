# Pureoe Lab platform

Responsive orange-themed storefront and partner portal, served by an Express API and PostgreSQL on Railway.

## Current implementation

- Customer/partner registration, login and signed HTTP-only session cookie.
- Unique referral codes and sponsor links.
- Member dashboard with rank, downline counts, level sales, order history and wallet ledger.
- Product catalogue and administrator product CRUD.
- Basket and manual-EFT order creation.
- Admin EFT confirmation, cancellation and refunds.
- Configurable rank rates, thresholds and bonuses; rank creation endpoint.
- Server-side team sales qualification and idempotent per-order commission ledger.
- Admin commission/wallet approval, withdrawal request workflow and audit log.
- Platform switches for orders, commissions, withdrawals, inventory and monthly activation.
- PostgreSQL schema initialization on startup; health endpoint at /health.

## Deploy on Railway

Railway builds the root Dockerfile. Required service variables:
- DATABASE_URL — Railway reference to Postgres.DATABASE_URL
- JWT_SECRET — strong random secret
- BOOTSTRAP_ADMIN_KEY — one-time key for first admin setup
- NODE_ENV=production

The application listens on Railway's PORT and uses /health for health checks.

## First administrator

Open the website, choose **Sign in / Join** → **First admin setup**, then supply BOOTSTRAP_ADMIN_KEY, admin name, email and a unique password (12+ characters). The endpoint refuses further bootstrap after an administrator exists. Keep the setup key private; rotate/remove it after initial setup.

## Default safety settings

All of these are OFF on initial install:
- orders_enabled
- commissions_enabled
- withdrawals_enabled
- inventory_tracking
- monthly_activation_enabled

The seeded product catalogue is hidden (active=false), with R200 placeholder prices and zero stock. An administrator must verify supplier, ingredient, label, product safety and pricing details, then edit/activate products. Enter real EFT instructions only after confirming the receiving bank account.

## MLM defaults

- Rank 1: Level 1 20%; configured R600 once-off bonus.
- Rank 2: Level 1 20% + Level 2 10%; Level 1 team sales target R6,000; configured R1,200 bonus.
- Rank 3: Level 1 20% + Level 2 10% + Level 3 5%; combined Level 1 + Level 2 target R12,000.
- Further ranks can be added through the admin ranks API and configured with level rates and thresholds.

Commissions are created as pending ledger credits only when the commissions switch is enabled and an admin confirms a paid EFT order. Admin approval moves eligible credits to the member's available wallet. Refunds reverse related commission ledger entries and wallet credits. Withdrawals require a separate admin approval and paid status.

## API overview

Public: GET /health, GET /api/public, POST /api/register, POST /api/login, POST /api/logout, POST /api/setup-admin.
Authenticated member: GET /api/me, POST /api/orders, POST /api/withdrawals.
Admin: /api/admin/summary, /users, /orders, /orders/:id/confirm, /orders/:id/cancel, /orders/:id/refund, /products, /ranks, /commissions, /wallet, /withdrawals, /audit, /settings.

## Before accepting real orders or paying commissions

This is an operational staging/MVP foundation, not a legally approved production MLM or financial platform. Complete independent South African legal review (Consumer Protection Act/direct selling and pyramid scheme restrictions, POPIA, tax and marketing claims); verify all product details and supplier authorisations; define the Rank 1 bonus trigger and monthly R700 qualification policy; test registration, order, EFT, refund, rank, commission, wallet and withdrawal flows; configure backups, monitoring, privacy notices, terms, support and bank details. The monthly R700 activation switch is currently a configuration placeholder and is not used to qualify commissions. Do not pay or promise commissions until the programme is reviewed and tested.
