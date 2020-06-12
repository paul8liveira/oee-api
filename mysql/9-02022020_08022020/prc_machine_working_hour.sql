USE `oee`;
DROP procedure IF EXISTS `prc_machine_working_hour`;

DELIMITER $$
USE `oee`$$
CREATE PROCEDURE prc_machine_working_hour (
	in p_token varchar(50),
    in p_mc_cd varchar(10)
)
BEGIN
	declare v_count int(11);
    declare v_channel_id int(11);
    
    select count(*)
         , id 
      into v_count
         , v_channel_id 
      from channel 
	 where token = p_token;
    
    /*canal não existe ou token está duplicado*/
	if (v_count = 0 or v_count > 1) then 
		signal sqlstate '99999'
		set message_text = 'Token inválido';
    end if;    
	
	select concat(t.hour_ini, t.hour_fin) as turn
	  from (
		select (select replace(hour_ini, ':', '') as hour_ini
		          from machine_shift ms
				 inner join channel_machine cm on cm.channel_id = v_channel_id and cm.machine_code = ms.machine_code
				 where ms.machine_code = p_mc_cd 
				 order by ms.hour_ini 
				 limit 1) as hour_ini
			 , (select replace(hour_fin, ':', '') as hour_fin 
				  from machine_shift ms
				 inner join channel_machine cm on cm.channel_id = v_channel_id and cm.machine_code = ms.machine_code
				 where ms.machine_code = p_mc_cd
				 order by ms.hour_fin desc 
				 limit 1) as hour_fin
	) t ;  
END$$

DELIMITER ;