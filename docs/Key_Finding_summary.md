# Velocity SaaS — Key Findings Summary

**Analyst:** Suraj Rajput  
**Project type:** Portfolio revenue-analytics analysis  
**Dataset:** 2,000 B2B SaaS accounts, 2.35M feature-usage events, support tickets, and subscription records

---

## The Business Situation

Velocity SaaS appears stable when viewed only through total MRR.

The movement underneath tells a more concerning story: New MRR weakened sharply, while expansion from existing customers and the current customer base carried more of the revenue trend.

The main business questions are:

- Is acquisition quality weakening?
- Which customer segments create the greatest revenue exposure?
- Which active accounts are showing early usage decay?
- What should Customer Success review first?

---

## Five Important Findings

### 1. Net New MRR Stalled at $852

January 2024 showed the clearest revenue warning:

| MRR component | Value |
|---|---:|
| New MRR | $55,990 |
| Expansion MRR | $17,429 |
| Contraction MRR | -$727 |
| Churned MRR | -$71,840 |
| **Net New MRR** | **$852** |

New MRR fell from its January 2022 peak of $781,948 to $55,990 in January 2024 — a decline of approximately 92.8%.

**Interpretation:** Acquisition weakness and retention pressure were compounding. The next step would be to investigate acquisition-channel quality, onboarding, usage decay, and churn concentration by segment.

---

### 2. Enterprise Shows Higher Observed Logo Churn

| Plan | Observed logo churn |
|---|---:|
| Enterprise | 13.88% |
| Basic | 10.58% |
| Pro | 8.61% |

Enterprise logo churn was 31.2% higher than Basic in this dataset.

Because Enterprise accounts generally carry more MRR, this may create disproportionate revenue exposure. The next validation step is to compare churned MRR by plan rather than relying only on logo churn.

**Recommended action:** Review Enterprise onboarding, support history, usage behaviour, renewal timing, and churned MRR.

---

### 3. $411,801 of Current MRR Exposure from Usage Decay

A strict current usage-decay screen flagged:

- Currently active accounts
- At least 5 active days in the previous calendar month
- A 50% or greater drop in active days in the latest month

Results:

| Metric | Value |
|---|---:|
| Flagged accounts | 78 |
| Current MRR exposure | $411,801 |
| Enterprise flagged accounts | 22 |
| Enterprise MRR exposure | $315,767 |
| Enterprise share of exposure | 76.7% |

**Interpretation:** These accounts are still active and paying, but their usage has declined sharply. This is a Customer Success review queue, not a guarantee that the accounts will churn.

**Recommended action:** Sort by current MRR and review the highest-value accounts first, with Enterprise accounts as the immediate priority.

---

### 4. Feature Adoption Shows Exploratory Retention Associations

Observed historical churn rates:

| Feature | Adopters | Non-adopters | Relative difference |
|---|---:|---:|---:|
| SSO | 8.88% | 11.94% | 25.7% lower among adopters |
| Webhook | 9.54% | 11.51% | 17.1% lower among adopters |
| Integrations | 9.62% | 11.47% | 16.1% lower among adopters |

These are observed associations in the portfolio dataset. They do not prove that the features cause retention.

**Recommended action:** Treat SSO, Webhook, and Integrations as onboarding and retention hypotheses. Validate them on real customer data before making them formal product or CS KPIs.

---

### 5. Support and CSAT Show Historical Risk Associations

Historical account-level comparisons showed:

- Accounts with average CSAT below 3 had a 63.59% observed churn rate within that group.
- Accounts in the 48h+ average-resolution group had 11.90% observed churn.
- Accounts in the 24–48h group had 9.38% observed churn.
- The 1–2 ticket group had 13.46% observed churn.
- The 6+ ticket group had 11.83% observed churn.

**Interpretation:** Low CSAT and slower resolution are useful areas for investigation. These historical comparisons should not automatically be treated as causal or as guaranteed future-churn warnings.

**Recommended action:** Validate the timing of CSAT, support resolution, and future churn using a time-aware account-snapshot analysis.

---

## Recommended Priority Actions

| Priority | Action | Owner | Timeline |
|---:|---|---|---|
| 1 | Review the 78 usage-decay accounts, sorted by current MRR | Customer Success | This week |
| 2 | Calculate churned MRR by plan and investigate Enterprise churn | RevOps / CS | 1–2 weeks |
| 3 | Review Enterprise accounts without early SSO/Webhook adoption | CS / Product | 1–2 weeks |
| 4 | Investigate low-CSAT and slow-resolution accounts | CS Operations | 1–2 weeks |
| 5 | Validate acquisition-channel quality using MRR, expansion, and customer mix | Growth / RevOps | 2–4 weeks |

---

## Modelling Note

A calibrated, time-aware logistic-regression model was built to prioritise accounts for future-churn review.

The model:

- Uses monthly account snapshots
- Uses support and usage information available before the snapshot date
- Predicts churn during the following 60 days
- Uses time-based validation
- Produces a ranked Customer Success queue
- Is delivered through a Streamlit scoring interface

The model is a prioritisation tool, not a guarantee. Its performance varies across time periods and should be monitored and retrained as new labelled data becomes available.

---

## Data Scope and Limitations

This is a portfolio analysis using a controlled B2B SaaS dataset. The results demonstrate the analysis workflow and reporting structure; they are not client results.

For a real engagement, the workflow would begin with:

1. Data-quality validation
2. Agreement on MRR and churn definitions
3. Confirmation of feature and support-data timing
4. Time-aware model validation
5. Review of findings with the client’s CS, RevOps, and Product teams
