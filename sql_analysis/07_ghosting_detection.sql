 -- Ghosting Detection (Usage Decay) -  the "Silent Killers."'
WITH usage_data AS
(
SELECT
  account_id,
  SUM(usage_count) AS total_monthly_usage,
  strftime('%y-%m' , usage_date) AS month,
  COUNT(DISTINCT usage_date) AS active_days
FROM feature_usage
GROUP BY 1,3 
ORDER BY 2 DESC 
),
decay_data AS
(
SELECT 
  account_id,
  active_days,
  month,
  total_monthly_usage,
  LAG(active_days) OVER(PARTITION BY account_id ORDER BY month) AS prev_active_days
FROM usage_data
),
final_decay_info AS
(
SELECT 
  dd.account_id,
  a.plan_tier,
  s.mrr_amount,
  dd.active_days,
  dd.month,
  dd.prev_active_days,
  ROUND((dd.active_days - dd.prev_active_days) * 100.0 / dd.prev_active_days,2) AS usage_drop_pct 
FROM decay_data dd
JOIN accounts a ON a.account_id = dd.account_id
 JOIN (
        SELECT account_id, mrr_amount, 
               ROW_NUMBER() OVER(PARTITION BY account_id ORDER BY start_date DESC) as rn
        FROM subscriptions
        WHERE end_date IS NULL
    ) s ON s.account_id = dd.account_id  AND s.rn = 1
WHERE dd.prev_active_days >= 5
      AND ((dd.active_days - dd.prev_active_days) * 100.0 / dd.prev_active_days) <= -50 
      AND a.churn_flag = 0
      AND dd.month = '24-12'
ORDER BY usage_drop_pct 
)
SELECT 
  COUNT(*) AS total_ghost ,
  SUM(mrr_amount) AS total_mrr_at_risk,
  plan_tier
FROM final_decay_info
GROUP BY plan_tier
ORDER BY 1 DESC

/*
The Count vs. The Cash:

we have the same number of ghosts in Basic and Pro (28 each).
But the Enterprise ghosts (only 22 accounts) represent $315,767 in revenue.

The Insight: Enterprise ghosts are 33x more dangerous than Basic ghosts. Losing 22 Enterprise accounts is a catastrophic blow 
to the company's valuation.

The "Silent" $400K Leak:

Total MRR at Risk: ~$411,800.
If we do nothing, this company will likely lose $4.9 Million in ARR (Annual Recurring Revenue) over the next year just from 
these 78 accounts.

The "So What": we just found a $400k/month problem that was "invisible" because these customers hadn't cancelled yet.
*/
