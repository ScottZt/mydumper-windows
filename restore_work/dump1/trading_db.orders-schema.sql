/*!40101 SET NAMES binary*/;
/*!40014 SET FOREIGN_KEY_CHECKS=0*/;
/*!40101 SET SQL_MODE='NO_AUTO_VALUE_ON_ZERO,ONLY_FULL_GROUP_BY,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION'*/;
/*!40103 SET TIME_ZONE='+00:00' */;
CREATE TABLE `orders` (
  `id` char(32) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` datetime NOT NULL DEFAULT (now()),
  `updated_at` datetime NOT NULL DEFAULT (now()),
  `account_id` char(32) COLLATE utf8mb4_unicode_ci NOT NULL,
  `client_order_id` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `exchange_order_id` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `symbol` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `side` enum('BUY','SELL') COLLATE utf8mb4_unicode_ci NOT NULL,
  `type` enum('LIMIT','MARKET','STOP') COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` enum('NEW','PARTIALLY_FILLED','FILLED','CANCELED','REJECTED','EXPIRED') COLLATE utf8mb4_unicode_ci NOT NULL,
  `price` decimal(20,8) DEFAULT NULL,
  `quantity` decimal(20,8) NOT NULL,
  `filled_quantity` decimal(20,8) NOT NULL,
  `average_fill_price` decimal(20,8) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ix_orders_client_order_id` (`client_order_id`),
  KEY `account_id` (`account_id`),
  KEY `ix_orders_exchange_order_id` (`exchange_order_id`),
  KEY `ix_orders_status` (`status`),
  KEY `ix_orders_symbol` (`symbol`),
  CONSTRAINT `orders_ibfk_1` FOREIGN KEY (`account_id`) REFERENCES `accounts` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
