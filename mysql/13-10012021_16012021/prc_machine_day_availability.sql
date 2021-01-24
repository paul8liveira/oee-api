USE `oee`;
DROP procedure IF EXISTS `prc_machine_day_availability`;

DELIMITER $$
USE `oee`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `prc_machine_day_availability`(
	IN p_channel_id int,
	IN p_machine_code varchar(10),
    IN p_date_ini varchar(20),
	IN p_date_fin varchar(20)
)
BEGIN
	create temporary table if not exists tmp_machine_day_availability(
		machine_code varchar(10),
		pp float(15,2),
		pnp float(15,2)
	) engine=memory;

	delete from tmp_machine_day_availability;
    
	insert into tmp_machine_day_availability
	select b.machine_code
		 , sum(pp) as pp
		 , sum(pnp) as pnp
	  from (select a.machine_code 
				 , case a.type
					when 'PP' then sum(a.pause)
					else 0 end as pp
				 , case a.type
					when 'NP' then sum(a.pause)
					else 0 end as pnp        
			  from (select mpd.machine_code
						 , pr.type
						 , mpd.pause 
					  from machine_pause_dash mpd
					  left join pause_reason pr on pr.id = mpd.pause_reason_id
					 where mpd.channel_id = p_channel_id
					   and ((mpd.machine_code = convert(p_machine_code using latin1) collate latin1_swedish_ci) or ifnull(p_machine_code, '') = '')
					   and mpd.date_ref between (STR_TO_DATE(p_date_ini, '%Y-%m-%d %H:%i:%s'))  
											and (STR_TO_DATE(p_date_fin, '%Y-%m-%d %H:%i:%s'))
					 group by mpd.insert_index
					) a 
                     group by a.machine_code, a.type
			) b
			group by b.machine_code;
END$$

DELIMITER ;

