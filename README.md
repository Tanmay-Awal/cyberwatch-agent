<div align="center">

# 🛡️ CyberWatch
### AI-Powered Threat Intelligence Aggregator

**Autonomous. Free. Production-Grade.**

[![n8n](https://img.shields.io/badge/Built%20with-n8n-FF6D5A?style=for-the-badge&logo=n8n)](https://n8n.io)
[![Gemini](https://img.shields.io/badge/AI-Gemini%202.5%20Flash-4285F4?style=for-the-badge&logo=google)](https://aistudio.google.com)
[![Groq](https://img.shields.io/badge/AI-Groq%20Llama%203.1-F55036?style=for-the-badge)](https://groq.com)
[![PostgreSQL](https://img.shields.io/badge/Database-PostgreSQL-336791?style=for-the-badge&logo=postgresql)](https://postgresql.org)
[![Docker](https://img.shields.io/badge/Deploy-Docker-2496ED?style=for-the-badge&logo=docker)](https://docker.com)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow?style=for-the-badge)](LICENSE)
[![Cost](https://img.shields.io/badge/Cost-₹0%20%2F%20month-brightgreen?style=for-the-badge)]()

---

> **CyberWatch is a fully autonomous threat intelligence platform that monitors 4 security data sources 24/7, uses AI to correlate and prioritize vulnerabilities, and delivers real-time alerts to your Telegram — completely free.**

[🚀 Quick Start](#-quick-start) • [🏗️ Architecture](#️-architecture) • [📋 Features](#-features) • [🔧 Setup](#-setup-guide) • [📊 Demo](#-demo)

</div>

---

## 📌 Table of Contents

- [What Is CyberWatch?](#-what-is-cyberwatch)
- [The Problem We Solve](#-the-problem-we-solve)
- [Features](#-features)
- [Architecture](#-architecture)
- [The 5 Agents Explained](#-the-5-agents)
- [Tech Stack](#-tech-stack)
- [Quick Start](#-quick-start)
- [Setup Guide](#-setup-guide)
- [Workflow Overview](#-workflow-overview)
- [Database Schema](#-database-schema)
- [API Keys Required](#-api-keys-required)
- [Configuration](#-configuration)
- [Demo](#-demo)
- [Project Structure](#-project-structure)
- [Roadmap](#-roadmap)
- [Contributing](#-contributing)
- [License](#-license)

---

## 🔍 What Is CyberWatch?

CyberWatch is a **multi-agent, AI-powered cybersecurity threat intelligence platform** built entirely on n8n. It autonomously:

- 📡 **Collects** vulnerability data from NVD, AlienVault OTX, CISA KEV, and OSV.dev every hour
- 🧠 **Classifies** each CVE using Groq (Llama 3.1 70B) in under 1 second
- 🔗 **Correlates** threats using Gemini 2.5 Flash-Lite — finding attack chains, threat actors, and MITRE ATT&CK mappings
- 📊 **Prioritizes** using a multi-factor scoring formula (CVSS + EPSS + CISA KEV + exploit availability)
- 📢 **Dispatches** instant Telegram alerts for critical threats + beautiful daily morning digests

**Total monthly cost: ₹0**

---

## 🚨 The Problem We Solve

Every day, **100+ new security vulnerabilities** are officially published. The information is free and public — but completely unusable without processing.

| The Reality | The Numbers |
|-------------|-------------|
| New CVEs published daily | 100+ |
| Time to manually read one CVE report | 15-30 minutes |
| Hours needed to process all daily CVEs | 25-50 hours |
| Cost of paid threat intelligence platforms | $5,000 - $25,000/month |
| SMBs with zero threat intelligence | 85% (280 million businesses) |
| Average cost of a data breach | $4.45 million |

**CyberWatch solves this by delivering enterprise-grade threat intelligence at zero cost.**

---

## ✨ Features

### Core Features (MVP)
- ✅ **Multi-source CVE ingestion** — NVD, AlienVault OTX, CISA KEV, OSV.dev
- ✅ **AI-powered classification** — Category, attack type, complexity, targets
- ✅ **EPSS scoring** — Real exploitation probability from FIRST.org
- ✅ **Composite priority scoring** — Multi-factor formula (not just CVSS)
- ✅ **Threat correlation** — AI finds related CVEs and attack chains
- ✅ **MITRE ATT&CK mapping** — Links CVEs to known attack techniques
- ✅ **Threat actor profiling** — Identifies likely APT groups per CVE
- ✅ **Instant Telegram alerts** — For critical threats (score ≥ 8.5)
- ✅ **Daily morning digest** — Beautiful 8 AM briefing with AI executive summary
- ✅ **PostgreSQL persistence** — Full CVE history with rich metadata
- ✅ **Deduplication** — Never alerts twice for the same CVE

### Advanced Features
- 🔄 **Attack chain detection** — Identifies multi-CVE attack paths
- 🎯 **Industry targeting analysis** — Which sectors are most at risk
- 📈 **Exploitation timeline prediction** — When will this be exploited?
- 🔍 **Analyst notes** — AI-written context for security teams
- 📊 **Daily statistics** — CVE volume, severity distribution, trends

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         DATA SOURCES (Free APIs)                        │
│                                                                         │
│  ┌─────────┐  ┌─────────────┐  ┌──────────┐  ┌──────────────────────┐ │
│  │   NVD   │  │  OTX (Free) │  │ CISA KEV │  │      OSV.dev         │ │
│  │  (Gov)  │  │  AlienVault │  │  (Gov)   │  │  (Google OSS)        │ │
│  └────┬────┘  └──────┬──────┘  └────┬─────┘  └──────────┬───────────┘ │
└───────┼──────────────┼──────────────┼────────────────────┼─────────────┘
        │              │              │                    │
        └──────────────┴──────────────┴────────────────────┘
                                      │
                                      ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                      n8n ORCHESTRATION LAYER                            │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │  AGENT 1 — COLLECTOR                                            │   │
│  │  Scheduled every hour · Fetches · Normalizes · Deduplicates     │   │
│  └──────────────────────────────┬──────────────────────────────────┘   │
│                                 │                                       │
│  ┌──────────────────────────────▼──────────────────────────────────┐   │
│  │  AGENT 2 — ENRICHER                                             │   │
│  │  EPSS Score · Groq Classification · Priority Scoring            │   │
│  │  Model: Llama 3.1 70B (Groq) · Latency: <1 second              │   │
│  └──────────────────────────────┬──────────────────────────────────┘   │
│                                 │                                       │
│  ┌──────────────────────────────▼──────────────────────────────────┐   │
│  │  AGENT 3 — CORRELATOR                                           │   │
│  │  Gemini Correlation · MITRE ATT&CK · Threat Actor Mapping       │   │
│  │  Model: Gemini 2.5 Flash-Lite · Attack Chain Detection          │   │
│  └──────────────────────────────┬──────────────────────────────────┘   │
│                                 │                                       │
│  ┌──────────────────────────────▼──────────────────────────────────┐   │
│  │  AGENT 4 — PRIORITIZER (Runs 2x daily)                         │   │
│  │  Groups by severity · Ranks by score · Gemini executive summary │   │
│  └──────────────────────────────┬──────────────────────────────────┘   │
│                                 │                                       │
│  ┌──────────────────────────────▼──────────────────────────────────┐   │
│  │  AGENT 5 — DISPATCHER                                           │   │
│  │  Instant alerts (score ≥ 8.5) · Daily digest (8 AM IST)        │   │
│  │  Telegram · Deduplication · Rich formatting                     │   │
│  └──────────────────────────────┬──────────────────────────────────┘   │
└─────────────────────────────────┼───────────────────────────────────────┘
                                  │
              ┌───────────────────┼───────────────────┐
              ▼                   ▼                   ▼
     ┌─────────────────┐  ┌─────────────┐  ┌──────────────────┐
     │   PostgreSQL    │  │  Telegram   │  │   Grafana (opt)  │
     │  Full CVE store │  │   Alerts    │  │    Dashboard     │
     │  Rich metadata  │  │  & Digests  │  │    & Metrics     │
     └─────────────────┘  └─────────────┘  └──────────────────┘
```

---

## 🤖 The 5 Agents

### Agent 1 — Collector 📡
Runs every hour. Visits all 4 data sources simultaneously, fetches new CVEs, normalizes them into a unified schema, and deduplicates by CVE ID.

**Triggers:** Hourly schedule + Manual trigger  
**Output:** Normalized CVE records ready for enrichment

### Agent 2 — Enricher 🔬
Takes each raw CVE and enriches it with:
- **EPSS Score** from FIRST.org (exploitation probability)
- **AI Classification** via Groq Llama 3.1 70B (category, attack type, targets)
- **Composite Priority Score** using multi-factor formula

**Priority Formula:**
```
Priority = (CVSS × 0.30) + (EPSS × 0.25) + (CISA_KEV × 0.20) 
         + (Public_Exploit × 0.15) + (Network_Exploitable × 0.10)
```

**Output:** Enriched CVE with AI classification + priority score

### Agent 3 — Correlator 🔗
Sends enriched CVE to Gemini 2.5 Flash-Lite with full context. AI identifies:
- Related CVE patterns and attack chains
- Likely threat actors (APT groups)
- MITRE ATT&CK technique mappings
- Targeted industries
- Exploitation timeline prediction

**Output:** Fully correlated CVE with threat intelligence context

### Agent 4 — Prioritizer 📊
Runs at 6 AM and 6 PM. Fetches all CVEs from last 24 hours, groups by severity, ranks by priority score, and generates an AI executive summary via Gemini.

**Output:** Ranked priority list + executive briefing

### Agent 5 — Dispatcher 📢
Two modes:
- **Instant Alert** — Fires immediately when priority score ≥ 8.5
- **Daily Digest** — Sends beautiful 8 AM morning briefing to Telegram

**Output:** Telegram messages with rich formatting, severity emojis, and actionable recommendations

---

## 🛠️ Tech Stack

| Component | Technology | Why |
|-----------|-----------|-----|
| Orchestration | n8n (self-hosted) | Visual workflows, 400+ integrations, free |
| Fast AI | Groq + Llama 3.1 70B | <1 second response, 14,400 req/day free |
| Deep AI | Gemini 2.5 Flash-Lite | Best free model, 1M context, structured output |
| Database | PostgreSQL 15 | Reliable, JSONB support, powerful queries |
| Alerting | Telegram Bot API | Free, instant, works on all phones |
| Containerization | Docker + Docker Compose | One command setup, portable |
| CVE Data | NVD (NIST) | Official US Government database, free |
| Threat Intel | AlienVault OTX | Community threat intelligence, free tier |
| Exploit Data | CISA KEV | Actively exploited CVEs, US Government, free |
| OSS Vulns | OSV.dev (Google) | Open source vulnerabilities, completely free |
| EPSS | FIRST.org API | Exploitation probability scores, free |

---

## 🚀 Quick Start

```bash
# 1. Clone the repo
git clone https://github.com/YOUR_USERNAME/cyberwatch.git
cd cyberwatch

# 2. Start all containers
docker-compose up -d

# 3. Open n8n
# Go to http://localhost:5678

# 4. Setup database
docker exec -it cyberwatch-postgres psql -U cyberwatch -d cyberwatch -f /docker-entrypoint-initdb.d/setup.sql

# 5. Import workflow
# In n8n: Workflows → Import from File → workflows/cyberwatch_all_agents.json

# 6. Add your API keys (see Setup Guide below)

# 7. Click "Start" node → "Test Workflow" → Done! ✅
```

---

## 🔧 Setup Guide

### Prerequisites
- Docker Desktop installed
- Free accounts on: Groq, Google AI Studio, AlienVault OTX, Telegram

### Step 1 — Get Free API Keys

#### Groq API Key (AI Classification)
1. Go to [console.groq.com](https://console.groq.com)
2. Sign up free (no credit card)
3. API Keys → Create API Key → Copy

#### Gemini API Key (AI Correlation)
1. Go to [aistudio.google.com/app/apikey](https://aistudio.google.com/app/apikey)
2. Sign in with Google → Create API Key → Copy

#### AlienVault OTX Key (Threat Intelligence)
1. Go to [otx.alienvault.com](https://otx.alienvault.com)
2. Sign up free → Profile → Settings → Copy OTX Key

#### Telegram Bot Token + Chat ID (Alerts)
1. Open Telegram → Search **@BotFather**
2. Send `/newbot` → Follow steps → Copy **Token**
3. Search **@userinfobot** → Send any message → Copy your **Chat ID**

### Step 2 — Start Docker

```bash
cd cyberwatch
docker-compose up -d

# Verify both containers running
docker ps
```

You should see:
```
cyberwatch-n8n        Up    0.0.0.0:5678->5678/tcp
cyberwatch-postgres   Up    0.0.0.0:5432->5432/tcp
```

### Step 3 — Setup Database

```bash
docker exec -it cyberwatch-postgres psql -U cyberwatch -d cyberwatch
```

Paste the contents of `database/setup.sql` and run. Then type `\q` to exit.

### Step 4 — Configure n8n

1. Open [http://localhost:5678](http://localhost:5678)
2. Create owner account (first time only)
3. Go to **Workflows → Import from File**
4. Select `workflows/cyberwatch_all_agents.json`

### Step 5 — Add Credentials in n8n

**PostgreSQL Credential:**
```
Name:     CyberWatch PostgreSQL
Host:     postgres
Port:     5432
Database: cyberwatch
User:     cyberwatch
Password: cyberwatch123
SSL:      Disabled
```

**Telegram Credential:**
```
Name:        CyberWatch Telegram Bot
Access Token: [Your Bot Token from BotFather]
```

### Step 6 — Replace API Keys in Workflow

Open each node and replace:

| Node | Field | Replace |
|------|-------|---------|
| Fetch OTX Pulses | Header X-OTX-API-KEY | Your OTX key |
| Groq Classify CVE | Header Authorization | `Bearer YOUR_GROQ_KEY` |
| Gemini Correlate CVE | Header x-goog-api-key | Your Gemini key |
| Generate Digest Summary | Header x-goog-api-key | Your Gemini key |
| Send Critical Telegram Alert | Chat ID | Your Chat ID |
| Send Daily Digest Telegram | Chat ID | Your Chat ID |

### Step 7 — Test Run

For your first test, open **"Build NVD URL"** node and change:
```javascript
// Change this (2 hours):
2 * 60 * 60 * 1000

// To this (72 hours = lots of test data):
72 * 60 * 60 * 1000
```

Then click **Start → Test Workflow** and watch it run! 🎉

---

## 📊 Workflow Overview

```
PIPELINE FLOW (Every Hour):

Every Hour Trigger
       │
       ├──→ Fetch NVD CVEs ──→ Normalize NVD Data ──┐
       ├──→ Fetch OTX Pulses ──→ Normalize OTX ─────┤
       ├──→ Fetch CISA KEV ──→ Normalize CISA ───────┤
       └──→ Fetch OSV Vulns ────────────────────────→┘
                                                      │
                                             Merge & Deduplicate
                                                      │
                                              Build EPSS URL
                                                      │
                                             Fetch EPSS Score
                                                      │
                                              Add EPSS to CVE
                                                      │
                                            Build Groq Prompt
                                                      │
                                            Groq Classify CVE
                                                      │
                                            Parse & Score CVE
                                                      │
                                           Build Gemini Prompt
                                                      │
                                           Gemini Correlate CVE
                                                      │
                                            Parse Correlation
                                                      │
                                            Prepare DB Insert
                                                      │
                                           Save to PostgreSQL
                                                      │
                                      ┌───────────────┴───────────────┐
                                      ▼                               ▼
                              Score >= 8.5?                      Score < 8.5
                                      │                               │
                             Format Critical Alert           Log Saved (Non-Critical)
                                      │
                          Send Critical Telegram Alert ✅

DAILY DIGEST PIPELINE (8 AM IST):

Daily 8AM Trigger
       │
Prepare Digest Query
       │
Fetch Today's CVEs (PostgreSQL)
       │
Group & Rank CVEs
       │
Generate Digest Summary (Gemini)
       │
Format Daily Digest
       │
Send Daily Digest Telegram ✅
```

---

## 🗄️ Database Schema

```sql
TABLE: cve_intelligence
┌──────────────────────┬──────────────────┬─────────────────────────────┐
│ Column               │ Type             │ Description                 │
├──────────────────────┼──────────────────┼─────────────────────────────┤
│ id                   │ SERIAL PK        │ Auto increment ID           │
│ cve_id               │ VARCHAR(50)      │ CVE-2024-XXXXX (unique)     │
│ source               │ VARCHAR(50)      │ NVD / OTX / CISA / OSV     │
│ title                │ TEXT             │ Human readable title        │
│ description          │ TEXT             │ Full technical description  │
│ plain_english_summary│ TEXT             │ AI-generated plain summary  │
│ cvss_score           │ DECIMAL(4,2)     │ Official CVSS score (0-10)  │
│ cvss_vector          │ VARCHAR(200)     │ CVSS vector string          │
│ severity             │ VARCHAR(20)      │ CRITICAL/HIGH/MEDIUM/LOW    │
│ urgency              │ VARCHAR(20)      │ AI-determined urgency       │
│ category             │ VARCHAR(100)     │ Web App / Network / OS etc  │
│ attack_type          │ VARCHAR(100)     │ RCE / SQLi / XSS etc       │
│ epss_score           │ DECIMAL(6,5)     │ Exploitation probability    │
│ epss_percentile      │ DECIMAL(6,5)     │ EPSS percentile rank        │
│ priority_score       │ DECIMAL(5,2)     │ Our composite score (0-10)  │
│ is_cisa_kev          │ BOOLEAN          │ Actively exploited flag     │
│ has_exploit          │ BOOLEAN          │ Public exploit exists       │
│ affected_products    │ JSONB            │ List of affected software   │
│ references           │ JSONB            │ Advisory URLs               │
│ threat_actors        │ JSONB            │ APT groups linked           │
│ mitre_techniques     │ JSONB            │ ATT&CK technique IDs        │
│ attack_chain         │ JSONB            │ Attack chain analysis       │
│ exploitation_timeline│ VARCHAR(50)      │ When likely to be exploited │
│ recommended_action   │ TEXT             │ AI fix recommendation       │
│ technical_impact     │ TEXT             │ What attacker can do        │
│ correlation_confidence│ DECIMAL(4,3)   │ AI confidence score         │
│ analyst_notes        │ TEXT             │ AI analyst context          │
│ published_at         │ TIMESTAMPTZ      │ CVE publish date            │
│ enriched_at          │ TIMESTAMPTZ      │ When AI processed it        │
│ correlated_at        │ TIMESTAMPTZ      │ When correlated             │
│ created_at           │ TIMESTAMPTZ      │ When we collected it        │
└──────────────────────┴──────────────────┴─────────────────────────────┘

INDEXES:
  idx_cve_priority  → priority_score DESC  (fast top-N queries)
  idx_cve_severity  → severity            (filter by severity)
  idx_cve_urgency   → urgency             (filter by urgency)
  idx_cve_created   → created_at DESC     (time-based queries)
  idx_cve_kev       → is_cisa_kev = TRUE  (CISA KEV filter)
  idx_cve_exploit   → has_exploit = TRUE  (exploit filter)

VIEWS:
  critical_cves_today  → CVEs from last 24h, urgency CRITICAL/HIGH
  daily_stats          → Counts, averages, maximums for today
```

---

## 🔑 API Keys Required

| API | Free Tier | Rate Limit | Get It |
|-----|-----------|-----------|--------|
| Groq | ✅ Free | 14,400 req/day | [console.groq.com](https://console.groq.com) |
| Gemini 2.5 Flash-Lite | ✅ Free | 1M tokens/day | [aistudio.google.com](https://aistudio.google.com) |
| AlienVault OTX | ✅ Free | 10,000 req/month | [otx.alienvault.com](https://otx.alienvault.com) |
| NVD (NIST) | ✅ Free | No key needed | Built-in |
| CISA KEV | ✅ Free | No key needed | Built-in |
| OSV.dev | ✅ Free | No key needed | Built-in |
| EPSS (FIRST.org) | ✅ Free | No key needed | Built-in |
| Telegram Bot | ✅ Free | Unlimited | @BotFather on Telegram |

**Total API cost: ₹0/month**

---

## ⚙️ Configuration

Key settings you can customize in the workflow:

```javascript
// Alert threshold (default: 8.5 out of 10)
// Lower = more alerts, Higher = fewer but more critical
priority_score >= 8.5

// Collection window (default: 2 hours)
// Increase for testing, keep at 2 for production
2 * 60 * 60 * 1000

// Daily digest time (default: 8 AM IST)
// Cron: "0 8 * * *"
0 8 * * *

// Priority scoring weights (must sum to 1.0)
CVSS:            0.30
EPSS:            0.25
CISA_KEV:        0.20
Public_Exploit:  0.15
Network_Exploit: 0.10
```

---

## 📊 Demo

### Sample Telegram Critical Alert
```
🔴 CRITICAL ALERT — CyberWatch

CVE-2024-12345
Apache HTTP Server — Remote Code Execution
⚡ ACTIVELY EXPLOITED (CISA KEV)
🔗 Attack chain potential detected

📊 Scores
• CVSS: 9.8/10
• EPSS: 94.0% exploitation probability
• Priority: 9.7/10

📝 What this means
This vulnerability allows attackers to execute arbitrary code on 
Apache HTTP Server without any login required. Any website running 
Apache 2.4.x is potentially vulnerable.

💥 Attack type: Remote Code Execution
🏭 Category: Web Application
👥 Linked threat actors: APT28, Lazarus Group
🎯 MITRE ATT&CK: T1190, T1059, T1055

✅ Recommended action
Update Apache to version 2.4.58 immediately.

⏱️ Timeline: Immediate (exploit available)
🕐 Detected: 15/01/2025, 10:30:00 AM
```

### Sample Daily Digest
```
🛡️ CyberWatch Daily Brief
📅 Wednesday, 15 January 2025
──────────────────────────────

📊 Today's Numbers
• Total new CVEs: 47
• 🔴 Critical: 3
• 🟠 High: 12
• 🟡 Medium: 28
• ⚡ CISA KEV (active attacks): 2
• 💣 Public exploits available: 5

🤖 AI Executive Summary
Today's threat landscape is dominated by two actively exploited 
vulnerabilities in widely-deployed web servers. Security teams 
should prioritize patching Apache and Nginx installations immediately.
The presence of APT28 activity indicators suggests nation-state 
interest in these attack vectors.

🔴 TOP CRITICAL THREATS
1. CVE-2024-12345 ⚡
   └ Remote Code Execution | Score: 9.7/10
   └ Critical Apache vulnerability being actively exploited...
...
```

---

## 📁 Project Structure

```
cyberwatch/
│
├── 📄 README.md                        ← You are here
├── 📄 docker-compose.yml               ← One command setup
├── 📄 .env.example                     ← Environment variables template
├── 📄 .gitignore                       ← Git ignore rules
├── 📄 LICENSE                          ← MIT License
│
├── 📁 workflows/
│   └── cyberwatch_all_agents.json      ← Complete n8n workflow (import this)
│
├── 📁 database/
│   └── setup.sql                       ← PostgreSQL schema + indexes + views
│
└── 📁 docs/
    └── ARCHITECTURE.md                 ← Deep architecture explanation
```

---

## 🤝 Contributing

Contributions are welcome! Here's how:

1. Fork the repo
2. Create your branch: `git checkout -b feature/amazing-feature`
3. Commit: `git commit -m 'feat: add amazing feature'`
4. Push: `git push origin feature/amazing-feature`
5. Open a Pull Request

---

## 📜 License

MIT License — see [LICENSE](LICENSE) file.

---

## 👨‍💻 Author

**Tanmay Awal**  
Final Year B.Tech Computer Science  
[LinkedIn](https://www.linkedin.com/in/tanmay-awal-548b0a322) • [GitHub](https://github.com/Tanmay-Awal)

---

## ⭐ Star History

If CyberWatch helped you, please consider starring the repo! It helps others discover this project.

---

<div align="center">

**Built with ❤️ using n8n · Gemini · Groq · PostgreSQL · Docker**

*Zero budget. Production architecture. Real intelligence.*

</div>
