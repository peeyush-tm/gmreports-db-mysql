-- --------------------------------------------------------
-- Host:                         192.168.1.122
-- Server version:               10.1.12-MariaDB - MariaDB Server
-- Server OS:                    Linux
-- HeidiSQL Version:             9.3.0.4984
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

-- Dumping structure for table gm_reports.report_metadata
DROP TABLE IF EXISTS `report_metadata`;
CREATE TABLE IF NOT EXISTS `report_metadata` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `ICCID` varchar(20) DEFAULT NULL,
  `MSISDN` varchar(255) DEFAULT NULL,
  `IMSI` varchar(255) DEFAULT NULL,
  `MNO_ACCOUNTID` bigint(20) DEFAULT NULL,
  `ENT_ACCOUNTID` bigint(20) DEFAULT NULL,
  `RATE_PLAN_ID` bigint(20) DEFAULT NULL,
  `BILLING_CYCLE` bigint(3) DEFAULT NULL,
  `WHOLESALE_PLAN_ID` bigint(20) DEFAULT NULL,
  `SERVICE_PLAN_ID` bigint(20) DEFAULT '1',
  `ACCOUNT_NAME` varchar(1000) DEFAULT NULL,
  `RATE_PLAN_NAME` varchar(50) DEFAULT NULL,
  `WHOLE_SALE_NAME` varchar(50) DEFAULT NULL,
  `SERVICE_PLAN_NAME` varchar(255) DEFAULT NULL,
  `SIM_STATE` varchar(45) DEFAULT NULL,
  `ACTIVATION_DATE` varchar(45) DEFAULT NULL,
  `ACCOUNT_COUNTRIE` varchar(45) DEFAULT NULL,
  `BOOTSTRAP_ICCID` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`ID`),
  KEY `IMSI` (`IMSI`),
  KEY `ACCOUNT_COUNTRIE` (`ACCOUNT_COUNTRIE`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Data exporting was unselected.
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
