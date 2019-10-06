CREATE TABLE `progress_improvement` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `channel_id` int(11) NOT NULL,
  `gain` varchar(20) NOT NULL,
  `pause_reason_id` int(11) NOT NULL,
  `description` varchar(100) NOT NULL,
  `action_description` mediumtext NOT NULL,
  `owner` varchar(45) DEFAULT NULL,
  `status` int(1) DEFAULT NULL,
  `starts_at` date DEFAULT NULL,
  `finished_at` date DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `fk_progress_channel` (`channel_id`),
  KEY `fk_progress_pause` (`pause_reason_id`),
  CONSTRAINT `fk_progress_channel` FOREIGN KEY (`channel_id`) REFERENCES `channel` (`id`),
  CONSTRAINT `fk_progress_pause` FOREIGN KEY (`pause_reason_id`) REFERENCES `pause_reason` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=latin1;
