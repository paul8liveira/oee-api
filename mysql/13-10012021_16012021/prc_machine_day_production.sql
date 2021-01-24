USE `oee`;
DROP procedure IF EXISTS `prc_machine_day_production`;

DELIMITER $$
USE `oee`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `prc_machine_day_production`(
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
	select t.code as machine_code
		 , case t.category
				when 'not_linear' then
					round(coalesce(fnc_machine_not_linear_production(p_channel_id, p_machine_code, p_date_ini, p_date_fin), 0), 2)
				else
					(select coalesce(sum(f.field3), 0) as amount
					   from feed f 
					  inner join (select max(id) as id
									from feed
								   where ch_id = p_channel_id
                                     and ((mc_cd = convert(p_machine_code using latin1) collate latin1_swedish_ci) or ifnull(p_machine_code, '') = '')
									 and inserted_at between (STR_TO_DATE(p_date_ini, '%Y-%m-%d %H:%i:%s'))  
														 and (STR_TO_DATE(p_date_fin, '%Y-%m-%d %H:%i:%s'))
								   group by mc_cd
										  , date_format(inserted_at, '%d%m%Y')) tf on tf.id = f.id                
					)
			end as amount
		
	  from (
		select code
			 , category 
		  from machine_data m
		 where m.code = convert(p_machine_code using latin1) collate latin1_swedish_ci 
	) t;           
END$$

DELIMITER ;

