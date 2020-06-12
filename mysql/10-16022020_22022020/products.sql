CREATE TABLE product (
	id int not null auto_increment primary key,
	channel_id int(11) NOT NULL,
	machine_code varchar(10) NOT NULL,
	name varchar(500) not null,
	created_at timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
	updated_at timestamp NULL DEFAULT NULL,
	CONSTRAINT fk_product_channel FOREIGN KEY (channel_id) REFERENCES channel (id),
	CONSTRAINT fk_product_machine FOREIGN KEY (machine_code) REFERENCES machine_data (code)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

USE `oee`;
DROP procedure IF EXISTS `prc_product`;

DELIMITER $$
USE `oee`$$
CREATE PROCEDURE `prc_product`(
	in p_id int,
    in p_channel_id int,
    in p_machine_code varchar(10),
    in p_name varchar(500)
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
		insert into product(channel_id, machine_code, name)
		values (p_channel_id, p_machine_code, p_name);
        set v_product_id = LAST_INSERT_ID();
    else
		update product 
		   set name = p_name
             , machine_code = p_machine_code
	     where id = p_id;
           set v_product_id = p_id;
    end if;
    
	select p.*
		 , c.name as channel_name
		 , m.name as machine_name
	  from product p
	 inner join channel c on c.id = p.channel_id
	 inner join machine_data m on m.code = p.machine_code
	 where p.id = v_product_id;    
END$$

DELIMITER ;




