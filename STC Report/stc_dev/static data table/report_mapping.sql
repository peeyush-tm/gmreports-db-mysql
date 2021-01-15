-- --------------------------------------------------------
-- Host:                         192.168.1.231
-- Server version:               5.7.27 - MySQL Community Server (GPL)
-- Server OS:                    linux-glibc2.12
-- HeidiSQL Version:             11.0.0.5919
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

-- Dumping structure for table stc_report.report_mapping
DROP TABLE IF EXISTS `report_mapping`;
CREATE TABLE IF NOT EXISTS `report_mapping` (
  `REPORT_ID` int(11) DEFAULT NULL,
  `NODE_ID` int(11) DEFAULT NULL,
  KEY `REPORT_ID` (`REPORT_ID`),
  KEY `NODE_ID` (`NODE_ID`),
  CONSTRAINT `NODE_ID` FOREIGN KEY (`NODE_ID`) REFERENCES `report_data_details` (`ID`),
  CONSTRAINT `REPORT_ID` FOREIGN KEY (`REPORT_ID`) REFERENCES `reports` (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='this table is used to generate the mapping between reports and respective tables  ';

-- Dumping data for table stc_report.report_mapping: ~12 rows (approximately)
DELETE FROM `report_mapping`;
/*!40000 ALTER TABLE `report_mapping` DISABLE KEYS */;
INSERT INTO `report_mapping` (`REPORT_ID`, `NODE_ID`) VALUES
	(1, 1),
	(2, 1),
	(3, 3),
	(3, 6),
	(4, 4),
	(4, 5),
	(4, 6),
	(5, 7),
	(6, 3),
	(6, 2),
	(8, 11),
	(7, 9);
/*!40000 ALTER TABLE `report_mapping` ENABLE KEYS */;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
