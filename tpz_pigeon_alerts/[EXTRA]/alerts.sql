

-- Dumping structure for table tp_alerts
CREATE TABLE IF NOT EXISTS `alerts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `identifier` varchar(50) CHARACTER SET utf16 COLLATE utf16_unicode_ci DEFAULT NULL,
  `charidentifier` int(11) DEFAULT NULL,
  `username` varchar(50) CHARACTER SET utf16 COLLATE utf16_unicode_ci DEFAULT NULL,
  `alerted_job` varchar(50) CHARACTER SET utf16 COLLATE utf16_unicode_ci DEFAULT NULL,
  `message` longtext CHARACTER SET utf16 COLLATE utf16_unicode_ci DEFAULT NULL,
  `date` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=191 DEFAULT CHARSET=latin1 ROW_FORMAT=DYNAMIC;
