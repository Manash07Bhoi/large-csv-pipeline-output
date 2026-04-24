-- ============================================================
-- build_videos_db.sql
-- Generated: 2026-04-24 02:01:04 UTC
-- Source: large-csv-pipeline  (developer: Roshan)
-- ============================================================
-- Run with: sqlite3 videos.db < build_videos_db.sql
-- ============================================================

PRAGMA journal_mode = WAL;
PRAGMA synchronous   = NORMAL;
PRAGMA temp_store     = MEMORY;

-- ── Main table (all 13 source columns + derived fields) ────────────────────
CREATE TABLE IF NOT EXISTS videos (
    id            INTEGER PRIMARY KEY AUTOINCREMENT,
    video_key     TEXT UNIQUE,           -- embed key from iframe src
    iframe        TEXT,                  -- full <iframe> HTML embed code
    thumbnail     TEXT,                  -- primary thumbnail URL
    thumbnails    TEXT,                  -- semicolon-list of preview thumbnails
    title         TEXT NOT NULL,         -- video title
    tags          TEXT,                  -- semicolon-separated keyword tags
    categories    TEXT,                  -- semicolon-separated full category list
    category      TEXT,                  -- primary category (first from list)
    model         TEXT,                  -- performer / model name
    duration      INTEGER,               -- duration in seconds
    views         INTEGER,               -- total view count
    source_id     TEXT,                  -- original numeric ID from source CSV
    rating_count  TEXT,                  -- rating / vote count
    thumbnail_hd  TEXT,                  -- primary HD thumbnail URL
    thumbnails_hd TEXT                   -- semicolon-list of HD thumbnails
);

-- ── Indexes ────────────────────────────────────────────────────────────────
CREATE INDEX IF NOT EXISTS idx_id        ON videos(id);
CREATE INDEX IF NOT EXISTS idx_title     ON videos(title COLLATE NOCASE);
CREATE INDEX IF NOT EXISTS idx_category  ON videos(category);
CREATE INDEX IF NOT EXISTS idx_model     ON videos(model);
CREATE INDEX IF NOT EXISTS idx_duration  ON videos(duration);
CREATE INDEX IF NOT EXISTS idx_views     ON videos(views);
CREATE INDEX IF NOT EXISTS idx_video_key ON videos(video_key);

-- ── Full-Text Search (FTS5) ────────────────────────────────────────────────
CREATE VIRTUAL TABLE IF NOT EXISTS videos_fts
    USING fts5(title, tags, content=videos, content_rowid=id);

-- Populate FTS from main table (run after INSERT statements)
-- INSERT INTO videos_fts(rowid, title, tags)
-- SELECT id, title, COALESCE(tags,'') FROM videos;

-- ── Example queries ────────────────────────────────────────────────────────

-- 1. Full-text search
-- SELECT id, title, thumbnail FROM videos
--     JOIN videos_fts ON videos.id = videos_fts.rowid
--     WHERE videos_fts MATCH 'brunette outdoor'
--     ORDER BY rank LIMIT 20;

-- 2. Filter by category
-- SELECT id, title, thumbnail, duration, views
--     FROM videos WHERE category = 'Amateur'
--     ORDER BY views DESC LIMIT 50;

-- 3. Filter by duration (1–5 minutes)
-- SELECT id, title, duration, category FROM videos
--     WHERE duration BETWEEN 60 AND 300 LIMIT 50;

-- 4. Filter by tag (LIKE — slower; FTS preferred)
-- SELECT id, title, tags FROM videos
--     WHERE '|' || tags || '|' LIKE '%|teen|%' LIMIT 20;

-- 5. Top by views in a category
-- SELECT id, title, views, thumbnail FROM videos
--     WHERE category = 'MILF' ORDER BY views DESC LIMIT 20;

-- ── Post-insert optimisation ───────────────────────────────────────────────
VACUUM;
PRAGMA optimize;
