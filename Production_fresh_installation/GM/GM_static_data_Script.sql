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

-- Dumping structure for table reports
DROP TABLE IF EXISTS `reports`;
CREATE TABLE IF NOT EXISTS `reports` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `NAME` varchar(256) NOT NULL DEFAULT '0' COMMENT 'reports names',
  `INTERVAL_VALUE` int(11) NOT NULL DEFAULT '0' COMMENT 'Frequency  value ',
  `INTERVAL_UNIT` varchar(50) NOT NULL DEFAULT '0' COMMENT 'Frequency  type',
  `REMARKS` varchar(256) NOT NULL DEFAULT '0' COMMENT 'description',
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='contains details about the reports';

-- Dumping data for table reports: ~7 rows (approximately)
/*!40000 ALTER TABLE `reports` DISABLE KEYS */;
INSERT INTO `reports` (`ID`, `NAME`, `INTERVAL_VALUE`, `INTERVAL_UNIT`, `REMARKS`) VALUES
  (1, 'SMS(Delivered)', 1, 'Daily', 'gm_sms_delivered_report'),
  (2, 'SMS(Undelivered)', 1, 'Daily', 'gm_sms_undelivered_report'),
  (3, 'Data', 1, 'Daily', 'gm_voice_report'),
  (4, 'Voice', 1, 'Daily', 'gm_data_report'),
  (5, 'mobile_number_reconciliation', 1, 'Daily', 'gm_mobile_number_reconciliation_report'),
  (6, 'gm_apn_billing_cycle_report', 1, 'Monthly', 'gm_apn_billing_cycle_report'),
  (7, 'OTA', 0, '0', '0');
/*!40000 ALTER TABLE `reports` ENABLE KEYS */;

-- Dumping structure for table report_data_details
DROP TABLE IF EXISTS `report_data_details`;
CREATE TABLE IF NOT EXISTS `report_data_details` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `DATA_NODE` varchar(256) DEFAULT NULL,
  `REPORT_NODE` varchar(100) DEFAULT NULL,
  `DATA_PROCESSING_DATE` datetime NOT NULL,
  `IS_PROCESSED` tinyint(4) NOT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='contains details of data fetched from gcontrol and mediation database.';

-- Dumping data for table report_data_details: ~10 rows (approximately)
/*!40000 ALTER TABLE `report_data_details` DISABLE KEYS */;
INSERT INTO `report_data_details` (`ID`, `DATA_NODE`, `REPORT_NODE`, `DATA_PROCESSING_DATE`, `IS_PROCESSED`) VALUES
  (1, 'cdr_sms_details', 'SMS(Delivered)', '2019-12-02 06:35:56', 1),
  (2, 'cdr_data_details', 'SMS(Undelivered)', '2019-12-02 06:35:56', 1),
  (3, 'pgw_svc_data', 'Data', '2019-12-02 06:36:32', 1),
  (4, 'cdr_voice_complete', 'Voice', '2019-12-02 06:54:15', 1),
  (5, 'cdr_voice_incomplete', 'Voice', '2019-12-02 06:47:17', 1),
  (6, 'cdr_voice_tadig_codes', 'Voice', '2019-12-02 06:51:10', 1),
  (7, 'metadata', 'metadata', '2019-11-25 11:52:26', 1),
  (8, 'apn_billing_cycle_aggregation', 'apn_billing_cycle_aggregation', '2019-11-25 11:52:26', 0),
  (9, 'OTA', 'metadata', '0000-00-00 00:00:00', 0),
  (10, 'retail_revenue_share', NULL, '0000-00-00 00:00:00', 0);
/*!40000 ALTER TABLE `report_data_details` ENABLE KEYS */;

