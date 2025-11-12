CREATE TABLE IF NOT EXISTS `user_jobs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `identifier` varchar(60) NOT NULL,
  `job` varchar(50) NOT NULL,
  `grade` int(11) NOT NULL DEFAULT 0,
  `removeable` tinyint(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (`id`),
  KEY `identifier` (`identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;