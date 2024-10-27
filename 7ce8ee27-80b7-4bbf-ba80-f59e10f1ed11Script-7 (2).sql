WITH cte AS (
  SELECT
    COALESCE(fabd.ad_date, gabd.ad_date) AS ad_date,
    fabd.url_parameters AS url_parameters,
    COALESCE(fabd.spend, 0) AS spend,
    COALESCE(fabd.impressions, 0) AS impressions,
    COALESCE(fabd.reach, 0) AS reach,
    COALESCE(fabd.clicks, 0) AS clicks,
    CASE WHEN fabd.leads IS NULL THEN 0 ELSE fabd.leads END AS leads,
    COALESCE(fabd.value, 0) AS value
  FROM facebook_ads_basic_daily fabd
  full join google_ads_basic_daily gabd ON fabd.ad_date = gabd.ad_date
  LEFT JOIN facebook_adset fa ON fabd.adset_id = fa.adset_id
  LEFT JOIN facebook_campaign fc ON fabd.campaign_id = fc.campaign_id
),
cte2 AS (
  SELECT
    ad_date,
    CASE WHEN LOWER(SUBSTRING(url_parameters, 49)) = 'nan' THEN NULL ELSE LOWER(SUBSTRING(url_parameters, 49)) END AS utm_campaign
  FROM cte
),
cte3 AS (
  SELECT
    ad_date,
    SUM(spend) AS total_spend,
    SUM(reach) AS Afisari,
    SUM(clicks) AS Clicks,
    SUM(value) AS Value
  FROM cte
  GROUP BY ad_date
)
SELECT
  cte.ad_date,
  cte2.utm_campaign,
  cte3.total_spend,
  cte3.Afisari,
  cte3.Clicks,
  cte3.Value,
  CASE WHEN cte3.Afisari = 0 THEN 0 ELSE CAST(cte3.Clicks AS FLOAT) / cte3.Afisari * 100 END AS CTR,
  CASE WHEN cte3.Clicks = 0 THEN 0 ELSE cte3.total_spend / CAST(cte3.Clicks AS FLOAT) END AS CPC,
  CASE WHEN cte3.Afisari = 0 THEN 0 ELSE cte3.total_spend / (cte3.Afisari / 1000) END AS CPM,
  CASE WHEN cte3.total_spend = 0 THEN 0 ELSE (cast (cte3.Value as float) - cast (cte3.total_spend as float) )/ cast(cte3.total_spend as float) END AS ROMI
FROM cte
LEFT JOIN cte2 ON cte.ad_date = cte2.ad_date
LEFT JOIN cte3 ON cte3.ad_date = cte.ad_date


    

    