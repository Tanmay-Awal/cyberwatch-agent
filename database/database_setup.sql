-- ============================================================
-- CyberWatch — PostgreSQL Database Setup
-- Run this BEFORE importing the n8n workflow
-- ============================================================

-- Create the main CVE intelligence table
CREATE TABLE IF NOT EXISTS cve_intelligence (
    id                    SERIAL PRIMARY KEY,
    cve_id                VARCHAR(50) UNIQUE NOT NULL,
    source                VARCHAR(50) NOT NULL DEFAULT 'NVD',
    title                 TEXT,
    description           TEXT,
    plain_english_summary TEXT,
    cvss_score            DECIMAL(4,2) DEFAULT 0,
    cvss_vector           VARCHAR(200),
    severity              VARCHAR(20) DEFAULT 'UNKNOWN',
    urgency               VARCHAR(20) DEFAULT 'MEDIUM',
    category              VARCHAR(100) DEFAULT 'UNCATEGORIZED',
    attack_type           VARCHAR(100),
    epss_score            DECIMAL(6,5) DEFAULT 0,
    epss_percentile       DECIMAL(6,5) DEFAULT 0,
    priority_score        DECIMAL(5,2) DEFAULT 0,
    is_cisa_kev           BOOLEAN DEFAULT FALSE,
    has_exploit           BOOLEAN DEFAULT FALSE,
    affected_products     JSONB DEFAULT '[]',
    references            JSONB DEFAULT '[]',
    threat_actors         JSONB DEFAULT '[]',
    mitre_techniques      JSONB DEFAULT '[]',
    attack_chain          JSONB DEFAULT '{}',
    exploitation_timeline VARCHAR(50),
    recommended_action    TEXT,
    technical_impact      TEXT,
    correlation_confidence DECIMAL(4,3) DEFAULT 0,
    analyst_notes         TEXT,
    published_at          TIMESTAMPTZ,
    enriched_at           TIMESTAMPTZ,
    correlated_at         TIMESTAMPTZ,
    created_at            TIMESTAMPTZ DEFAULT NOW(),
    updated_at            TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes for fast queries
CREATE INDEX IF NOT EXISTS idx_cve_priority    ON cve_intelligence (priority_score DESC);
CREATE INDEX IF NOT EXISTS idx_cve_severity    ON cve_intelligence (severity);
CREATE INDEX IF NOT EXISTS idx_cve_urgency     ON cve_intelligence (urgency);
CREATE INDEX IF NOT EXISTS idx_cve_created     ON cve_intelligence (created_at DESC);
CREATE INDEX IF NOT EXISTS idx_cve_kev         ON cve_intelligence (is_cisa_kev) WHERE is_cisa_kev = TRUE;
CREATE INDEX IF NOT EXISTS idx_cve_exploit     ON cve_intelligence (has_exploit) WHERE has_exploit = TRUE;

-- Alert log table
CREATE TABLE IF NOT EXISTS alert_log (
    id          SERIAL PRIMARY KEY,
    cve_id      VARCHAR(50) REFERENCES cve_intelligence(cve_id),
    alert_type  VARCHAR(50),
    channel     VARCHAR(50) DEFAULT 'telegram',
    message     TEXT,
    sent_at     TIMESTAMPTZ DEFAULT NOW()
);

-- Useful views
CREATE OR REPLACE VIEW critical_cves_today AS
SELECT cve_id, title, priority_score, cvss_score, epss_score,
       urgency, attack_type, category, is_cisa_kev, has_exploit,
       plain_english_summary, recommended_action, created_at
FROM cve_intelligence
WHERE created_at >= NOW() - INTERVAL '24 hours'
  AND urgency IN ('CRITICAL', 'HIGH')
ORDER BY priority_score DESC;

CREATE OR REPLACE VIEW daily_stats AS
SELECT
    COUNT(*) as total,
    COUNT(*) FILTER (WHERE urgency = 'CRITICAL') as critical_count,
    COUNT(*) FILTER (WHERE urgency = 'HIGH') as high_count,
    COUNT(*) FILTER (WHERE urgency = 'MEDIUM') as medium_count,
    COUNT(*) FILTER (WHERE is_cisa_kev = TRUE) as cisa_kev_count,
    COUNT(*) FILTER (WHERE has_exploit = TRUE) as has_exploit_count,
    ROUND(AVG(priority_score)::numeric, 2) as avg_priority_score,
    MAX(priority_score) as max_priority_score
FROM cve_intelligence
WHERE created_at >= NOW() - INTERVAL '24 hours';

-- Confirm setup
SELECT 'CyberWatch database setup complete!' as status;
SELECT COUNT(*) as table_count FROM information_schema.tables
WHERE table_name IN ('cve_intelligence', 'alert_log');
