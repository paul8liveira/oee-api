USE `oee`;
DROP procedure IF EXISTS `prc_machine_week_day_report`;

DELIMITER $$
USE `oee`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `prc_machine_week_day_report`(
	IN p_channel_id int,
	IN p_machine_code varchar(10),
    IN p_year_number char(4),
    IN p_week_number char(2),
    IN p_date_ini varchar(20),
	IN p_date_fin varchar(20)
)
BEGIN
	-- quantidade produzida
    call prc_machine_week_day_production_amount(p_channel_id, p_machine_code, p_year_number, p_week_number, p_date_ini, p_date_fin);

	-- disponibilidade
    call prc_machine_week_day_availability(p_channel_id, p_machine_code, p_year_number, p_week_number, p_date_ini, p_date_fin);
    
    -- desempenho
    call prc_machine_week_day_performance(p_channel_id, p_machine_code, p_year_number, p_week_number, p_date_ini, p_date_fin);
    
    -- qualidade
    set @v_quality = 0;
	set @v_pp = 0;
	set @v_pnp = 0;
	set @v_performance = 0;
	set @v_availability = 0; 
	set @v_real_availability = 0;   
    set @v_amount = 0;
    
    select coalesce(fnc_channel_quality(p_channel_id), 0) 
      into @v_quality;

	select amount 
      from tmp_wd_report_amount 	  
     where machine_code = p_machine_code
      into @v_amount;

	select pp
		 , pnp
	  from tmp_wd_report_availability 
	 where machine_code = p_machine_code
	  into @v_pp, @v_pnp;

	select performance
		 , (field5 - coalesce(@v_pp, 0))
	  from tmp_wd_report_performance 
	 where machine_code = p_machine_code
	  into @v_performance, @v_availability;    
      
	set @v_real_availability = (@v_availability - coalesce(@v_pnp, 0));
      
	drop table tmp_wd_report_amount;
    drop table tmp_wd_report_availability;
    drop table tmp_wd_report_performance;
    
    -- channel_id, machine_code, availability, performance, quality, oee
    select p_channel_id as channel_id
	     , p_machine_code as machine_code
         , round(coalesce(@v_amount, 0), 2) as amount
		 , concat(if(
			@v_availability = 0, 0, 
			round(((@v_real_availability / @v_availability) * 100), 2)
		 ), '%') as availability
		 , concat(round((@v_performance * 100), 2), '%') as performance
		 , concat(@v_quality, '%') as quality
		 , concat(if(
			@v_availability = 0, 0, 
			round(coalesce((@v_performance * (@v_real_availability / @v_availability) * @v_quality),0), 2)
		 ), '%') as oee 
	  from dual;
END$$

DELIMITER ;

