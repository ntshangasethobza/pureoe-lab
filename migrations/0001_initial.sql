PRAGMA foreign_keys = ON;
CREATE TABLE users (
 id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, email TEXT NOT NULL UNIQUE,
 password_hash TEXT NOT NULL, role TEXT NOT NULL DEFAULT 'customer' CHECK(role IN ('customer','member','admin')),
 referral_code TEXT NOT NULL UNIQUE, referred_by INTEGER REFERENCES users(id), rank INTEGER NOT NULL DEFAULT 1,
 created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX idx_users_sponsor ON users(referred_by);
CREATE TABLE products (
 id INTEGER PRIMARY KEY AUTOINCREMENT, sku TEXT UNIQUE, name TEXT NOT NULL, description TEXT NOT NULL DEFAULT '',
 price_cents INTEGER NOT NULL CHECK(price_cents>=0), stock INTEGER NOT NULL DEFAULT 0, active INTEGER NOT NULL DEFAULT 0,
 image_key TEXT, created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE orders (
 id INTEGER PRIMARY KEY AUTOINCREMENT, user_id INTEGER NOT NULL REFERENCES users(id), total_cents INTEGER NOT NULL,
 status TEXT NOT NULL DEFAULT 'pending_eft' CHECK(status IN ('pending_eft','paid','cancelled','refunded')),
 eft_reference TEXT, created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP, paid_at TEXT
);
CREATE INDEX idx_orders_user_status ON orders(user_id,status);
CREATE TABLE order_items (
 id INTEGER PRIMARY KEY AUTOINCREMENT, order_id INTEGER NOT NULL REFERENCES orders(id), product_id INTEGER NOT NULL REFERENCES products(id),
 quantity INTEGER NOT NULL, unit_price_cents INTEGER NOT NULL, product_name TEXT NOT NULL
);
CREATE TABLE rank_config (
 rank INTEGER PRIMARY KEY, name TEXT NOT NULL, level_rates TEXT NOT NULL DEFAULT '{}',
 level1_target_cents INTEGER NOT NULL DEFAULT 0, combined_target_cents INTEGER NOT NULL DEFAULT 0,
 bonus_cents INTEGER NOT NULL DEFAULT 0, enabled INTEGER NOT NULL DEFAULT 1
);
CREATE TABLE commission_ledger (
 id INTEGER PRIMARY KEY AUTOINCREMENT, recipient_id INTEGER NOT NULL REFERENCES users(id), source_user_id INTEGER NOT NULL REFERENCES users(id),
 order_id INTEGER NOT NULL REFERENCES orders(id), level INTEGER NOT NULL, amount_cents INTEGER NOT NULL,
 status TEXT NOT NULL DEFAULT 'pending' CHECK(status IN ('pending','approved','reversed')),
 created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP, UNIQUE(recipient_id,order_id,level)
);
CREATE TABLE wallet_ledger (
 id INTEGER PRIMARY KEY AUTOINCREMENT, user_id INTEGER NOT NULL REFERENCES users(id), kind TEXT NOT NULL,
 amount_cents INTEGER NOT NULL, status TEXT NOT NULL DEFAULT 'pending', reference TEXT, note TEXT,
 created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE withdrawal_requests (
 id INTEGER PRIMARY KEY AUTOINCREMENT, user_id INTEGER NOT NULL REFERENCES users(id), amount_cents INTEGER NOT NULL,
 status TEXT NOT NULL DEFAULT 'requested' CHECK(status IN ('requested','approved','paid','rejected')),
 bank_details TEXT NOT NULL, created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP, updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE app_settings (key TEXT PRIMARY KEY, value TEXT NOT NULL);
CREATE TABLE audit_logs (
 id INTEGER PRIMARY KEY AUTOINCREMENT, actor_id INTEGER REFERENCES users(id), action TEXT NOT NULL,
 entity_type TEXT, entity_id TEXT, details TEXT NOT NULL DEFAULT '{}', created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);
INSERT INTO rank_config(rank,name,level_rates,level1_target_cents,combined_target_cents,bonus_cents) VALUES
 (1,'Starter','{"1":20}',600000,0,60000),
 (2,'Builder','{"1":20,"2":10}',600000,1200000,120000),
 (3,'Leader','{"1":20,"2":10,"3":5}',600000,1200000,0);
INSERT INTO app_settings(key,value) VALUES('platform','{"orders_enabled":false,"commissions_enabled":false,"withdrawals_enabled":false,"inventory_tracking":false,"monthly_activation_enabled":false,"currency":"ZAR","environment":"staging","eft_instructions":""}');
