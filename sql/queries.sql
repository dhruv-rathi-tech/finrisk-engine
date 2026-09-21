-- =====================================================================
-- FinRisk: Analytical & Audit Queries
-- Used for validation, data inspection, and Power BI report verification
-- =====================================================================

-- 1. All Flagged Anomalies with Narrative Explanations
SELECT 
    f.fiscal_year,
    f.industry,
    f.ticker,
    f.metric,
    ROUND(f.yoy_pct_change, 1) AS yoy_pct,
    ROUND(f.z_score, 2) AS z_score,
    ROUND(f.percentile_rank, 0) AS pctl,
    f.severity,
    f.distortion_caveat,
    n.narrative
FROM flags f
LEFT JOIN narratives n 
    ON f.ticker = n.ticker 
    AND f.fiscal_year = n.fiscal_year 
    AND f.metric = n.metric
ORDER BY f.fiscal_year DESC, ABS(f.z_score) DESC;

-- 2. High Severity Statistical Anomalies (|z| >= 2.5)
SELECT 
    ticker,
    industry,
    fiscal_year,
    metric,
    ROUND(yoy_pct_change, 1) AS yoy_pct,
    ROUND(z_score, 2) AS z_score
FROM flags
WHERE severity = 'high';

-- 3. Low-Base Distortion Caveats (|YoY %| >= 200%)
SELECT 
    ticker,
    fiscal_year,
    metric,
    ROUND(yoy_pct_change, 1) AS yoy_pct,
    ROUND(z_score, 2) AS z_score
FROM flags
WHERE distortion_caveat = 1;

-- 4. Industry Peer Group Summary Stats by Year & Metric
SELECT 
    industry,
    fiscal_year,
    metric,
    COUNT(*) AS company_count,
    ROUND(AVG(yoy_pct_change), 2) AS avg_yoy_pct,
    ROUND(MIN(yoy_pct_change), 2) AS min_yoy_pct,
    ROUND(MAX(yoy_pct_change), 2) AS max_yoy_pct
FROM metrics_analysis
GROUP BY industry, fiscal_year, metric
ORDER BY industry, metric, fiscal_year;

-- 5. Audit Traceability: Method & XBRL Tag Selection per Company
SELECT 
    ticker,
    metric,
    tag_or_method
FROM tags_used
ORDER BY metric, ticker;
