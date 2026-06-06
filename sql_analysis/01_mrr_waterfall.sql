-- MRR WaterFall
WITH mrr_data AS
(
SELECT 
  strftime(movement_date, '%Y-%m') AS month,
  SUM(CASE WHEN movement_type = 'New' THEN mrr_change ELSE 0 END ) AS New,
  SUM(CASE WHEN movement_type = 'Expansion' THEN mrr_change ELSE 0 END) AS Expansion ,
  SUM(CASE WHEN movement_type = 'Contraction' THEN mrr_change ELSE 0 END) AS Contraction ,
  SUM(CASE WHEN movement_type = 'Churn' THEN mrr_change ELSE 0 END) AS Churn,
FROM mrr_movements
GROUP BY month
ORDER BY month
)
SELECT month , New, Expansion , Contraction , Churn , (New + Expansion + Contraction + Churn) AS Net_New_Mrr
FROM mrr_data
ORDER BY Net_New_Mrr

/*
MRR Waterfall exposed a critical turning point for Velocity SaaS: The Leaky Bucket (From starting mrr of $781k in 2022 jan
to net new mrr of $852 in 2024 jan)

In January 2024, despite acquiring $55k in New MRR, churn wiped out $71k, leaving net growth at a staggering low of just $852. 
The data shows that we can't just 'market' our way out of this—we have to fix retention.
*/
