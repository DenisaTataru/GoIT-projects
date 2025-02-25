with combined_data as (
	select fabd.ad_date,
	fc.campaign_name,
	fa.adset_name,
	fabd.spend,
	fabd.impressions,
	fabd.reach,
	fabd.clicks,
	fabd.leads,
	fabd.value
	from facebook_ads_basic_daily fabd left join facebook_campaign fc on fabd.campaign_id =fc.campaign_id 
	left join facebook_adset fa on fabd.adset_id =fa.adset_id
	union all 
	select ad_date,
	campaign_name,
	adset_name,
	spend,
	impressions,
	reach,
	clicks,
	leads,
	value
	from google_ads_basic_daily gabd )
select 
	ad_date,
	campaign_name,
	sum(spend) as total_cost,
	sum(impressions) as total_impressions,
	sum(clicks) as total_clicks,
	sum(value) as total_conversion
from combined_data
group by 1,2
order by 1 