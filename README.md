# Velocity SaaS — Revenue Analytics & Churn-Risk Prioritisation

[![Live Streamlit App](https://img.shields.io/badge/Live_App-Streamlit-FF4B4B?style=for-the-badge&logo=streamlit)](https://velocity-saas-churn-predictor.streamlit.app/)

[![Looker Dashboard](https://img.shields.io/badge/Executive_Dashboard-Looker_Studio-4285F4?style=for-the-badge&logo=google)](https://datastudio.google.com/reporting/63493602-4b12-4f11-928a-4eb91acbc790/page/p_n1xeecef4d)

[![Founder Memo](https://img.shields.io/badge/Strategy_Brief-PDF-B31B1B?style=for-the-badge&logo=adobeacrobatreader)](docs/Founder_Memo_Suraj_Rajput.pdf)

## Executive Summary

Velocity SaaS is a portfolio revenue-analytics project designed to demonstrate how an early-stage B2B SaaS team could investigate MRR movement, churn concentration, usage decay, and Customer Success priorities.

The analysis covers:

- 2,000 customer accounts
- 2.35 million feature-usage events
- 17,268 support tickets
- 46,205 subscription records
- MRR movement across 2022–2024

The central finding is that total MRR can appear stable while acquisition weakens and churn absorbs new revenue.

In January 2024:

- New MRR: **$55,990**
- Expansion MRR: **$17,429**
- Contraction: **-$727**
- Churned MRR: **-$71,840**
- Net New MRR: **$852**

## Deployed Solution

### 1. Executive Revenue Dashboard

A five-page Looker Studio dashboard covering:

- Revenue health overview
- MRR movement
- Churn by plan, industry, and acquisition channel
- Product and support associations
- Current usage-decay review queue

[Open the Looker dashboard](https://datastudio.google.com/reporting/63493602-4b12-4f11-928a-4eb91acbc790/page/p_n1xeecef4d)

### 2. Customer Success Risk Queue

Latest-observed-period usage-decay screen — December 2024 flags active accounts that meet this rule:

- At least five active days in the previous calendar month
- A 50% or greater drop in active days in the latest month
- The account is still active

The strict queue contains:

- **78 active accounts**
- **$411,801 current MRR exposure**
- **22 Enterprise accounts**
- **$315,767 Enterprise exposure**
- **76.7% of total exposure in Enterprise**

This is a Customer Success review queue, not a guarantee that the accounts will churn.

### 3. Calibrated Churn-Risk Model

The modelling layer uses monthly account snapshots:

```text
Past support and usage signals
→ snapshot date
→ churn during the following 60 days
```

Model validation: On a future held-out synthetic period, the top 50 scored account snapshots contained 16 actual churn cases, giving the queue 32% precision. Expanding the review queue to 500 accounts captured 31.6% of future churn cases. These results are intended to support prioritization, not automated churn decisions.



