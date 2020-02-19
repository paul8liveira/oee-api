alter table feed_config add column chart_product_sql text null;
alter table machine_config add column chart_product_sql text null;

USE `oee`;
DROP procedure IF EXISTS `prc_chart`;

DELIMITER $$
USE `oee`$$
CREATE PROCEDURE `prc_chart`(
	in p_date_ini varchar(20),
    in p_date_fin varchar(20),
    in p_ch_id int(11),
    in p_mc_cd varchar(10),
    in chart_type int(1)
)
BEGIN
	SET @chart_sql = coalesce(
		(select case chart_type 
					when 0 then chart_sql 
                    else chart_product_sql 
				end
           from machine_config 
		  where machine_code = p_mc_cd),
		(select case chart_type 
					when 0 then chart_sql 
                    else chart_product_sql 
				end
		   from feed_config 
		  where channel_id = p_ch_id)
	);
	
    SET @chart_sql = REPLACE(@chart_sql, '__date_ini', p_date_ini);
    SET @chart_sql = REPLACE(@chart_sql, '__date_fin', p_date_fin);
    SET @chart_sql = REPLACE(@chart_sql, '__ch_id', p_ch_id);
    SET @chart_sql = REPLACE(@chart_sql, '__mc_cd', p_mc_cd);
    
    PREPARE stmt FROM @chart_sql;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;
END$$

DELIMITER ;

