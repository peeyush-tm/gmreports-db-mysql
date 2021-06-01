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

-- Dumping structure for table stc_report.report_data_details
DROP TABLE IF EXISTS `report_data_details`;
CREATE TABLE IF NOT EXISTS `report_data_details` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `DATA_NODE` varchar(256) DEFAULT NULL,
  `REPORT_NODE` varchar(100) DEFAULT NULL,
  `DATA_PROCESSING_DATE` datetime NOT NULL,
  `IS_PROCESSED` tinyint(4) NOT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='contains details of data fetched from gcontrol and mediation database.';

-- Dumping data for table stc_report.report_data_details: ~11 rows (approximately)
DELETE FROM `report_data_details`;
/*!40000 ALTER TABLE `report_data_details` DISABLE KEYS */;
INSERT INTO `report_data_details` (`ID`, `DATA_NODE`, `REPORT_NODE`, `DATA_PROCESSING_DATE`, `IS_PROCESSED`) VALUES
	(1, 'cdr_sms_details', 'SMS(Delivered)', '2019-12-02 06:35:56', 1),
	(2, 'cdr_data_details', 'SMS(Undelivered)', '2019-12-02 06:35:56', 1),
	(3, 'pgw_svc_data', 'Data', '2021-01-10 07:36:31', 1),
	(4, 'cdr_voice_complete', 'Voice', '2021-01-10 07:55:24', 1),
	(5, 'cdr_voice_incomplete', 'Voice', '2021-01-10 07:55:12', 0),
	(6, 'cdr_voice_tadig_codes', 'Voice', '2019-12-02 06:51:10', 1),
	(7, 'metadata', 'metadata', '2021-01-10 06:48:18', 1),
	(8, 'apn_billing_cycle_aggregation', 'apn_billing_cycle_aggregation', '2019-11-25 11:52:26', 0),
	(9, 'retail_revenue_share', 'retail_revenue_share', '2020-05-28 06:35:56', 1),
	(10, 'retail_revenue_share', NULL, '2021-01-10 07:55:24', 0),
	(11, 'registration_failure', 'network', '2020-07-14 09:57:10', 1);
/*!40000 ALTER TABLE `report_data_details` ENABLE KEYS */;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
