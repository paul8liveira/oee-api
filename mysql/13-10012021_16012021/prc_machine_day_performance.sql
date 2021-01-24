USE `oee`;
DROP procedure IF EXISTS `prc_machine_day_performance`;

DELIMITER $$
USE `oee`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `prc_machine_day_performance`(
	IN p_channel_id int,
	IN p_machine_code varchar(10),
    IN p_date_ini varchar(20),
	IN p_date_fin varchar(20)
)
BEGIN
	create temporary table if not exists tmp_machine_day_performance(
		machine_code varchar(10),
		field5 float(15,2),
		performance float(15,2)
	) engine=memory;

	delete from tmp_machine_day_performance;
    
	insert into tmp_machine_day_performance 
	select coalesce(t.mc_cd, 'no data') as machine_code
		 , cast(coalesce(t.field5, 0) as decimal(15,2)) as field5
		 , case 
		     when t.category = 'linear' then
               round(coalesce((((t.field3 / (t.field5 - t.pause_pp - t.pause_np)) * t.nominal_output)), 0), 2)
		     when (t.field3 > 0 and t.manual_production = 0) then
				1
		     when (t.field3 = 0 and t.manual_production = 0) then
				0                
             else 
				round(((t.manual_production / (t.field5 - t.pause_pp))) / ((t.field5 - t.pause_pp - t.pause_np) / (t.field5 - t.pause_pp)), 2)
		  end as performance
	  from (
		select f.ch_id
			 , f.mc_cd
			 , sum(f.field5) as field5
			 , sum(f.field3) as field3 
             , m.nominal_output
             , m.category
             , coalesce(ta.pp, 0) as pause_pp
             , coalesce(ta.pnp, 0) as pause_np
             , case
			     when m.category = 'not_linear'
					then fnc_machine_not_linear_production(f.ch_id, f.mc_cd, p_date_ini, p_date_fin) 
				 else 0 
			   end as manual_production
		  from feed f 
		 inner join (
			select max(f.id) as id
			  from feed f
			 where f.ch_id = p_channel_id
			   -- and f.field5 > 0 atenção: removido pq  influencia na performance, me avise se tiver interesse em mudar para avaliarmos juntos
			   and ((f.mc_cd = convert(p_machine_code using latin1) collate latin1_swedish_ci) or ifnull(p_machine_code, '') = '')
			   and f.inserted_at between 
				   (STR_TO_DATE(p_date_ini, '%Y-%m-%d %H:%i:%s'))  
			   and (STR_TO_DATE(p_date_fin, '%Y-%m-%d %H:%i:%s'))			
			 group by f.mc_cd
				 , date_format(f.inserted_at, '%d%m%Y')
		) tmp on f.id = tmp.id
		inner join machine_data m on m.code = f.mc_cd
         left join tmp_machine_day_availability ta on ta.machine_code = f.mc_cd
        group by f.mc_cd
	) t;     
    
END$$

DELIMITER ;

