alter table feed_config add column chart_product_sql text null;
alter table machine_config add column chart_product_sql text null;

USE `oee`;
DROP procedure IF EXISTS `prc_chart`;

DELIMITER $$
USE `oee`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `prc_chart`(
	in p_date_ini varchar(20),
    in p_date_fin varchar(20),
    in p_ch_id int(11),
    in p_mc_cd varchar(10),
    in p_chart_type int(1)
)
BEGIN
	SET @chart_sql = coalesce(
		(select case p_chart_type 
					when 0 then chart_sql 
                    else chart_product_sql 
				end
           from machine_config 
		  where machine_code = p_mc_cd),
		(select case p_chart_type 
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



CREATE TABLE `machine_product_dash` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `channel_id` int(11) NOT NULL,
  `machine_code` varchar(10) CHARACTER SET latin1 NOT NULL,
  `date_ref` datetime NOT NULL,
  `product_id` int(11) NOT NULL,
  `inserted_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `amount` float(15,2) DEFAULT NULL,
  `insert_index` int(11) DEFAULT NULL,
  `date_ref_year` int(11) GENERATED ALWAYS AS (year(`date_ref`)) VIRTUAL NOT NULL,
  `date_ref_month` int(11) GENERATED ALWAYS AS (month(`date_ref`)) VIRTUAL NOT NULL,
  `date_ref_day` int(11) GENERATED ALWAYS AS (dayofmonth(`date_ref`)) VIRTUAL NOT NULL,
  PRIMARY KEY (`id`),
  KEY `code_idx` (`machine_code`),
  KEY `fk_machine_product_dash_product` (`product_id`),
  KEY `idx_channel_machine_date_ref_insert_index_pause` (`channel_id`,`machine_code`,`date_ref`,`insert_index`,`amount`),
  CONSTRAINT `fk_machine_product_dash_channel` FOREIGN KEY (`channel_id`) REFERENCES `channel` (`id`),
  CONSTRAINT `fk_machine_product_dash_machine` FOREIGN KEY (`machine_code`) REFERENCES `machine_data` (`code`),
  CONSTRAINT `fk_machine_product_dash_product` FOREIGN KEY (`product_id`) REFERENCES `product` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


update feed_config set chart_product_sql = '
select f.inserted_at as labels  
	 , f.field3 as data    
	 , coalesce((select chart_tooltip_desc from machine_config where machine_code = f.mc_cd), chart_tooltip_desc, \'\') as chart_tooltip_desc
	 , case when mpd.date_ref is null then \'#A8CF45\' else \'#0990F3\' end as line_color
     , pr.name as product_name
     , mpd.amount
  from feed f
 inner join channel c on c.id = f.ch_id
 inner join machine_data md on md.code = f.mc_cd
 inner join feed_config fc on fc.channel_id = c.id
  left join machine_product_dash mpd on mpd.channel_id = f.ch_id and mpd.machine_code = f.mc_cd and mpd.date_ref = f.inserted_at
  left join product pr on pr.id = mpd.product_id    
 where f.inserted_at between \'__date_ini\' and \'__date_fin\'
   and ch_id = __ch_id
   and mc_cd = \'__mc_cd\'
 order by f.inserted_at'
 where channel_id = 14 ;