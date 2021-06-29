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

-- Dumping structure for table stc_report.gm_country_code_mapping
DROP TABLE IF EXISTS `gm_country_code_mapping`;
CREATE TABLE IF NOT EXISTS `gm_country_code_mapping` (
  `account` varchar(50) DEFAULT '0',
  `country_Code` int(11) DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Dumping data for table stc_report.gm_country_code_mapping: ~11 rows (approximately)
DELETE FROM `gm_country_code_mapping`;
/*!40000 ALTER TABLE `gm_country_code_mapping` DISABLE KEYS */;
INSERT INTO `gm_country_code_mapping` (`account`, `country_Code`) VALUES
	('GT MVNO', 2),
	('GLOBAL', 3),
	('Saudi Arabia', 7),
	('Netherlands', 5),
	('Australia', 4),
	('United Arab Emirates', 8),
	('Kuwait', 9),
	('Qatar', 10),
	('Koria', 6),
	('Globetouch', 1),
	('Bahrain', 11);
/*!40000 ALTER TABLE `gm_country_code_mapping` ENABLE KEYS */;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
