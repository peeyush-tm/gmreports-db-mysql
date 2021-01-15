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

-- Dumping structure for table stc_report.retail_revenue_share
DROP TABLE IF EXISTS `retail_revenue_share`;
CREATE TABLE IF NOT EXISTS `retail_revenue_share` (
  `ID` bigint(50) NOT NULL AUTO_INCREMENT,
  `START_DATE` varchar(50) DEFAULT NULL,
  `DATA_USED` varchar(50) DEFAULT NULL,
  `CREDIT_AMOUNT` varchar(50) DEFAULT NULL,
  `PACKAGE_CODE` varchar(50) DEFAULT NULL,
  `ORDER_ID` varchar(50) DEFAULT NULL,
  `UUID_IMSI` varchar(50) DEFAULT NULL,
  `IMSI` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='reatails revenue table store the data from the BSS API''s';

-- Data exporting was unselected.

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
