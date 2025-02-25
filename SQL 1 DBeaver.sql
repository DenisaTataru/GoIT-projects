select 
ad_date,
spend,
clicks,
spend/clicks as CPC
from public.facebook_ads_basic_daily fabd 
where clicks >0
order by ad_date desc;