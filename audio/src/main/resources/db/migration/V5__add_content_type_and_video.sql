ALTER TABLE content ADD COLUMN content_type VARCHAR(20);
ALTER TABLE content ADD COLUMN raw_video_path VARCHAR(500);

UPDATE content SET content_type = 'AUDIO' WHERE content_type IS NULL;

ALTER TABLE content ALTER COLUMN content_type SET NOT NULL;
ALTER TABLE content ALTER COLUMN content_type SET DEFAULT 'AUDIO';

ALTER TABLE content ADD CONSTRAINT chk_content_type
    CHECK (content_type IN ('SHOW', 'AUDIO'));
