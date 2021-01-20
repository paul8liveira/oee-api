USE `oee`;
DROP function IF EXISTS `fnc_machine_pause`;

DELIMITER $$
USE `oee`$$
CREATE DEFINER=`root`@`%` FUNCTION `fnc_machine_pause`(
	p_channel_id int,
    p_machine_code varchar(10),
    p_date_ini varchar(20),
    p_date_fin varchar(20),
    p_pause_type char(2)
) RETURNS int(11)
    DETERMINISTIC
begin
	declare v_pause int;
    set v_pause = 0;
    select sum(a.pause) as pause
      into v_pause
	  from (
		select mpd.pause 
		  from channel c
		 inner join channel_machine cm on cm.channel_id = c.id
		  left join machine_pause_dash mpd on mpd.channel_id = c.id and mpd.machine_code = cm.machine_code
		  left join pause_reason pr on pr.id = mpd.pause_reason_id
		 where c.id = p_channel_id
		   and cm.machine_code = p_machine_code
		   and mpd.date_ref between 
				   (str_to_date(p_date_ini, '%Y-%m-%d %H:%i:%s')) 
			   and (str_to_date(p_date_fin, '%Y-%m-%d %H:%i:%s'))
           and ((pr.type = p_pause_type) or p_pause_type = '')  
		 group by mpd.insert_index
	) a;
	return coalesce(v_pause, 0);
end$$

DELIMITER ;

