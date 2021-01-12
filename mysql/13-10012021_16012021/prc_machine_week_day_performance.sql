USE `oee`;
DROP procedure IF EXISTS `prc_machine_week_day_performance`;

DELIMITER $$
USE `oee`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `prc_machine_week_day_performance`(
	IN p_channel_id int,
	IN p_machine_code varchar(10),
    IN p_year_number char(4),
    IN p_week_number char(2),
    IN p_date_ini varchar(20),
	IN p_date_fin varchar(20)
)
BEGIN
	create temporary table if not exists tmp_wd_report_performance(
		machine_code varchar(10),
		field5 float(15,2),
		performance float(15,2)
	) engine=memory;
    
	set @v_query = '
		insert into tmp_wd_report_performance
		select coalesce(t.mc_cd, \'no data\') as machine_code
			 , cast(coalesce(t.field5, 0) as decimal(15,2)) as field5
			 , round(coalesce((((t.field3 / (t.field5 - fnc_machine_week_day_pause(t.ch_id, t.mc_cd, \'__year_number\', \'__week_number\', \'__date_ini\', \'__date_fin\', \'PP\'))) * t.nominal_output)), 0),2) as performance 
		  from (
			select f.ch_id
				 , f.mc_cd
				 , sum(f.field5) as field5
				 , sum(f.field3) as field3 
				 , m.nominal_output
			  from feed f 
			 inner join (
				select max(f.id) as id
				  from feed f
				 where f.ch_id = __channel_id
				   and (f.mc_cd = convert(\'__machine_code\' using latin1) collate latin1_swedish_ci)
				   __period
				 group by f.mc_cd
					 , date_format(f.inserted_at, \'%d%m%Y\')
			) tmp on f.id = tmp.id
			inner join machine_data m on m.code = f.mc_cd
			group by f.mc_cd
		) t;
	';
	
    -- chamada da função de pausa
	set @v_query = replace(@v_query, '__week_number', p_week_number);
    set @v_query = replace(@v_query, '__year_number', p_year_number);
    set @v_query = replace(@v_query, '__date_ini', p_date_ini);
    set @v_query = replace(@v_query, '__date_fin', p_date_fin);
    
    -- canal e maquina
	set @v_query = replace(@v_query, '__channel_id', p_channel_id);
    set @v_query = replace(@v_query, '__machine_code', p_machine_code);
    
    -- periodo
	if(p_week_number <> '' and p_year_number <> '') then
       set @v_query = replace(@v_query, '__period', concat('and f.inserted_at_week = ', p_week_number, ' and f.inserted_at_year = ', p_year_number));
	else    
		set @v_query = replace(@v_query, '__period', concat('
			and f.inserted_at between (STR_TO_DATE(\'', p_date_ini, '\', \'%Y-%m-%d %H:%i:%s\'))  
								  and (STR_TO_DATE(\'', p_date_fin, '\', \'%Y-%m-%d %H:%i:%s\'))'));
	end if;       
    
	prepare stmt from @v_query;
	execute stmt;
	deallocate prepare stmt;      
END$$

DELIMITER ;

