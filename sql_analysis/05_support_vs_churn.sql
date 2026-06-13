-- tickets_raised_churns
WITH tickets_data AS
(
SELECT 
  account_id,
  COUNT(*) AS total_tickets
FROM support_tickets
GROUP BY 1
)

SELECT 
  CASE  
    WHEN td.total_tickets IS NULL THEN '0(Silent)'
    WHEN td.total_tickets BETWEEN 1 AND 2 THEN '1-2(Low)'
    WHEN td.total_tickets BETWEEN 3 AND 5 THEN '3-5(Mid)'
  ELSE '6+(High)' END AS volume_bucket,  
  COUNT(*) AS total_accounts,
  SUM(a.churn_flag) AS churned_accounts,
  ROUND(SUM(a.churn_flag) * 100.0 / COUNT(*), 2) AS churn_pct
FROM accounts a 
LEFT JOIN tickets_data td 
  ON a.account_id = td.account_id
GROUP BY 1
ORDER BY churn_pct DESC;


-- Avg_resolution_time_churns
-- The Resolution Cliff: Filter for accounts with avg_resolution_time > 48 hours. Compared their churn to those with < 48 hours.

WITH resolution_data AS
(
SELECT 
  account_id,
  COUNT(*) AS total_tickets,
  AVG(resolution_time_hours) AS avg_resolution_time
FROM support_tickets
GROUP BY 1
),
resolution_bucket AS
(
SELECT 
  account_id,
  CASE WHEN avg_resolution_time <= 48 THEN 'avg_res_time_less'
       WHEN avg_resolution_time > 48 THEN 'avg_res_time_high'
  END AS resolution_bucket
FROM resolution_data
)  
SELECT 
  rb.resolution_bucket,
  COUNT(*) AS total_users,
  SUM(a.churn_flag) AS churned_users,
  ROUND(SUM(a.churn_flag)* 100.0 / COUNT(*),2) AS churn_pct
FROM accounts a
LEFT JOIN resolution_bucket rb 
ON rb.account_id = a.account_id
GROUP BY 1 
ORDER BY churn_pct DESC;


-- satisfaction_score_based_churns
-- CSAT Predictor: Look at accounts with avg_satisfaction < 3. Does this signal a churn in the next 30 days?

WITH satisfaction_score_data AS 
(
SELECT 
  DISTINCT account_id,
  COUNT(*) AS total_tickets,
  ROUND(AVG(satisfaction_score)) AS avg_satisfaction_score
FROM support_tickets
GROUP BY 1
),
satisfaction_affected_table AS
(
SELECT 
  s.account_id,
  s.satisfaction_score,
  DATE_DIFF('day', s.created_date, c.churn_date) AS days_from_bad_score_to_churn
FROM support_tickets s
JOIN churn_events c ON s.account_id = c.account_id
WHERE s.satisfaction_score < 3 
  AND DATE_DIFF('day', s.created_date, c.churn_date) BETWEEN 0 AND 30
)
SELECT 
  COUNT(DISTINCT account_id) AS total_churned
FROM satisfaction_affected_table


-----------------------------------------------------------------------------------------------------------------------------------
-- Insight :
/*

A. The "Low Engagement" Risk (13.46% Churn)
Result: The "1-2 tickets" group has higher churn than the "6+ tickets" group.
Insight: High support volume is actually a sign of HEALTH. It means they are using the product and trying to make it work. 
Customers with only 1 ticket are "unengaged." They run into one problem, get bored, and leave.

B. The "SLA" Reality (48 Hours)
Result:  48h analysis shows 11.86% (High Res time) vs 9.81% (Less Res time).
Insight: This proves the ROI of speed. Moving a customer from the "High" bucket to the "Less" bucket reduces their 
churn probability by ~2%.
Impact: If those 1,627 users had 2% lower churn, we would save 32 Enterprise/Pro accounts.

C. The "CSAT Smoking Gun" 
Result: 47 people churned within 30 days of a bad score.
Insight: This is your leading indicator. A bad score isn't just "unhappy feedback"; it is a cancellation notice 30 days in advance.
Recommendation: Any satisfaction score < 3 must trigger an Auto-Escalation to a manager. You have 30 days to save that revenue.

*/
