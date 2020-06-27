USE `oee`;
DROP procedure IF EXISTS `prc_machine_product_dash`;

DELIMITER $$
USE `oee`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `prc_machine_product_dash`(
	in p_channel_id int,
    in p_machine_code varchar(10),
    in p_date_ini varchar(50),
    in p_date_fin varchar(50),
    in p_product_id int,
    in p_amount float(15,2),
    in p_time_in_min int
)
BEGIN
    set @insert_index = (select ifnull(max(insert_index),0)+1 from machine_product_dash);
    
	insert into machine_product_dash(channel_id, machine_code, date_ref, product_id, amount, time_in_min, insert_index)
	select f.ch_id
		 , f.mc_cd
		 , DATE_FORMAT(f.inserted_at, '%Y-%m-%d %H:%i:%s') as date_ref
		 , p_product_id
         , p_amount
         , p_time_in_min
         , @insert_index
	  from feed f
	 where f.ch_id = p_channel_id
	   and f.mc_cd = p_machine_code
	   and f.inserted_at between p_date_ini and p_date_fin
	   and not exists(select 1 
						from machine_product_dash mpd 
					   where mpd.channel_id = f.ch_id 
						 and mpd.machine_code = f.mc_cd 
						 and mpd.date_ref = f.inserted_at);
END$$

DELIMITER ;

alter table machine_product_dash add column time_in_min int;