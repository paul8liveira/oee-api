USE `oee`;
DROP procedure IF EXISTS `prc_oee`;

DELIMITER $$
USE `oee`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `prc_oee`(
	IN p_channel_id int,
	IN p_date_ini varchar(20),
	IN p_date_fin varchar(20),
	IN p_machine_code varchar(10)
)
begin
	-- disponibilidade
    call prc_machine_day_availability(p_channel_id, p_machine_code, p_date_ini, p_date_fin);
    
    -- desempenho
    call prc_machine_day_performance(p_channel_id, p_machine_code, p_date_ini, p_date_fin);
    
    -- qualidade
    set @v_quality = fnc_channel_quality(p_channel_id);
	
	select p_channel_id as channel_id
		 , t.machine_code 
		 , m.name as machine_name
		 , if(t.availability = 0, 0, round(((t.real_availability / t.availability) * 100), 2)) as availability
		 , round((t.performance * 100 ), 2) as performance
		 , @v_quality as quality
		 , if(t.availability = 0, 0, round(coalesce(((t.performance) * (t.real_availability / t.availability) * @v_quality), 0), 2)) as oee
	  from (
		select p.machine_code
			 , a.pp
			 , a.pnp
			 , p.performance
			 , (p.field5 - coalesce(a.pp, 0)) as availability
			 , ((p.field5 - coalesce(a.pp, 0)) - coalesce(a.pnp, 0)) as real_availability
		  from tmp_machine_day_performance p
		  left join tmp_machine_day_availability a on a.machine_code = p.machine_code
	) t
	 inner join machine_data m on m.code = t.machine_code;
     
    drop table tmp_machine_day_availability;
    drop table tmp_machine_day_performance;     
end$$

DELIMITER ;

