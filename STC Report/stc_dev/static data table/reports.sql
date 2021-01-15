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

-- Dumping structure for table stc_report.reports
DROP TABLE IF EXISTS `reports`;
CREATE TABLE IF NOT EXISTS `reports` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `NAME` varchar(256) NOT NULL DEFAULT '0' COMMENT 'reports names',
  `INTERVAL_VALUE` int(11) NOT NULL DEFAULT '0' COMMENT 'Frequency  value ',
  `INTERVAL_UNIT` varchar(50) NOT NULL DEFAULT '0' COMMENT 'Frequency  type',
  `REMARKS` varchar(256) NOT NULL DEFAULT '0' COMMENT 'description',
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='contains details about the reports';

-- Dumping data for table stc_report.reports: ~8 rows (approximately)
DELETE FROM `reports`;
/*!40000 ALTER TABLE `reports` DISABLE KEYS */;
INSERT INTO `reports` (`ID`, `NAME`, `INTERVAL_VALUE`, `INTERVAL_UNIT`, `REMARKS`) VALUES
	(1, 'SMS(Delivered)', 1, 'Daily', 'gm_sms_delivered_report'),
	(2, 'SMS(Undelivered)', 1, 'Daily', 'gm_sms_undelivered_report'),
	(3, 'Data', 1, 'Daily', 'gm_voice_report'),
	(4, 'Voice', 1, 'Daily', 'gm_data_report'),
	(5, 'mobile_number_reconciliation', 1, 'Daily', 'gm_mobile_number_reconciliation_report'),
	(6, 'gm_apn_billing_cycle_report', 1, 'Monthly', 'gm_apn_billing_cycle_report'),
	(7, 'gm_retail_revenue_share_report', 1, 'Monthly', 'gm_retail_revenue_share_report'),
	(8, 'gm_mobile_network_registration_failure_daily_report', 1, 'Daily', 'gm_mobile_network_registration_failure_daily_report');
/*!40000 ALTER TABLE `reports` ENABLE KEYS */;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
