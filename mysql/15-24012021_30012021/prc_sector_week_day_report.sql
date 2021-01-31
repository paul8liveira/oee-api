USE `oee`;
DROP procedure IF EXISTS `prc_sector_week_day_report`;

DELIMITER $$
USE `oee`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `prc_sector_week_day_report`(
	IN p_channel_id int,
	IN p_sector_id int,
    IN p_year_number char(4),
    IN p_week_number char(2),
    IN p_date varchar(20)
)
BEGIN
	set @v_date = STR_TO_DATE(p_date, '%Y-%m-%d %H:%i:%s');
    
	-- consultas por semana e ano, fazem a media diretamente da tabela daily_oee
	if(p_week_number <> '' and p_year_number <> '') then
		select channel_id
			 , machine_code
			 , machine_name
			 , round(sum(production), 2) as amount
			 , round(avg(availability), 2) as availability
			 , round(avg(performance), 2) as performance
			 , round(avg(quality), 2) as quality
			 , round(avg(oee), 2) as oee 
		  from (
			select oee.*
				 , weekday(str_to_date(concat(oee.year, '-' , oee.month, '-' , oee.day), '%Y-%m-%d')) as weekday
			  from daily_oee oee
			  join machine_data m on m.code = oee.machine_code
			 where oee.channel_id = p_channel_id
			   and m.sector_id = p_sector_id
			   and oee.year = p_year_number
			   and oee.week = p_week_number
		) t
		where weekday not in (5,6)
		group by machine_code, week; 
	else     
		select oee.channel_id
             , oee.machine_code
             , oee.machine_name
             , oee.production
             , round(oee.availability, 2) as availability
             , round(oee.performance, 2) as performance
             , round(oee.quality, 2) as quality
             , round(oee.oee, 2) as oee
		  from daily_oee oee
		  join machine_data m on m.code = oee.machine_code
		 where oee.channel_id = p_channel_id
		   and m.sector_id = p_sector_id
		   and oee.year = year(@v_date)
		   and oee.month = month(@v_date)
		   and oee.day = day(@v_date);		
	end if; 
END$$

DELIMITER ;

