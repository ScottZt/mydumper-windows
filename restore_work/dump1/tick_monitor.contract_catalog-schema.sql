/*!40101 SET NAMES binary*/;
/*!40014 SET FOREIGN_KEY_CHECKS=0*/;
/*!40101 SET SQL_MODE='NO_AUTO_VALUE_ON_ZERO,ONLY_FULL_GROUP_BY,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION'*/;
/*!40103 SET TIME_ZONE='+00:00' */;
CREATE TABLE `contract_catalog` (
  `symbol` varchar(32) COLLATE utf8mb4_general_ci NOT NULL,
  `name` varchar(64) COLLATE utf8mb4_general_ci NOT NULL,
  `exchange` varchar(16) COLLATE utf8mb4_general_ci NOT NULL,
  `exchange_name` varchar(32) COLLATE utf8mb4_general_ci NOT NULL,
  `category` varchar(32) COLLATE utf8mb4_general_ci NOT NULL,
  `refreshed_at` datetime NOT NULL,
  PRIMARY KEY (`symbol`),
  KEY `ix_contract_catalog_refreshed_at` (`refreshed_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
