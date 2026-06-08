-- cohort retention 
-- who joined in Jan 2022, how many were still here 12 months later? 
WITH cohortData AS
(
SELECT 
  strftime(signup_date, '%y-%m') AS cohort_month,
  COUNT(*) AS total_customers
FROM accounts 
GROUP BY 1
),

retained_customers AS 
(
SELECT 
  strftime(signup_date, '%y-%m') AS cohort_month,
  --difference between subscription start date & signup date (in months)
  (date_part('year',s.start_date) - date_part('year',a.signup_date)) * 12 +
  (date_part('month',s.start_date) - date_part('month',a.signup_date)) AS months_been,
  COUNT(DISTINCT a.account_id) AS active_customers
FROM accounts a 
JOIN subscriptions s 
ON a.account_id = s.account_id
GROUP BY 1,2

)
SELECT  
  c.cohort_month,
  c.total_customers,
  r.active_customers,
  r.months_been,
  ROUND(r.active_customers*100.0/c.total_customers,2) AS retention_pct
FROM cohortData c
JOIN retained_customers r
ON  c.cohort_month = r.cohort_month
ORDER BY 1,4

/*
We have 3 years of data. Let's compare the Jan 2022 cohort vs. 
the Jan 2023 cohort to answer the founder's question: "Is our product getting stickier?"

A. The Year-over-Year Retention Check
Jan 2022 Cohort: Month 12 Retention = 94.08%
Jan 2023 Cohort: Month 12 Retention = 91.55%
Insight: "Our retention is just looking high (above 90%)",But
"Our long-term retention is actually declining. Customers who joined in 2022 were 2.5% more likely to stay 
for a year than those who joined in 2023. This suggests that as we scaled, we began acquiring 'lower quality' leads or 
the product is not scaling well for newer use cases."

B. The "Total Customers" Decay (Confirming Q1)
Look at total_customers column:
Jan 22: 152
Jan 23: 71
Jan 24: 34
Insight: This confirms our "Acquisition Decay" from Q1. Not only are we getting fewer customers, but the ones we do get
are slightly less likely to stay for a full year. The business is effectively shrinking from both ends.

C. The "30-Month Stability"
Observation: Look at 22-01. After Month 24, the retention stabilizes at 88.16% and stays there until Month 35.
Insight: Once a customer survives 2 years with us, they basically never leave. These are our "Power Users." We need to find out 
what they are doing in the app.
*/

