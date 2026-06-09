-- Feature Retention Drivers 
--We now know who stays (the 88% survivors). Now we need to know WHAT they do. This is the most "Actionable" part for ROI.

-- The Business Question:
-- "What specific feature usage in the first 30 days predicts that a customer will be in that 88% 'Forever' group?"

WITH usagedata AS
(
SELECT 
  a.account_id,
  f.feature_name,
  COUNT(f.usage_id) AS times_feature_used
FROM accounts a 
JOIN feature_usage f 
ON a.account_id = f.account_id
WHERE DATE_DIFF('day',a.signup_date , f.usage_date) BETWEEN 0 AND 29 
GROUP BY 1,2
),

featurexchurn AS
(
SELECT  
  u.feature_name,
  COUNT(*) AS num_of_users_used,
  SUM(a.churn_flag) AS users_churned
FROM accounts a
JOIN usagedata u 
ON a.account_id = u.account_id
GROUP BY 1
)

SELECT 
  feature_name,
  ROUND(SUM(users_churned) * 100.0 / SUM(num_of_users_used),2) AS churn_pct
FROM featurexchurn
GROUP BY feature_name 
ORDER BY 2 DESC

/*
SSO Churn: 8.88% (Lowest)
Webhook Churn: 9.54% (Second Lowest)
API/Collab Churn: 12%+ (Highest)

SSO adoption correlates with 30% lower churn. This is likely because SSO indicates Enterprise customers with high switching costs
and IT lock-in.

Recommendation: We shouldn't just 'force SSO' (which Basic users can't use). Instead, we should:

Prioritize SSO setup as a key milestone for Enterprise onboarding.
Identify at-risk Enterprise accounts that haven't configured SSO by Day 30 and flag them for Customer Success intervention.
Use SSO adoption rate as a leading indicator of account health."

 */
