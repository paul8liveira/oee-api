USE `oee`;
DROP procedure IF EXISTS `prc_machine_week_day_availability`;

DELIMITER $$
USE `oee`$$
CREATE DEFINER=`root`@`%` PROCEDURE `prc_machine_week_day_availability`(
	IN p_channel_id int,
	IN p_machine_code varchar(10),
    IN p_year_number char(4),
    IN p_week_number char(2),
    IN p_date_ini varchar(20),
	IN p_date_fin varchar(20)
)
BEGIN
	create temporary table if not exists tmp_wd_report_availability(
		machine_code varchar(10),
		pp float(15,2),
		pnp float(15,2)
	) engine=memory;
    
    -- em caso de estar no mesmo contexto
    delete from tmp_wd_report_availability;
    
	set @v_query = '
        insert into tmp_wd_report_availability
		select b.machine_code
			 , sum(pp) as pp
			 , sum(pnp) as pnp
		  from (
		select a.machine_code 
			 , case a.type
				when \'PP\' then sum(a.pause)
				else 0 end as pp
			 , case a.type
				when \'NP\' then sum(a.pause)
				else 0 end as pnp        
		  from (       
			select mpd.machine_code
				 , pr.type
				 , mpd.pause 
			  from machine_pause_dash mpd
			  left join pause_reason pr on pr.id = mpd.pause_reason_id
			 where mpd.channel_id = __channel_id
               and mpd.machine_code = convert(\'__machine_code\' using latin1) collate latin1_swedish_ci
			   __period
			 group by mpd.insert_index) a
		 group by a.machine_code, a.type) b
		 group by b.machine_code;
	';
        
    -- canal e maquina
	set @v_query = replace(@v_query, '__channel_id', p_channel_id);
    set @v_query = replace(@v_query, '__machine_code', p_machine_code);
    
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

