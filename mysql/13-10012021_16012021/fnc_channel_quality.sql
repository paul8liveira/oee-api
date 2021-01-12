USE `oee`;
DROP function IF EXISTS `fnc_channel_quality`;

DELIMITER $$
USE `oee`$$
CREATE FUNCTION `fnc_channel_quality` (p_channel_id int)
RETURNS INTEGER
BEGIN
	set @v_quality = (select quality from channel where id = p_channel_id);
	RETURN @v_quality;
END$$

DELIMITER ;

