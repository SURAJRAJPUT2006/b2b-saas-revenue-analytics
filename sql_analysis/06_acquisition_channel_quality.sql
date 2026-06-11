-- Marketing ROI --
WITH expansion_data AS
(
SELECT 
  account_id,
  MIN(movement_date) AS first_upgrade,
  SUM(mrr_after) AS total_expansion_mrr,
  COUNT(*) AS expansion_count
FROM mrr_movements
WHERE movement_type = 'Expansion'  
GROUP BY 1
)
SELECT  
  a.referral_source,
  COUNT(a.account_id) AS customers ,
  COUNT(ed.account_id) AS customers_upgraded,
  ROUND(COUNT(ed.account_id) * 100.0 / COUNT(a.account_id) , 2) AS upgrade_pct ,
  ROUND(AVG(DATE_DIFF('day', a.signup_date , CAST(ed.first_upgrade AS DATE))),0) AS avg_days_to_first_upgrade,
  SUM(ed.total_expansion_mrr) AS total_expansion_mrr_per_channel
FROM accounts a 
LEFT JOIN expansion_data ed 
ON a.account_id = ed.account_id 
GROUP BY 1
ORDER BY 6 DESC;


/*
Channel quality and ROI 
Finding: Organic Search is the business's "Growth Engine."

The Data: Organic Search (502 accounts) and Paid Search (414 accounts) dominate acquisition. 
Both have the lowest churn rates (~9.2%–9.7%).

The Revenue Impact: Combined, they generated $471,742 in expansion MRR. Organic Search alone generated $281,547, 
which is 48% higher than Paid Search ($190,195).

The Efficiency Gap: While Paid Search is high quality, it comes with a high CAC (Customer Acquisition Cost). 
Organic Search provides nearly identical churn/expansion quality at near-zero incremental cost.

The Velocity Observation: Referrals are the "Fastest Growers" (365 days to upgrade), but they hit a ceiling quickly 
(lowest upgrade rate at 7.5%).

Strategic Recommendation: Double down on SEO/Content for Organic growth. Use Paid Search as a "booster" for 
specific high-value keywords, but treat Organic Search as the primary Ideal Customer Profile (ICP) source.
*/

