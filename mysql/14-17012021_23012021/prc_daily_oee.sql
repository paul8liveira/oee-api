USE `oee`;
DROP procedure IF EXISTS `prc_daily_oee`;

DELIMITER $$
USE `oee`$$
CREATE DEFINER=`root`@`%` PROCEDURE `prc_daily_oee`(
	in p_channel_id int(11),
    in p_date varchar(20)
)
BEGIN
	select concat(convert(date_format(str_to_date(p_date, '%Y-%m-%d %H:%i:%s'), '%Y-%m-%d'), char(10)), ' ', initial_turn, ':00')
         , concat(convert(date_format(str_to_date(p_date, '%Y-%m-%d %H:%i:%s'), '%Y-%m-%d'), char(10)), ' ', final_turn, ':59')
         , year(str_to_date(p_date, '%Y-%m-%d %H:%i:%s'))
         , month(str_to_date(p_date, '%Y-%m-%d %H:%i:%s'))
         , week(str_to_date(p_date, '%Y-%m-%d %H:%i:%s'), 5)
         , day(str_to_date(p_date, '%Y-%m-%d %H:%i:%s'))
	  into @v_date_ini, @v_date_fin, @v_year, @v_month, @v_week, @v_day
	  from channel 
	 where id = p_channel_id;
     
     delete from daily_oee 
      where channel_id = p_channel_id
        and year = @v_year
        and month = @v_month
        and day = @v_day;
        
	-- quantidade produzida
    call prc_machine_day_production(p_channel_id, '', @v_date_ini, @v_date_fin);
        
	-- disponibilidade
    call prc_machine_day_availability(p_channel_id, '', @v_date_ini, @v_date_fin);
    
    -- desempenho
    call prc_machine_day_performance(p_channel_id, '', @v_date_ini, @v_date_fin);
    
    -- qualidade
    set @v_quality = fnc_channel_quality(p_channel_id);
	
    insert into daily_oee(channel_id, machine_code, machine_name, production, availability, performance, quality, oee, year, month, week, day)
	select p_channel_id as channel_id
		 , t.machine_code 
		 , m.name as machine_name
         , t.amount
		 , if(t.availability = 0, 0, ((t.real_availability / t.availability) * 100)) as availability
		 , (t.performance * 100) as performance
		 , @v_quality as quality
		 , if(t.availability = 0, 0, coalesce(((t.performance) * (t.real_availability / t.availability) * @v_quality), 0)) as oee
         , @v_year, @v_month, @v_week, @v_day
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
     
END$$

DELIMITER ;

