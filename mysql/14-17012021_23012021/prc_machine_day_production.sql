USE `oee`;
DROP procedure IF EXISTS `prc_machine_day_production`;

DELIMITER $$
USE `oee`$$
CREATE DEFINER=`root`@`%` PROCEDURE `prc_machine_day_production`(
	IN p_channel_id int,
	IN p_machine_code varchar(10),
    IN p_date_ini varchar(20),
	IN p_date_fin varchar(20)
)
BEGIN
	create temporary table if not exists tmp_machine_day_production(
		machine_code varchar(10),
		amount float(15,2)
	) engine=memory;
    
    -- em caso de estar no mesmo contexto
    delete from tmp_machine_day_production;
  
	insert into tmp_machine_day_production           
	select t.machine_code
		 , case t.category
				when 'not_linear' then
					round(coalesce(fnc_machine_not_linear_production(t.channel_id, t.machine_code, p_date_ini, p_date_fin), 0), 2)
				else
					round(coalesce(fnc_machine_linear_production(t.channel_id, t.machine_code, p_date_ini, p_date_fin), 0), 2)
			end as amount
		
	  from (
		select cm.channel_id
             , cm.machine_code
			 , m.category 
		  from channel_machine cm 
          join machine_data m on m.code = cm.machine_code
		 where cm.channel_id = p_channel_id
           and ((cm.machine_code = convert(p_machine_code using latin1) collate latin1_swedish_ci) or ifnull(p_machine_code, '') = '')
	) t;           
END$$

DELIMITER ;

