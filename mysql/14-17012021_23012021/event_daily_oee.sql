create event if not exists event_daily_oee
	on schedule
		every 1 day
		starts '2021-01-26 23:46:00'
		comment 'Inserir dados na tabela daily_oee'
    do
		call prc_daily_oee(14, date_format(now(), '%Y-%m-%d'));
        
        
        