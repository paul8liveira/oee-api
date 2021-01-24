USE `oee`;
DROP procedure IF EXISTS `prc_all_channel_oee`;

DELIMITER $$
USE `oee`$$
CREATE DEFINER=`root`@`%` PROCEDURE `prc_all_channel_oee`(
	in p_channel_id int(11),
    in p_date varchar(20)
)
BEGIN
	select cm.channel_id
         , d.machine_code
         , d.machine_name
		 , round(d.availability, 2) as availability
		 , round(d.performance, 2) as performance
		 , round(d.quality, 2) as quality
		 , round(d.oee, 2) as oee
	  from channel_machine cm
	 inner join daily_oee d on d.machine_code = cm.machine_code
	 where cm.channel_id = p_channel_id
	   and year = year(str_to_date(p_date, '%Y-%m-%d %H:%i:%s'))
	   and month = month(str_to_date(p_date, '%Y-%m-%d %H:%i:%s'))
	   and day = day(str_to_date(p_date, '%Y-%m-%d %H:%i:%s'));
END$$

DELIMITER ;

