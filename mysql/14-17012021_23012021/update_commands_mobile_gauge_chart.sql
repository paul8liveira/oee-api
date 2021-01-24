update commands set query = '
select d.machine_code 
     , m.name as machine_name
     , coalesce(mc.max_day_production, 0) as max_day_production
     , if(ifnull(mc.max_day_production, 0) = 0, 0, round(coalesce(((d.production * 100) / mc.max_day_production), 0), 2)) as production     
     , replace(mc.chart_tooltip_desc, \'__value\', d.production) as chart_tooltip_desc     
     , DATE_FORMAT(d.inserted_at, \'%d/%m/%Y %H:%i:%s\') as date
  from daily_oee d
 inner join machine_data m on m.code = d.machine_code
 inner join machine_config mc on mc.machine_code = d.machine_code
where d.channel_id = __ch_id
  and concat(lpad(d.day, 2, 0), lpad(d.month, 2, 0), d.year) = \'__date_ini\';'
where channel_id = 14
and type = 'mobile_gauge_chart';