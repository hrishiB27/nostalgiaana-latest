UPDATE users SET phone = '+919987092587' WHERE email = 'balaji@nostalgiaana.com' AND phone IS NULL;
ALTER TABLE users DROP CONSTRAINT chk_users_email_or_phone;
ALTER TABLE users DROP COLUMN email;
