USE `oee`;
DROP function IF EXISTS `fnc_machine_not_linear_production`;

DELIMITER $$
USE `oee`$$
CREATE DEFINER=`root`@`localhost` FUNCTION `fnc_machine_not_linear_production`(
	p_channel_id int,
	p_machine_code varchar(10),
    p_date_ini varchar(20),
	p_date_fin varchar(20) 
) RETURNS float
BEGIN
    -- o IoT não consegue prever a produção de uma máquina não linear por isso, eles informam manualmente
    -- isso serve somente para maquina de categoria "not_linear"
    -- soma do amount agrupado por produto da maquina dentro do periodo
    
	set @v_prod = 0;
    
	select sum(t.amount_cycle) as production
	  into @v_prod
	  from (select (mpd.amount * p.cycle_time) as amount_cycle
			  from machine_product_dash mpd
			 inner join product p on p.id = mpd.product_id
			 where mpd.channel_id = p_channel_id
			   and mpd.machine_code = convert(p_machine_code using latin1) collate latin1_swedish_ci
			   and mpd.date_ref between (STR_TO_DATE(p_date_ini, '%Y-%m-%d %H:%i:%s')) 
									and (STR_TO_DATE(p_date_fin, '%Y-%m-%d %H:%i:%s'))
			 group by mpd.product_id
					, mpd.insert_index) t;   
    
    return coalesce(@v_prod, 0);
END$$

DELIMITER ;