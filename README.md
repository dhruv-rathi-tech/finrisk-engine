# FinRisk: Financial Statement Anomaly & Risk Narrator

An AI-augmented audit-analytics pipeline that detects statistically anomalous year-over-year (YoY) variances in public company filings, benchmarks them against industry peers, and uses a locally-hosted LLM to generate auditor-grade narrative explanations.

---

## Project Structure

```text
.
├── pipeline/
│   ├── fetch_data.py               # SEC EDGAR XBRL ingestion
│   ├── normalize.py                # Tag harmonization & SQLite staging
│   ├── analyze.py                  # YoY % deltas & peer z-score engine
│   ├── flag.py                     # Deterministic anomaly thresholding
│   └── narrate.py                  # Local LLM auditor commentary (Ollama)
├── data/
│   ├── raw/
│   │   └── .gitkeep                # SEC EDGAR raw JSON responses (gitignored)
│   └── finrisk.db                  # Validated SQLite analytics database
├── sql/
│   ├── schema.sql                  # DDL table schemas (financials, metrics, flags, narratives)
│   └── queries.sql                 # Operational & audit validation SQL queries
├── reports/
│   └── data_summary.json           # Execution metrics & anomaly breakdown scorecard
├── utils/
│   ├── retry_narrate.py            # Re-attempts unfulfilled narrative rows
│   ├── list_flags.py               # CLI summary of flagged anomalies
│   ├── inspect_tags.py             # SEC XBRL taxonomy tag inspector
│   ├── check_msft.py               # OPEX derivation consistency validator
│   ├── debug_gaps.py               # Missing period & tag gap diagnostics
│   └── debug_api.py                # LLM connectivity test
├── .env.example                    # Environment variable template
├── .gitignore                      # Git exclusion rules (caches, virtualenvs, raw dumps)
├── LICENSE                         # MIT License
├── requirements.txt                # Python package dependencies
└── README.md                       # Project documentation
```

---

## Architecture & Flow

```mermaid
flowchart LR
    A[SEC EDGAR API] -->|fetch_data.py| B[data/raw/ Cache]
    B -->|normalize.py| C[(data/finrisk.db)]
    C -->|analyze.py| D[Peer Z-Score & Percentile Engine]
    D -->|flag.py| E[Anomaly Flags & Caveats]
    E -->|narrate.py| F[Ollama / Llama 3.2 3B]
    F -->|SQLite Update| G[Power BI Dashboard]
```

---

## Core Design Principles

- **Pure Statistical Detection**: The detection layer relies strictly on peer z-scores and percentile ranks computed with deterministic, auditable thresholds ($|z| \ge 2.0$).
- **AI as Communicator, Not Decision-Maker**: The LLM's sole responsibility is **narration**—explaining pre-flagged mathematical variances in plain English using SEC filing context. It never determines whether a figure is anomalous.
- **Defensible & Auditable**: Distinguishes between sensationalized "AI fraud detection" claims and institutional-grade, verifiable quantitative risk analysis.

---

## Dataset & Scope

| Attribute | Details |
| :--- | :--- |
| **Source** | SEC EDGAR XBRL company-facts API (Live public filings) |
| **Timeframe** | FY2020 – FY2024 (spans COVID-19 structural shocks as an unassisted baseline anomaly test) |
| **Retail Peer Group (8)** | `WMT`, `TGT`, `COST`, `HD`, `LOW`, `TJX`, `BBY`, `KR` |
| **Tech Peer Group (9)** | `AAPL`, `MSFT`, `GOOGL`, `META`, `ADBE`, `CRM`, `ORCL`, `CSCO`, `INTC` |
| **Monitored Metrics** | Revenue, Net Income, Operating Expenses, Gross Profit, Total Assets |

---

## Pipeline Execution

| Phase | Module | Functionality |
| :---: | :--- | :--- |
| **1** | [`pipeline/fetch_data.py`](pipeline/fetch_data.py) | Ingests company-facts JSON directly from SEC EDGAR via rate-limited API calls. |
| **2** | [`pipeline/normalize.py`](pipeline/normalize.py) | Harmonizes inconsistent XBRL tags, derives GAAP metrics, validates periods, and stages to SQLite. |
| **3** | [`pipeline/analyze.py`](pipeline/analyze.py) | Calculates YoY % deltas and derives industry peer z-scores and percentile ranks. |
| **4** | [`pipeline/flag.py`](pipeline/flag.py) | Evaluates rule-based anomaly thresholds ($|z| \ge 2.0$) and tags low-base distortion caveats. |
| **5** | [`pipeline/narrate.py`](pipeline/narrate.py) | Feeds context to local Llama 3.2 3B to generate auditor-style commentary. |
| **BI** | `FinRisk.pbix` | Interactive 4-page dashboard: Overview, Company Drill-down, Peer Benchmarking, Anomalies. |

---

## Data Quality & Accounting Nuance

Real SEC filings present significant reporting inconsistencies that this pipeline explicitly accounts for:

- **XBRL Tag Fragmentation**: Companies report equivalent concepts under varied tags (e.g., `Revenues` vs. `RevenueFromContractWithCustomerExcludingAssessedTax`). Handled via hierarchical priority fallbacks.
- **Unreliable `fy` Metadata**: SEC API fiscal-year tags can misrepresent true accounting periods. Year buckets are derived strictly from the period `end` date.
- **Method-Locking per Entity**: Prevented synthetic swings (e.g., Microsoft's reported OPEX shifting scope between FY22–FY23). A single derivation formula is enforced across all 5 years per company.
- **Principled `NULL` Retention**: Undisclosed or non-derivable values (e.g., Oracle/Kroger Gross Profit) remain `NULL` rather than being fabricated.
- **Low-Base Distortion Caveats**: Flagged items with massive percentage spikes caused by near-zero prior-year bases (e.g., TJX FY2022 Net Income +3547.8% following COVID troughs) receive a `distortion_caveat` tag instructing the LLM to prioritize dollar shifts.

---

## Quickstart Guide

### 1. Prerequisites
- Python 3.10+
- [Ollama](https://ollama.ai/) installed and running locally
- Pull the narrator model:
  ```bash
  ollama pull llama3.2:3b
  ```

### 2. Setup
Clone the repository and install dependencies:
```bash
git clone https://github.com/dhruv-rathi-tech/finrisk-engine.git
cd finrisk-engine
pip install -r requirements.txt
```

### 3. Run the Pipeline
> **Note**: Update the `USER_AGENT` variable in [`pipeline/fetch_data.py`](pipeline/fetch_data.py) with your email as mandated by SEC EDGAR fair access policy.

```bash
python pipeline/fetch_data.py      # Pull raw SEC EDGAR filings
python pipeline/normalize.py       # Standardize & load into SQLite
python pipeline/analyze.py         # Compute YoY deltas & peer z-scores
python pipeline/flag.py            # Flag statistical anomalies
python pipeline/narrate.py         # Generate LLM risk commentary
```

### 4. Interactive Power BI Dashboard
Open `FinRisk.pbix` in Power BI Desktop and point the data source connection to your local `data/finrisk.db`.

---

## License

Distributed under the [MIT License](LICENSE).