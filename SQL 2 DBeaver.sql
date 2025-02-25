select 
ad_date,
campaign_id,
sum(spend) as total_spend,
sum(impressions) as total_impresions,
sum(clicks) as total_clicks,
sum(value) as total_value,
sum(spend)::numeric/sum(clicks)::numeric as CPC,
sum(spend)::numeric/sum(impressions)::numeric*1000 as CPM,
sum(clicks)::numeric/sum(impressions)::numeric*100 as CTR,
(sum(value)::numeric-sum(spend)::numeric)/sum(spend)::numeric as ROMI
from facebook_ads_basic_daily fabd 
where clicks > 0 and impressions > 0 and spend > 0
group by ad_date,campaign_id 
order by ad_date desc;