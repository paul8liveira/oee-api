USE `oee`;
DROP procedure IF EXISTS `prc_chart_product_pareto`;

DELIMITER $$
USE `oee`$$
CREATE PROCEDURE `prc_chart_product_pareto`(
	in p_channel_id int,
    in p_machine_code varchar(10),
    in p_time_filter int
)
BEGIN
	set @totalAmount := 0;
	set @queryProductsCount = '
		select sum(p.amount) 
		  into @totalAmount 
		  from (
			select mpd.amount
			  from machine_product_dash mpd
			 where mpd.channel_id = __channel_id
			   __machine_filter
			   and mpd.date_ref_year = year(now())
			   __filter
			 group by mpd.insert_index
		) p;';
    
	set @queryProducts = '       
		select d.*
			 , round(@frequencyCount := @frequencyCount + d.percentage, 2) as sum_percentage
		  from (
            select concat(\'(\', c.count, \') \', c.product_name) as product_name_count
				 , c.* 
			  from (
				select p.product_name 
					 , case when length(p.product_name) > 10 then concat(left(p.product_name, 10), \'...\') else p.product_name end as product_name_short
					 , sum(p.amount) as amount             
					 , round(((sum(p.amount) * 100) / @totalAmount),2) as percentage  
                     , count(0) as count
				  from (
					select mpd.date_ref
						 , mpd.product_id
						 , mpd.amount
						 , pr.name as product_name
						 , mpd.channel_id
					  from machine_product_dash mpd
					 inner join product pr on pr.id = mpd.product_id
					 where mpd.channel_id = __channel_id
					   __machine_filter
					   and mpd.date_ref_year = year(now())
					   __filter                       
					 group by mpd.insert_index
				) p
				group by p.product_id
			) c
			order by c.amount desc
		) d,
		(select @frequencyCount := 0) SQLVars;';
        
        -- canal
		set @queryProducts = replace(@queryProducts, '__channel_id', p_channel_id);
		set @queryProductsCount = replace(@queryProductsCount, '__channel_id', p_channel_id);
        
        -- filtro por maquina
        if(p_machine_code is not null) then
			set @queryProducts = replace(@queryProducts, '__machine_filter', concat('and mpd.machine_code = ', '''', p_machine_code, ''''));
            set @queryProductsCount = replace(@queryProductsCount, '__machine_filter', concat('and mpd.machine_code = ', '''', p_machine_code, '''')); 
        else    
			set @queryProducts = replace(@queryProducts, '__machine_filter', '');
            set @queryProductsCount = replace(@queryProductsCount, '__machine_filter', '');        
        end if;
        
        -- filtro somente por ano
        if(p_time_filter = 0) then
			set @queryProducts = replace(@queryProducts, '__filter', '');
            set @queryProductsCount = replace(@queryProductsCount, '__filter', '');
        -- filtro somente por mes
        elseif (p_time_filter = 1) then
			set @queryProducts = replace(@queryProducts, '__filter', 'and mpd.date_ref_month = month(now())');
            set @queryProductsCount = replace(@queryProductsCount, '__filter', 'and mpd.date_ref_month = month(now())'); 
        -- filtro por mes/semana
        elseif(p_time_filter = 2) then
			set @queryProducts = replace(@queryProducts, '__filter', 'and mpd.date_ref between date_sub(now(), interval 7 day) and now()');
            set @queryProductsCount = replace(@queryProductsCount, '__filter', 'and mpd.date_ref between date_sub(now(), interval 7 day) and now()');        
		-- filtro por mes/dia
        elseif(p_time_filter = 3) then
			set @queryProducts = replace(@queryProducts, '__filter', 'and mpd.date_ref_day = day(now()) and mpd.date_ref_month = month(now())');
			set @queryProductsCount = replace(@queryProductsCount, '__filter', 'and mpd.date_ref_day = day(now()) and mpd.date_ref_month = month(now())');
		-- filtro por mes/dia anterior
        else
			set @queryProducts = replace(@queryProducts, '__filter', 'and mpd.date_ref_day = (day(now())-1) and mpd.date_ref_month = month(now())');
			set @queryProductsCount = replace(@queryProductsCount, '__filter', 'and mpd.date_ref_day = (day(now())-1) and mpd.date_ref_month = month(now())');        
        end if;    
        
    prepare stmt from @queryProductsCount;
	execute stmt;
	deallocate prepare stmt;  
    
    prepare stmt from @queryProducts; 
	execute stmt;
	deallocate prepare stmt;      
        
END$$

DELIMITER ;

