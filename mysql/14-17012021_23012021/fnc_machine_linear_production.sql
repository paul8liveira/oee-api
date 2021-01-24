USE `oee`;
DROP function IF EXISTS `fnc_machine_linear_production`;

DELIMITER $$
USE `oee`$$
CREATE FUNCTION fnc_machine_linear_production (
	p_channel_id int,
	p_machine_code varchar(10),
    p_date_ini varchar(20),
	p_date_fin varchar(20) 
)
RETURNS float
BEGIN
	set @v_prod = 0;
	select sum(f.field3)
      into @v_prod
	  from feed f 
	 inner join (     
		select max(id) as id
		  from feed
	     where ch_id = p_channel_id
		   and mc_cd = convert(p_machine_code using latin1) collate latin1_swedish_ci
		   and inserted_at between (STR_TO_DATE(p_date_ini, '%Y-%m-%d %H:%i:%s'))  
							   and (STR_TO_DATE(p_date_fin, '%Y-%m-%d %H:%i:%s'))
	     group by mc_cd
			 , date_format(inserted_at, '%d%m%Y')) tf on tf.id = f.id;   
             
	return coalesce(@v_prod, 0);
END$$

DELIMITER ;

