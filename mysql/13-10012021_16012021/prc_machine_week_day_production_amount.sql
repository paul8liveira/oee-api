USE `oee`;
DROP procedure IF EXISTS `prc_machine_week_day_production_amount`;

DELIMITER $$
USE `oee`$$
CREATE DEFINER=`root`@`%` PROCEDURE `prc_machine_week_day_production_amount`(
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
    
    -- em caso de estar no mesmo contexto
    delete from tmp_wd_report_amount;
    
	set @v_query = '
        insert into tmp_wd_report_amount           
		select t.code as machine_code
			 , case t.category
					when \'not_linear\' then
						round(coalesce(fnc_machine_not_linear_production(__channel_id, \'__machine_code\', \'__year_number\', \'__week_number\', \'__date_ini\', \'__date_fin\'), 0), 2)
					else
						(select coalesce(sum(f.field3), 0) as amount
						   from feed f 
						  inner join (select max(id) as id
										from feed
									   where ch_id = __channel_id
										 and mc_cd = \'__machine_code\'
										 __period
									   group by mc_cd
											  , date_format(inserted_at, \'%d%m%Y\')) tf on tf.id = f.id                
						)
				end as amount
			
		  from (
			select code
				 , category 
			  from machine_data m
			 where m.code = \'__machine_code\' 
		) t;           
	';
    
    -- canal e maquina
	set @v_query = replace(@v_query, '__channel_id', p_channel_id);
    set @v_query = replace(@v_query, '__machine_code', p_machine_code);
    
    -- periodo
	if(p_week_number <> '' and p_year_number <> '') then
       set @v_query = replace(@v_query, '__year_number', p_year_number);
       set @v_query = replace(@v_query, '__week_number', p_week_number);
	   set @v_query = replace(@v_query, '__date_ini', '');
       set @v_query = replace(@v_query, '__date_fin', '');
       
       
       set @v_query = replace(@v_query, '__period', concat('and inserted_at_week = ', p_week_number, ' and inserted_at_year = ', p_year_number));
	else    
       set @v_query = replace(@v_query, '__year_number', '');
       set @v_query = replace(@v_query, '__week_number', '');
	   set @v_query = replace(@v_query, '__date_ini', p_date_ini);
       set @v_query = replace(@v_query, '__date_fin', p_date_fin);
       
		set @v_query = replace(@v_query, '__period', concat('
			and inserted_at between (STR_TO_DATE(\'', p_date_ini, '\', \'%Y-%m-%d %H:%i:%s\'))  
								and (STR_TO_DATE(\'', p_date_fin, '\', \'%Y-%m-%d %H:%i:%s\'))'));
	end if;       
        
	prepare stmt from @v_query;
	execute stmt;
	deallocate prepare stmt;      
END$$

DELIMITER ;

