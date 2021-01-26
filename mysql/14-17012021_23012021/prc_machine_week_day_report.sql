USE `oee`;
DROP procedure IF EXISTS `prc_machine_week_day_report`;

DELIMITER $$
USE `oee`$$
CREATE DEFINER=`root`@`%` PROCEDURE `prc_machine_week_day_report`(
	IN p_channel_id int,
	IN p_machine_code varchar(10),
    IN p_year_number char(4),
    IN p_week_number char(2),
    IN p_date_ini varchar(20),
	IN p_date_fin varchar(20)
)
BEGIN
	-- consultas por semana e ano, fazem a media diretamente da tabela daily_oee
	if(p_week_number <> '' and p_year_number <> '') then
		select p_channel_id as channel_id
             , machine_code
			 , machine_name
			 , round(sum(production), 2) as amount
			 , round(avg(availability), 2) as availability
			 , round(avg(performance), 2) as performance
			 , round(avg(quality), 2) as quality
			 , round(avg(oee), 2) as oee
		  from (
		select machine_code
			 , machine_name
			 , production
			 , availability
			 , performance
			 , quality
			 , oee
			 , weekday(str_to_date(concat(year, '-' , month, '-' , day), '%Y-%m-%d')) as weekday
			 , week
		  from daily_oee
		 where year = p_year_number
		   and week = p_week_number
		   and ((machine_code = p_machine_code) or ifnull(p_machine_code, '') = '')
		) t
		where weekday not in(5, 6) -- menos sabado e domingo
		group by machine_code, week; 
	else    
		-- quantidade produzida
		call prc_machine_day_production(p_channel_id, p_machine_code, p_date_ini, p_date_fin);

		-- disponibilidade
		call prc_machine_day_availability(p_channel_id, p_machine_code, p_date_ini, p_date_fin);
		
		-- desempenho
		call prc_machine_day_performance(p_channel_id, p_machine_code, p_date_ini, p_date_fin);
		
		-- qualidade
		set @v_quality = fnc_channel_quality(p_channel_id);
		  
		select p_channel_id as channel_id
			 , t.machine_code as machine_code
			 , m.name as machine_name
			 , round(coalesce(t.amount, 0), 2) as amount
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
				 , pr.amount
			  from tmp_machine_day_performance p
			  left join tmp_machine_day_production pr on pr.machine_code = p.machine_code
			  left join tmp_machine_day_availability a on a.machine_code = p.machine_code
			  
		) t
		inner join machine_data m on m.code = t.machine_code;    
		
		drop table tmp_machine_day_production;
		drop table tmp_machine_day_availability;
		drop table tmp_machine_day_performance;
	end if; 


END$$

DELIMITER ;

