DROP DATABASE IF EXISTS `rick_and-morty_development`;

CREATE DATABASE `rick_and-morty_development`;

USE `rick_and-morty_development`;

CREATE TABLE `travel_plans` (
  `id` int NOT NULL AUTO_INCREMENT,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `travel_legs` (
  `id` int NOT NULL AUTO_INCREMENT,
  `travel_plan_id` int NOT NULL,
  `travel_stop_id` int NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_cr_0fc4d3e9f4` (`travel_plan_id`),
  CONSTRAINT `fk_cr_0fc4d3e9f4` FOREIGN KEY (`travel_plan_id`) REFERENCES `travel_plans` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;