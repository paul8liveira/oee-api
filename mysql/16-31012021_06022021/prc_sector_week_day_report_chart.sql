USE `oee`;
DROP procedure IF EXISTS `prc_sector_week_day_report_chart`;

DELIMITER $$
USE `oee`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `prc_sector_week_day_report_chart`(
	IN p_channel_id int,
	IN p_sector_id int,
    IN p_year_number char(4),
    IN p_week_number char(2), 
    IN p_date_ini varchar(20),
	IN p_date_fin varchar(20)
)
BEGIN
	set @v_query = '
		select p.pause_name 
			 , case when length(p.pause_name) > 10 then concat(left(p.pause_name, 10), \'...\') else p.pause_name end as pause_name_short
			 , p.pause_type
			 , sum(p.pause) as pause              
			 , count(0) as count
             , concat(\'(\', count(0), \') \', p.pause_name) as pause_name_count
		  from (
			select mpd.date_ref
				 , mpd.pause_reason_id
				 , mpd.pause
				 , pr.name as pause_name
				 , case pr.type when \'PP\' then \'Pausa programada\' else \'Pausa não programada\' end as pause_type
				 , mpd.channel_id
				 , mpd.date_ref_week
			  from machine_pause_dash mpd
             inner join machine_data m on m.code = mpd.machine_code 
			 inner join pause_reason pr on pr.id = mpd.pause_reason_id
			 where mpd.channel_id = __channel_id
			   and m.sector_id = __sector_id
			   __period
			 group by mpd.insert_index
		) p
		group by p.pause_reason_id
		order by sum(p.pause) desc
		limit 10
	';
    
    -- canal e maquina
	set @v_query = replace(@v_query, '__channel_id', p_channel_id);
    set @v_query = replace(@v_query, '__sector_id', p_sector_id);
    
    -- periodo
	if(p_week_number <> '' and p_year_number <> '') then
       set @v_query = replace(@v_query, '__period', concat('and mpd.date_ref_week = ', p_week_number, ' and mpd.date_ref_year = ', p_year_number));
	else    
		set @v_query = replace(@v_query, '__period', concat('
			and mpd.date_ref between (STR_TO_DATE(\'', p_date_ini, '\', \'%Y-%m-%d %H:%i:%s\'))  
								 and (STR_TO_DATE(\'', p_date_fin, '\', \'%Y-%m-%d %H:%i:%s\'))'));
	end if;       
    
	prepare stmt from @v_query;
	execute stmt;
	deallocate prepare stmt;          
END$$

DELIMITER ;

