USE `oee`;
DROP function IF EXISTS `fnc_machine_production`;

DELIMITER $$
USE `oee`$$
CREATE DEFINER=`root`@`%` FUNCTION `fnc_machine_production`(
	p_channel_id int,
	p_machine_code varchar(10),
    p_year_number char(4),
    p_week_number char(2),
    p_date_ini varchar(20),
	p_date_fin varchar(20)    
) RETURNS float
    DETERMINISTIC
begin
    -- isso serve somente para maquina de categoria "not_linear"
    -- soma do amount agrupado por produto da maquina
    -- isso deve ser multiplicado pelo tempo de ciclo do produto
	set @v_prod = 0;
    
	if(p_week_number <> '') then
		select sum(t.amount_cycle) as production
		  into @v_prod
		  from (
			select (mpd.amount * p.cycle_time) as amount_cycle
			  from machine_product_dash mpd
			 inner join product p on p.id = mpd.product_id
			 where mpd.channel_id = p_channel_id
			   and mpd.machine_code = p_machine_code
               and mpd.date_ref_year = cast(p_year_number as unsigned integer)
			   and mpd.date_ref_week = cast(p_week_number as unsigned integer)
			 group by mpd.product_id
					, mpd.insert_index
		) t;        
	else    
		select sum(t.amount_cycle) as production
		  into @v_prod
		  from (
			select (mpd.amount * p.cycle_time) as amount_cycle
			  from machine_product_dash mpd
			 inner join product p on p.id = mpd.product_id
			 where mpd.channel_id = p_channel_id
			   and mpd.machine_code = p_machine_code
			   and mpd.date_ref between (STR_TO_DATE(p_date_ini, '%Y-%m-%d %H:%i:%s')) 
									and (STR_TO_DATE(p_date_fin, '%Y-%m-%d %H:%i:%s'))
			 group by mpd.product_id
					, mpd.insert_index
		) t;         
	end if;     
    
    return coalesce(@v_prod, 0);
end$$

DELIMITER ;