-- Dumping structure for table report_generation_details
DROP TABLE IF EXISTS `report_generation_details`;
CREATE TABLE IF NOT EXISTS `report_generation_details` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `REPORT_ID` int(11) NOT NULL DEFAULT '0',
  `START_DATE` datetime DEFAULT NULL,
  `END_DATE` datetime DEFAULT NULL,
  `LAST_EXECUTION_TIME` date DEFAULT NULL,
  `REPORT_FILE_PATH` text,
  PRIMARY KEY (`id`),
  KEY `fk_reports` (`REPORT_ID`),
  CONSTRAINT `fk_reports` FOREIGN KEY (`report_id`) REFERENCES `reports` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='contains genration details of every reports in reports table.';

-- Dumping data for table report_generation_details: ~7 rows (approximately)
/*!40000 ALTER TABLE `report_generation_details` DISABLE KEYS */;
INSERT INTO `report_generation_details` (`id`, `REPORT_ID`, `START_DATE`, `END_DATE`, `LAST_EXECUTION_TIME`, `REPORT_FILE_PATH`) VALUES
  (1, 1, '2019-09-10 00:00:00', '2019-10-31 00:00:00', '2019-11-04', 'globetocuh/report'),
  (2, 2, '2019-08-10 00:00:00', '2019-10-30 00:00:00', '2019-11-29', '/home/palaktiwari/GMReports_Client//basic_reports/smsUndeliveredCdr20191129030018.csv'),
  (3, 3, '2019-08-10 00:00:00', '2019-10-31 00:00:00', '2019-11-01', '/home/palaktiwari/GMReports_Client//basic_reports/dataCdr20191202062118.csv'),
  (4, 4, '2019-08-10 00:00:00', '2019-10-31 00:00:00', '2019-10-31', 'GLOBETOCH/VOICE/REPORT'),
  (5, 5, '2019-08-10 00:00:00', '2019-10-31 00:00:00', '2019-11-01', 'globetocuh/report'),
  (6, 6, '2019-08-10 00:00:00', '2019-10-31 00:00:00', '2019-11-01', 'globetocuh/apn_billing_cycle/report'),
  (7, 7, '2019-10-01 00:00:00', '2019-10-31 00:00:00', '2019-10-31', 'globetocuh/report');
/*!40000 ALTER TABLE `report_generation_details` ENABLE KEYS */;

-- Dumping structure for table report_mapping
DROP TABLE IF EXISTS `report_mapping`;
CREATE TABLE IF NOT EXISTS `report_mapping` (
  `REPORT_ID` int(11) DEFAULT NULL,
  `NODE_ID` int(11) DEFAULT NULL,
  KEY `REPORT_ID` (`REPORT_ID`),
  KEY `NODE_ID` (`NODE_ID`),
  CONSTRAINT `NODE_ID` FOREIGN KEY (`NODE_ID`) REFERENCES `report_data_details` (`ID`),
  CONSTRAINT `REPORT_ID` FOREIGN KEY (`REPORT_ID`) REFERENCES `reports` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='this table is used to generate the mapping between reports and respective tables  ';

-- Dumping data for table report_mapping: ~11 rows (approximately)
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
  (7, 9);
/*!40000 ALTER TABLE `report_mapping` ENABLE KEYS */;



-- Dumping structure for table gm_reports.gm_country_code_mapping
DROP TABLE IF EXISTS `gm_country_code_mapping`;
CREATE TABLE IF NOT EXISTS `gm_country_code_mapping` (
  `account` varchar(50) DEFAULT '0',
  `country_Code` int(11) DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Dumping data for table gm_reports.gm_country_code_mapping: ~11 rows (approximately)
DELETE FROM `gm_country_code_mapping`;
/*!40000 ALTER TABLE `gm_country_code_mapping` DISABLE KEYS */;
INSERT INTO `gm_country_code_mapping` (`account`, `country_Code`) VALUES
  ('GT MVNO', 2),
  ('GLOBAL', 3),
  ('Saudi Arabia', 7),
  ('Netherlands', 5),
  ('Australia', 4),
  ('United Arab Emirates', 8),
  ('KUWAIT', 9),
  ('Qatar', 10),
  ('Koria', 6),
  ('Globetouch', 1),
  ('Bahrain', 11);


/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
