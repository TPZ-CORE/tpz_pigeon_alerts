
-- Dumping structure for table tp_personal_pigeons
CREATE TABLE IF NOT EXISTS `pigeons` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `identifier` varchar(50) CHARACTER SET utf16 COLLATE utf16_unicode_ci DEFAULT NULL,
  `charidentifier` int(11) DEFAULT NULL,
  `hasPigeon` int(11) DEFAULT 0,
  `hunger` int(11) DEFAULT 100,
  `dead` int(11) DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1 ROW_FORMAT=DYNAMIC;

