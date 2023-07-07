CREATE DATABASE  IF NOT EXISTS `tv_channels` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `tv_channels`;
-- MySQL dump 10.13  Distrib 8.0.19, for Win64 (x86_64)
--
-- Host: localhost    Database: tv_channels
-- ------------------------------------------------------
-- Server version	8.0.19

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `channel_programs`
--

DROP TABLE IF EXISTS `channel_programs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `channel_programs` (
  `channel id` int NOT NULL AUTO_INCREMENT,
  `channel name` varchar(100) NOT NULL,
  `channel freq` bigint DEFAULT NULL,
  `program name` varchar(145) DEFAULT NULL,
  `start/end time` varchar(45) DEFAULT NULL,
  `program crew` varchar(1000) DEFAULT NULL,
  PRIMARY KEY (`channel id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `channel_programs`
--

LOCK TABLES `channel_programs` WRITE;
/*!40000 ALTER TABLE `channel_programs` DISABLE KEYS */;
INSERT INTO `channel_programs` VALUES (1,'CTV',120050,'NEWS','12:20-14:30','Sam, Jim, Mark'),(2,'CTV',120050,'With Guest','14:30-15:30','Sam, Jane'),(3,'CTV',120050,'Special Interview','16:00-17:30','Jim, Sam'),(4,'KTV',115000,'Kids Toon','10:10-10:50','Saly, Suzy'),(5,'KTV',115000,'With Kids','11:00-12:00','Clie, Doe'),(6,'KTV',115000,'Kiddy','12:10-13:30','Saly'),(7,'S Channel',135040,'Teen Sports','10:00-11:10','Jack, Ray'),(8,'S Channel',135040,'Boxing','11:30-12:40','Jack, Peter');
/*!40000 ALTER TABLE `channel_programs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping events for database 'tv_channels'
--

--
-- Dumping routines for database 'tv_channels'
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2023-06-29 11:03:15

CREATE TABLE `channel` (
  `channel id` int NOT NULL AUTO_INCREMENT,
  `channel name` varchar(100) NOT NULL,
  `channel freq` bigint DEFAULT NULL,
  PRIMARY KEY (`channel id`)
);

CREATE TABLE `programs` (
  `program name` varchar(145) DEFAULT NULL,
  `start/end time` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`program name`),
  FOREIGN KEY (`channel id`) REFERENCES `channel`(`channel id`)
);

CREATE TABLE `crew` (
  `program crew` varchar(1000) DEFAULT NULL,
  PRIMARY KEY (`program crew`),
  FOREIGN KEY (`program name`) REFERENCES `programs`(`program name` )
);

-- ADDING CREW COUNT

INSERT INTO `programs`
SELECT COUNT(`program crew`) AS `crew count` 
FROM `crew` 
GROUP BY `program name`;

-- -------------

INSERT INTO `channel` (`channel id`, `channel name`, `channel freq`)
SELECT DISTINCT `channel id`, `channel name`, `channel freq`
FROM `channel_programs`;

INSERT INTO `programs` (`program name`, `start/end time`)
SELECT DISTINCT `program name`, `start/end time`
FROM `channel_programs`;

INSERT INTO `crew` (`program crew`)
SELECT DISTINCT `program crew`
FROM `channel_programs`;



-- VIEW
CREATE VIEW program_view AS SELECT c.`channel name`, p.`program name`, p.`start/end time`, 
TIMESTAMPDIFF(MINUTE, 
              TIME(SUBSTRING_INDEX(`start/end time`, '/', 1)), 
              TIME(SUBSTRING_INDEX(`start/end time`, '/', -1))) as `duration`
              FROM `channel` c 
JOIN `program` p ON c.`channel id` = p.`channel id`; 

-- TRIGGERS


CREATE TRIGGER update_crew_count_insert AFTER INSERT ON `crew`
FOR EACH ROW 
BEGIN UPDATE `programs` SET `crew count` = `crew count` + 1 
WHERE program_id = NEW.program_id
END;

CREATE TRIGGER update_crew_count_delete AFTER DELETE ON `crew`
FOR EACH ROW 
BEGIN UPDATE `programs` SET `crew count` = `crew count` - 1 
WHERE program_id = OLD.program_id
END;