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
	google_ads_basic_daily gabd),
	monthly_stats as (
	select date_trunc('month',ad_date) as ad_month,
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
	group by ad_date, campaign_name, url_parameters
	),
	monthly_stats_changes as (
	select *,
	lag(CPC) over (partition by utm_campaign order by ad_month desc) as previous_month_CPC,
	lag(CPM) over (partition by utm_campaign order by ad_month desc) as previous_month_CPM,
	lag(CTR) over (partition by utm_campaign order by ad_month desc) as previous_month_CTR,
	lag(ROMI) over (partition by utm_campaign order by ad_month desc) as previous_month_ROMI
	from monthly_stats)
	select *,
	case when previous_month_CPC > 0 then CPC::numeric/previous_month_CPC
	when previous_month_CPC = 0 then 1
	end as CPC_change,
	case when previous_month_CPM > 0 then CPM::numeric/previous_month_CPM
	when previous_month_CPM = 0 then 1
	end as CPM_change,
	case when previous_month_CTR > 0 then CTR::numeric/previous_month_CTR
	when previous_month_CTR = 0 then 1
	end as CTR_change,
	case when previous_month_ROMI > 0 then ROMI::numeric/previous_month_ROMI
	when previous_month_ROMI = 0 then 1
	end as ROMI_change
	from monthly_stats_changes
	
	