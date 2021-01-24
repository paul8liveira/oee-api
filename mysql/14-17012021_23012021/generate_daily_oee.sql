select concat('call prc_daily_oee(14, \'', year(inserted_at), '-', month(inserted_at), '-', day(inserted_at), ' 00:00:00\');')
  from feed
 where ch_id = 14
 and year(inserted_at) > 2018
 group by year(inserted_at) 
     , month(inserted_at) 
     , day(inserted_at);