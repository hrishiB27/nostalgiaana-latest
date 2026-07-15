-- Content referencing an old category is uncategorized until an admin
-- re-assigns it — there's no reliable automatic mapping from the old
-- general-purpose categories to the new show-type categories.
UPDATE content SET category_id = NULL;

DELETE FROM categories;

INSERT INTO categories (id, name, description, created_by, created_at) VALUES
(gen_random_uuid(), 'Weeknight Shows', 'Regular weeknight programming', NULL, NOW()),
(gen_random_uuid(), 'Weekend Charcha Shows', 'Weekend conversational charcha sessions', NULL, NOW()),
(gen_random_uuid(), 'Khoj Series', 'The Khoj series of discovery episodes', NULL, NOW()),
(gen_random_uuid(), 'Special Guest Presentations', 'Presentations featuring special invited guests', NULL, NOW()),
(gen_random_uuid(), 'Member Presentations', 'Presentations by community members', NULL, NOW());
