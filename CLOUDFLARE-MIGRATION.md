# Pureoe Lab — Cloudflare-native migration
Dedicated resources: Worker `pureoe-lab`, D1 `pureoe-lab-app-db` (WEUR primary), R2 `pureoe-lab-assets`, Queue `pureoe-lab-events` (EU).
Apply `cloudflare/schema.sql`, configure `SESSION_SECRET` and `BOOTSTRAP_ADMIN_KEY` as Worker secrets, then deploy with Wrangler. Orders, commissions and withdrawals start OFF. Seeded products are unpublished placeholders. Railway remains untouched as rollback until cutover is approved.
