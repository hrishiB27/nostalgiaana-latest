ALTER TABLE users ADD COLUMN approved BOOLEAN;

UPDATE users SET approved = true WHERE approved IS NULL;

ALTER TABLE users ALTER COLUMN approved SET NOT NULL;
ALTER TABLE users ALTER COLUMN approved SET DEFAULT false;
