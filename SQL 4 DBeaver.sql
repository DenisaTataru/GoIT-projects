with combined_data as (
	select 
	ad_date,
	campaign_name,
	adset_name,
	coalesce(spend,0) AS spend,
	coalesce(impressions,0) AS impressions,
	COALESCE(reach,0) AS reach,
	COALESCE(clicks,0) AS clicks,
	coalesce(leads,0) AS leads,
	COALESCE(value,0) AS value,
	url_parameters
	from 
	facebook_ads_basic_daily fabd 
	join 
	facebook_campaign fc on fabd.campaign_id =fc.campaign_id 
	join 
	facebook_adset on fabd.adset_id =facebook_adset.adset_id
	union all 
	select 
	ad_date,
	campaign_name,
	adset_name,
	coalesce(spend,0) AS spend,
	coalesce(impressions,0) AS impressions,
	COALESCE(reach,0) AS reach,
	COALESCE(clicks,0) AS clicks,
	coalesce(leads,0) AS leads,
	COALESCE(value,0) AS value,
	url_parameters
	from 
	google_ads_basic_daily gabd)
select 
ad_date,
campaign_name,
	sum(spend) as total_spend,
	sum(impressions) as total_impresions,
	sum(clicks) as total_clicks,
	sum(value) as total_value,
	case when sum(clicks) >0 then sum(spend)::numeric/sum(clicks)::numeric 
	end as CPC,
	case when sum(impressions) >0 then sum(spend)::numeric/sum(impressions)::numeric *1000 
	end as CPM,
	case when sum(impressions) >0 then sum(clicks)::numeric/sum(impressions)::numeric *100 
	end as CTR,
	case when sum(spend) >0 then (sum(value)::numeric-sum(spend)::numeric)/sum(spend)::numeric *100 
	end as ROMI,
	case 
	when lower(substring(url_parameters,'utm_campaign=([^\&]+)')) = 'nan' then null
	else lower(substring(url_parameters,'utm_campaign=([^\&]+)'))
	end as utm_campaign
from combined_data 
group by 1,2,11