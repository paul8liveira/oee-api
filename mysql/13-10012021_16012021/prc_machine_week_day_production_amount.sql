USE `oee`;
DROP procedure IF EXISTS `prc_machine_week_day_production_amount`;

DELIMITER $$
USE `oee`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `prc_machine_week_day_production_amount`(
	IN p_channel_id int,
	IN p_machine_code varchar(10),
    IN p_year_number char(4),
    IN p_week_number char(2),
    IN p_date_ini varchar(20),
	IN p_date_fin varchar(20)
)
BEGIN
	create temporary table if not exists tmp_wd_report_amount(
		machine_code varchar(10),
		amount float(15,2)
	) engine=memory;
    
	set @v_query = '
        insert into tmp_wd_report_amount
		select mc_cd as machine_code
			 , avg(coalesce(field5, 0)) as amount 
		  from feed f inner join (
			select max(f.id) as id
			  from feed f
			 where f.ch_id = __channel_id
			   and f.mc_cd = convert(\'__machine_code\' using latin1) collate latin1_swedish_ci
			   __period
			 group by f.mc_cd
					, date_format(f.inserted_at, \'%d%m%Y\')
		) tf on tf.id = f.id
	';
    
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

