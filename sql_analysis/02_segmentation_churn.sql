-- Churn By Segment (plan tier, industry, referral source) ---
-- By Plan Tier 

WITH plantier AS (
  SELECT 
    plan_tier,
    COUNT(DISTINCT account_id) AS total_accounts,
    SUM(churn_flag) AS churned_accounts,
    ROUND(SUM(churn_flag) * 100.0 / COUNT(*),2) AS churn_pct
  FROM accounts
  GROUP BY plan_tier 
  ORDER BY churn_pct DESC
)
SELECT * FROM plantier

/*

1. The Enterprise Red Flag (The Biggest Leak)
The Data: our Enterprise churn (13.88%) is higher than Basic (10.58%) and Pro (8.61%).
The High-Value Insight: In the SaaS world, this is a disaster. Usually,
Enterprise churn should be near 0-5% because they sign long contracts and have more support.
The "Why": This suggests that while we are great at closing big deals (our Jan 2022 peak), 
we are failing at serving them.
Strategic Question: Is our product too "simple" for big companies? 
Or is our Enterprise pricing so high that they don't see the ROI?
This is where you'd recommend a deep dive into Support Tickets (Q5).

*/
-- By Industry
WITH industry AS 
(
 SELECT 
    industry,
    COUNT(DISTINCT account_id) AS total_accounts,
    SUM(churn_flag) AS churned_accounts,
    ROUND(SUM(churn_flag) * 100.0 / COUNT(*),2) AS churn_pct
 FROM accounts
 GROUP BY industry 
 ORDER BY churn_pct DESC
)
SELECT * FROM industry

/*

2. The Channel Paradox (Why Acquisition is Decaying)
The Data: Events (15.66% churn) vs. Partnerships (8.65% churn).
The High-Value Insight: This explains our Q1 problem. 
We likely spent a lot of money on Events in early 2022 to get that "launch peak," but 
those customers were "low quality"—they signed up but didn't stay.
Action: We should immediately stop the "Event-driven" growth model and move to a "Partner-led" growth model.

*/

-- BY Referral Source 

WITH referral_source AS
(
SELECT 
    referral_source,
    COUNT(DISTINCT account_id) AS total_accounts,
    SUM(churn_flag) AS churned_accounts,
    ROUND(SUM(churn_flag) * 100.0 / COUNT(*),2) AS churn_pct
FROM accounts
GROUP BY referral_source 
ORDER BY churn_pct DESC
)
SELECT * FROM referral_source

/*

3. Defining the ICP (Ideal Customer Profile)
The Data: Consulting (8.53%) and E-commerce (8.78%) are our stickiest industries.
The Insight: We have found Product-Market Fit in the Consulting and E-commerce sectors.
Action: Marketing should stop trying to sell to everyone (SaaS/Healthcare) and focus 100% of their new leads on Consulting firms.

*/

