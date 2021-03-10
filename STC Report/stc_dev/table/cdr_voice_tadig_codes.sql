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

-- Dumping structure for table stc_report.cdr_voice_tadig_codes
DROP TABLE IF EXISTS `cdr_voice_tadig_codes`;
CREATE TABLE IF NOT EXISTS `cdr_voice_tadig_codes` (
  `TC_TADIG_CODE` varchar(256) CHARACTER SET utf8 NOT NULL,
  `TC_NETWORK_ID` bigint(20) NOT NULL,
  `TC_MCC` varchar(256) CHARACTER SET utf8 DEFAULT '0',
  `TC_MNC` varchar(256) CHARACTER SET utf8 DEFAULT '0',
  `TC_REC_CHANGED_AT` datetime DEFAULT NULL,
  `TC_REC_CHANGED_BY` varchar(256) CHARACTER SET utf8 NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Data exporting was unselected.

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
