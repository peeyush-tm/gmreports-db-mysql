-- --------------------------------------------------------
-- Host:                         192.168.1.122
-- Server version:               10.1.12-MariaDB - MariaDB Server
-- Server OS:                    Linux
-- HeidiSQL Version:             10.2.0.5599
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

-- Dumping structure for table cdr_sms_details
DROP TABLE IF EXISTS `cdr_sms_details`;
CREATE TABLE IF NOT EXISTS `cdr_sms_details` (
  `ID` bigint(20) NOT NULL AUTO_INCREMENT,
  `SMS_TYPE` varchar(256) DEFAULT NULL,
  `SOURCE` varchar(256) DEFAULT NULL,
  `DESTINATION` varchar(256) DEFAULT NULL,
  `SENT_TIME` datetime DEFAULT NULL,
  `FINAL_TIME` datetime DEFAULT NULL,
  `SMS_STATUS` varchar(256) DEFAULT NULL,
  `ATTEMPTS` bigint(20) DEFAULT NULL,
  `REASON` varchar(256) DEFAULT NULL,
  `ORIGINATION_GT` varchar(256) DEFAULT NULL,
  `DESTINATION_GT` varchar(256) DEFAULT NULL,
  `SUBSCRIBER_IMSI` varchar(256) DEFAULT NULL,
  PRIMARY KEY (`ID`),
  KEY `SOURCE` (`SOURCE`(255)),
  KEY `DESTINATION` (`DESTINATION`(255)),
  KEY `ID` (`ID`),
  KEY `FINAL_TIME` (`FINAL_TIME`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Data exporting was unselected.

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
