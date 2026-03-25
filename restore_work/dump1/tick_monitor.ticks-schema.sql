/*!40101 SET NAMES binary*/;
/*!40014 SET FOREIGN_KEY_CHECKS=0*/;
/*!40101 SET SQL_MODE='NO_AUTO_VALUE_ON_ZERO,ONLY_FULL_GROUP_BY,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION'*/;
/*!40103 SET TIME_ZONE='+00:00' */;
CREATE TABLE `ticks` (
  `id` int NOT NULL AUTO_INCREMENT,
  `contract` varchar(32) COLLATE utf8mb4_general_ci NOT NULL,
  `timestamp` datetime NOT NULL,
  `price` float NOT NULL,
  `volume` int NOT NULL,
  `open_interest` int NOT NULL,
  PRIMARY KEY (`id`),
  KEY `ix_ticks_timestamp` (`timestamp`),
  KEY `ix_ticks_contract` (`contract`)
) ENGINE=InnoDB AUTO_INCREMENT=555427 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
