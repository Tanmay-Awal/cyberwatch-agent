# 🏗️ CyberWatch — Architecture Deep Dive

## Overview

CyberWatch follows a **multi-agent pipeline architecture** where each agent has a single responsibility, clear inputs/outputs, and fails gracefully without breaking the entire pipeline.

---

## Architecture Principles

### 1. Single Responsibility per Agent
Each agent does ONE thing well:
- Collector → Only collects and normalizes
- Enricher → Only adds AI classification and scores
- Correlator → Only finds threat relationships
- Prioritizer → Only ranks and summarizes
- Dispatcher → Only sends alerts

### 2. Pipeline Design
Data flows in one direction: Collect → Enrich → Correlate → Prioritize → Dispatch

### 3. Idempotency
Every CVE has a unique ID. The database uses `ON CONFLICT DO UPDATE` — running the pipeline twice never creates duplicates.

### 4. Graceful Degradation
If Groq fails → CVE gets a default classification and continues  
If Gemini fails → CVE gets saved without correlation data  
If Telegram fails → CVE is still saved to database  

---

## Data Flow Diagram

```
RAW INPUT                    PROCESSING                     OUTPUT
─────────                    ──────────                     ──────

NVD API          ┐
OTX API          ├──→ NORMALIZE ──→ DEDUPLICATE
CISA KEV         │    (unified                │
OSV.dev API      ┘     schema)                │
                                              ▼
                              ┌───────── CVE OBJECT ─────────────┐
                              │  cve_id, description, cvss,      │
                              │  severity, affected_products      │
                              └──────────────┬───────────────────┘
                                             │
                                    EPSS API FETCH
                                             │
                              ┌───────── CVE OBJECT ─────────────┐
                              │  + epss_score, epss_percentile   │
                              └──────────────┬───────────────────┘
                                             │
                                    GROQ CLASSIFY
                                    (Llama 3.1 70B)
                                             │
                              ┌───────── CVE OBJECT ─────────────┐
                              │  + category, attack_type,        │
                              │  + urgency, priority_score       │
                              │  + plain_english_summary         │
                              └──────────────┬───────────────────┘
                                             │
                                   GEMINI CORRELATE
                                   (2.5 Flash-Lite)
                                             │
                              ┌───────── CVE OBJECT ─────────────┐
                              │  + threat_actors, mitre_techs    │
                              │  + attack_chain, timeline        │
                              │  + analyst_notes                 │
                              └──────────────┬───────────────────┘
                                             │
                                    POSTGRESQL SAVE
                                             │
                                    ┌────────┴────────┐
                                    ▼                 ▼
                             Score >= 8.5?       Score < 8.5
                                    │                 │
                             TELEGRAM ALERT      LOG & WAIT
                             (Immediate)         (for digest)
```

---

## Priority Scoring Formula

```
Priority Score = (CVSS_Normalized × 0.30)
               + (EPSS_Score × 0.25)
               + (CISA_KEV_Flag × 0.20)
               + (Has_Public_Exploit × 0.15)
               + (Network_Exploitable × 0.10)

Where:
  CVSS_Normalized  = cvss_score / 10        (range: 0.0 - 1.0)
  EPSS_Score       = probability 0-1        (range: 0.0 - 1.0)
  CISA_KEV_Flag    = 1 if in CISA list, 0 if not
  Has_Public_Exploit = 1 if exploit exists, 0 if not
  Network_Exploitable = 1 if exploitable remotely, 0 if not

Final score multiplied by 10 to get range 0-10.
Capped at 10.

Example:
  CVSS 9.8 → 0.98 × 0.30 = 0.294
  EPSS 0.94 → 0.94 × 0.25 = 0.235
  CISA KEV yes → 1 × 0.20 = 0.200
  Exploit yes → 1 × 0.15 = 0.150
  Network yes → 1 × 0.10 = 0.100
  Total = 0.979 × 10 = 9.79 → CRITICAL ALERT
```

---

## Agent Communication

Agents communicate via **n8n workflow data passing** — each node receives the output of the previous node as `$input.item.json`. This means:

1. No message queue needed (n8n handles it)
2. No separate API between agents
3. Full data context available at every step
4. n8n execution logs show exact data at each step

---

## Error Handling Strategy

```
API Failure (NVD down, OTX timeout):
  → n8n retries 3 times with 60s delay
  → After 3 fails: logs error, skips to next CVE
  → Does NOT stop entire pipeline

AI API Failure (Groq/Gemini):
  → Catches JSON parse error
  → Falls back to default classification values
  → CVE still saved with reduced metadata
  → Marked with low confidence score

Database Failure:
  → n8n logs the failed insert
  → CVE data preserved in execution log
  → Can be manually re-run

Telegram Failure:
  → Alert logged to database alert_log table
  → Next alert still attempted (not blocked)
```

---

## Scheduling Architecture

```
CRON SCHEDULES:

Every Hour (0 * * * *):
  → Collector pipeline runs
  → Fetches last 2 hours of CVEs
  → Processes each through full pipeline

Daily 8 AM IST (0 2:30 * * * in UTC):
  → Digest pipeline runs
  → Fetches last 24 hours from PostgreSQL
  → Generates and sends morning briefing
```

---

## Security Considerations

- API keys stored in n8n encrypted credential store (never in workflow JSON)
- PostgreSQL only accessible within Docker network
- n8n protected by basic auth
- No user PII stored anywhere
- CVE data is all public information
- Webhook URL not exposed (no incoming webhooks needed)
