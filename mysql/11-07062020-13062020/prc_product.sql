USE `oee`;
DROP procedure IF EXISTS `prc_product`;

DELIMITER $$
USE `oee`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `prc_product`(
	in p_id int,
    in p_channel_id int,
    in p_machine_code varchar(10),
    in p_name varchar(500),
    in p_cycle_time decimal(5,2), 
    in p_measure_unit varchar(45)
)
BEGIN
	declare v_product_id int;
    
	if exists (select 1 
				 from product 
				where channel_id = p_channel_id 
                  and machine_code = p_machine_code 
                  and name = p_name
                  and ((p_id <> id) or p_id = 0)) then 
		signal sqlstate '99999'
		set message_text = 'Produto já cadastrado para esta máquina';
    end if;
    
    if(p_id = 0) then
		insert into product(channel_id, machine_code, name, cycle_time, measure_unit)
		values (p_channel_id, p_machine_code, p_name, p_cycle_time, p_measure_unit);
        set v_product_id = LAST_INSERT_ID();
    else
		update product 
		   set name = p_name
             , machine_code = p_machine_code
             , cycle_time = p_cycle_time
             , measure_unit = p_measure_unit
	     where id = p_id;
           set v_product_id = p_id;
    end if;
    
	select p.*
		 , c.name as channel_name
		 , m.name as machine_name
         , cycle_time
         , measure_unit
	  from product p
	 inner join channel c on c.id = p.channel_id
	 inner join machine_data m on m.code = p.machine_code
	 where p.id = v_product_id;    
END$$

DELIMITER ;

