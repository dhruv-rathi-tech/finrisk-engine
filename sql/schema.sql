-- =====================================================================
-- FinRisk: Database Schema (SQLite)
-- Holds normalized financials, derived peer analytics, flags, and LLM commentary.
-- =====================================================================

-- 1. Normalized Financial Statements (FY2020 - FY2024)
CREATE TABLE IF NOT EXISTS financials (
    ticker              TEXT NOT NULL,
    industry            TEXT NOT NULL,
    fiscal_year         INTEGER NOT NULL,
    revenue             REAL,
    net_income          REAL,
    operating_expenses  REAL,
    gross_profit        REAL,
    total_assets        REAL,
    PRIMARY KEY (ticker, fiscal_year)
);

-- 2. Line-Item XBRL Tag Tracking (Audit Traceability)
CREATE TABLE IF NOT EXISTS tags_used (
    ticker              TEXT NOT NULL,
    metric              TEXT NOT NULL,
    tag_or_method       TEXT NOT NULL,
    PRIMARY KEY (ticker, metric)
);

-- 3. Industry Peer Group Membership
CREATE TABLE IF NOT EXISTS company_peer_group (
    ticker              TEXT PRIMARY KEY,
    company_name        TEXT,
    peer_group          TEXT NOT NULL,
    sic_code            TEXT
);

-- 4. Statistical Peer Analysis (YoY % deltas, peer z-scores, percentiles)
CREATE TABLE IF NOT EXISTS metrics_analysis (
    ticker              TEXT NOT NULL,
    industry            TEXT NOT NULL,
    fiscal_year         INTEGER NOT NULL,
    metric              TEXT NOT NULL,
    val_prior           REAL,
    val_curr            REAL,
    yoy_pct_change      REAL,
    peer_mean_yoy       REAL,
    peer_std_yoy        REAL,
    peer_n              INTEGER,
    z_score             REAL,
    percentile_rank     REAL,
    PRIMARY KEY (ticker, fiscal_year, metric)
);

-- 5. Anomaly & Caveat Flags (Threshold rules)
CREATE TABLE IF NOT EXISTS flags (
    ticker              TEXT NOT NULL,
    industry            TEXT NOT NULL,
    fiscal_year         INTEGER NOT NULL,
    metric              TEXT NOT NULL,
    yoy_pct_change      REAL,
    z_score             REAL,
    percentile_rank     REAL,
    peer_n              INTEGER,
    severity            TEXT,
    distortion_caveat   INTEGER DEFAULT 0,
    PRIMARY KEY (ticker, fiscal_year, metric)
);

-- 6. AI Narratives (Auditor-style LLM commentary via local Llama 3.2)
CREATE TABLE IF NOT EXISTS narratives (
    ticker              TEXT NOT NULL,
    industry            TEXT NOT NULL,
    fiscal_year         INTEGER NOT NULL,
    metric              TEXT NOT NULL,
    narrative           TEXT,
    model               TEXT,
    generated_at        TEXT,
    PRIMARY KEY (ticker, fiscal_year, metric)
);
