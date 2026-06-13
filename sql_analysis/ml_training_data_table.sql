/*
Account ID
Categorical Features: plan_tier, industry, referral_source.
Numerical Features:
total_tickets 
avg_satisfaction 
avg_resolution_time 
active_days_last_30 (the ghosting signal)
has_sso (1 if they used SSO in first 30 days, else 0 )
has_webhook (1 if they used Webhook in first 30 days, else 0 )
The Target: churn_flag (0 or 1).

CTE 1: The Support Signal 
Aggregate the support_tickets table to get:

total_tickets
avg_satisfaction (Handle the NULLs!)
avg_resolution_time

CTE 2: The Adoption Signal 
Look at feature_usage in the first 30 days (just like Q4) to create flags:

has_sso (1 if they used it, else 0)
has_webhook (1 if they used it, else 0)

CTE 3: The Ghosting Signal 
Get the count of active_days in the last 30 days of the dataset (December 2024).
Note: If an account has 0 days, the join will make it NULL. We will handle that in Python.

Final Query 4: The Final Stitch
Join everything to the accounts table.
*/
CREATE TABLE churn_data AS
WITH support_data AS
(
SELECT 
  account_id,
  COUNT(*) AS total_tickets,
  ROUND(AVG(satisfaction_score)) AS avg_satisfaction,
  ROUND(AVG(resolution_time_hours)) AS avg_resolution_time
FROM support_tickets 
GROUP BY 1
),
adoption_data AS
(
SELECT 
  f.account_id,
  MAX(CASE WHEN f.feature_name = 'SSO' THEN 1 ELSE 0 END) AS has_sso,
  MAX(CASE WHEN f.feature_name = 'Webhook' THEN 1 ELSE 0 END) AS has_webhook
FROM feature_usage f 
JOIN accounts a ON a.account_id = f.account_id
WHERE DATE_DIFF('day', a.signup_date , f.usage_date) BETWEEN 0 AND 30
GROUP BY 1
),
recent_actives AS
(
SELECT
  account_id,
  COUNT(DISTINCT usage_date) AS active_days_last_month
FROM feature_usage
WHERE usage_date >='2024-12-01'
GROUP BY 1
)
SELECT 
  a.account_id,
  a.plan_tier,
  a.industry,
  a.referral_source,
  COALESCE(sd.total_tickets, 0) AS total_tickets,
  COALESCE(sd.avg_satisfaction,3) AS avg_csat,
  COALESCE(sd.avg_resolution_time,0) AS avg_res_time,
  COALESCE(ad.has_sso,0) AS has_sso,
  COALESCE(ad.has_webhook,0) AS has_webhook,
  COALESCE(ra.active_days_last_month, 0) AS active_days_last_month,
  a.churn_flag
FROM accounts a
LEFT JOIN support_data sd ON sd.account_id = a.account_id
LEFT JOIN adoption_data ad ON ad.account_id = a.account_id
LEFT JOIN recent_actives ra ON ra.account_id = a.account_id;

