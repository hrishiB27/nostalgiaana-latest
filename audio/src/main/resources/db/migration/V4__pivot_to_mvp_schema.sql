DROP TABLE IF EXISTS playlist_content;
DROP TABLE IF EXISTS favorites;
DROP TABLE IF EXISTS listening_history;

ALTER TABLE payments DROP COLUMN subscription_id;
DROP TABLE IF EXISTS subscriptions;
DROP TABLE IF EXISTS playlists;

ALTER TABLE users DROP COLUMN name;
ALTER TABLE users ADD COLUMN first_name VARCHAR(255);
ALTER TABLE users ADD COLUMN last_name VARCHAR(255);
ALTER TABLE users ADD COLUMN country VARCHAR(255);
ALTER TABLE users ADD COLUMN city VARCHAR(255);

ALTER TABLE users ADD CONSTRAINT chk_users_email_or_phone
    CHECK (email IS NOT NULL OR phone IS NOT NULL);
