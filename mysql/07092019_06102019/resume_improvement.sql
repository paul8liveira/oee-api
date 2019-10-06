CREATE TABLE `resume_improvement` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `channel_id` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `overview` mediumtext,
  `action` mediumtext,
  `owner` varchar(45) DEFAULT NULL,
  `status` int(1) DEFAULT NULL,
  `resume_date` date NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_resume_channel` (`channel_id`),
  CONSTRAINT `fk_resume_channel` FOREIGN KEY (`channel_id`) REFERENCES `channel` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=latin1;
