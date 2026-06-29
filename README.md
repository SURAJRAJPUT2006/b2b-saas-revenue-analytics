# 📊 Velocity SaaS: Predictive Churn Engine & Revenue Turnaround

[![Live ML App](https://img.shields.io/badge/Live_App-Streamlit-FF4B4B?style=for-the-badge&logo=streamlit)](https://velocity-saas-churn-predictor.streamlit.app/)
[![Looker Dashboard](https://img.shields.io/badge/Executive_Dashboard-Looker_Studio-4285F4?style=for-the-badge&logo=google)](https://datastudio.google.com/reporting/63493602-4b12-4f11-928a-4eb91acbc790/page/p_n1xeecef4d)
[![Founder Memo](https://img.shields.io/badge/Strategy_Brief-PDF-B31B1B?style=for-the-badge&logo=adobeacrobatreader)](docs/Founder_Memo_Suraj_Rajput.pdf) 

## 💡 Executive Summary
B2B SaaS companies often operate with a "leaky bucket" mentality—focusing heavily on new acquisition while ignoring silent revenue decay. 

This project is a full-stack Revenue Operations audit of 2.2M rows of synthetic SaaS telemetry data (benchmarked against ProfitWell/OpenView). By shifting from reactive BI reporting to a **Predictive Machine Learning Engine**, I successfully flagged 78 "ghosting" accounts, identifying **$411,800 in at-risk MRR** before cancellation occurred.

---

## 📸 The Deployed Solution

### 1. The ML Churn Predictor (Real-Time CS Workflow)
I built and deployed a live Streamlit web application powered by a Logistic Regression model (achieving **98% Recall**). Customer Success teams can adjust customer parameters to calculate real-time churn probability.
👉 **[Try the Live Web App Here](https://velocity-saas-churn-predictor.streamlit.app/)**

### 2. The BI Dashboard (Executive Rearview Mirror)    
I architected a 5-page Google Looker Studio dashboard visualizing MRR Waterfalls, Cohort Retention, and the $411k Silent Risk Tracker. 
👉 **[View the Executive Dashboard Here](https://datastudio.google.com/reporting/63493602-4b12-4f11-928a-4eb91acbc790/page/p_n1xeecef4d)**

---

## 📈 Key Business Discoveries (SQL Analytics)

Through deep-dive SQL segmentation, I isolated the exact operational friction points driving revenue leakage:

* **🚨 The Enterprise Crisis (80/20 Risk):** Enterprise accounts churned at 13.8% (vs a 10% baseline). Of the 78 at-risk accounts flagged by the model, just **22 Enterprise accounts represented $315,767 in MRR**. 
* **⏳ The Support SLA Trap:** Accounts waiting >48 hours for a support resolution saw churn probability triple. Furthermore, accounts submitting 1-2 tickets churned *more* than those submitting 6+, proving that early friction without resolution drives silent disengagement.
* **🥇 The Golden Handcuffs:** Integrating SSO and Webhooks actively reduced churn by 25%. These features create high switching costs and must become Day-1 onboarding KPIs.
* **🚀 Acquisition Misalignment:** "Event" marketing yielded a massive 15.66% churn rate. Conversely, Organic Search acted as the true growth engine, driving $281,547 in highly-retained expansion MRR at near-zero CAC.

---

## ⚙️ Tech Stack & Architecture
* **Database & Querying:** SQL (DuckDB)
* **Predictive Modeling:** Python (Scikit-Learn, Pandas, NumPy)
* **Model Algorithm:** Logistic Regression (Class-Weight Balanced, StandardScaler)
* **Visualization & Deployment:** Streamlit, Plotly, Google Looker Studio
* **Business Metrics:** MRR/ARR Waterfalls, NRR, CAC, Cohort Retention, Usage Decay

---

## 📂 Repository Structure
```text
b2b-saas-revenue-analytics/
├── data/                             # Data generation scripts and CSV samples
├── sql_analysis/                     # Business logic, CTES, and feature engineering
├── ml_predictive_engine/             # Python Jupyter Notebooks (EDA & Model Training)
├── streamlit_app/                    # Web app deployment files (app.py, requirements.txt)
├── docs/                             # Executive Strategy PDFs (Founder Memo)
└── README.md                         # Project documentation
