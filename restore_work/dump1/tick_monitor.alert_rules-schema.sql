/*!40101 SET NAMES binary*/;
/*!40014 SET FOREIGN_KEY_CHECKS=0*/;
/*!40101 SET SQL_MODE='NO_AUTO_VALUE_ON_ZERO,ONLY_FULL_GROUP_BY,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION'*/;
/*!40103 SET TIME_ZONE='+00:00' */;
CREATE TABLE `alert_rules` (
  `id` int NOT NULL AUTO_INCREMENT,
  `contract` varchar(32) COLLATE utf8mb4_general_ci NOT NULL,
  `condition` varchar(256) COLLATE utf8mb4_general_ci NOT NULL,
  `alert_type` varchar(32) COLLATE utf8mb4_general_ci NOT NULL,
  `message` varchar(512) COLLATE utf8mb4_general_ci NOT NULL,
  `enabled` tinyint(1) NOT NULL,
  `created_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `ix_alert_rules_contract` (`contract`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
