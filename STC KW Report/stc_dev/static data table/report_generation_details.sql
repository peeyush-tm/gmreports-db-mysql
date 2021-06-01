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

-- Dumping structure for table stc_report.report_generation_details
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
  CONSTRAINT `fk_reports` FOREIGN KEY (`REPORT_ID`) REFERENCES `reports` (`ID`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='contains genration details of every reports in reports table.';

-- Dumping data for table stc_report.report_generation_details: ~8 rows (approximately)
DELETE FROM `report_generation_details`;
/*!40000 ALTER TABLE `report_generation_details` DISABLE KEYS */;
INSERT INTO `report_generation_details` (`id`, `REPORT_ID`, `START_DATE`, `END_DATE`, `LAST_EXECUTION_TIME`, `REPORT_FILE_PATH`) VALUES
	(1, 1, '2019-09-10 00:00:00', '2022-10-31 00:00:00', '2021-01-09', '/opt/gmreports-etl-java-0.3.0.0/Client/GMReports_Client//basic_reports/Gcontrol_20210109_DailySMS_11_1610265293735.csv'),
	(2, 2, '2019-08-10 00:00:00', '2022-10-30 00:00:00', '2021-01-09', '/opt/gmreports-etl-java-0.3.0.0/Client/GMReports_Client//basic_reports/Gcontrol_20210109_DailyUndelSMS_11_1610265300548.csv'),
	(3, 3, '2019-08-10 00:00:00', '2022-10-31 00:00:00', '2021-01-09', '/opt/gmreports-etl-java-0.3.0.0/Client/GMReports_Client//basic_reports/Gcontrol_20210109_DailyData_11_1610265212772.csv'),
	(4, 4, '2019-08-10 00:00:00', '2022-10-31 00:00:00', '2021-01-09', '/opt/gmreports-etl-java-0.3.0.0/Client/GMReports_Client//basic_reports/Gcontrol_20210109_DailyVoice_11_1610265331061.csv'),
	(5, 5, '2019-08-10 00:00:00', '2022-10-31 00:00:00', '2021-01-09', '/opt/gmreports-etl-java-0.3.0.0/Client/GMReports_Client//basic_reports/Gcontrol_20210109_MobileNumberRec_11_1610265301113.csv'),
	(6, 6, '2019-08-10 00:00:00', '2022-10-31 00:00:00', '2021-01-04', 'globetocuh/apn_billing_cycle/report'),
	(7, 7, '2019-06-29 00:00:00', '2022-10-31 00:00:00', '2021-01-04', '/opt/stc_report_72_38_server/GMReports_Client//basic_reports/Gcontrol_20201106_RetailRevShare_5_1604643973790.csv'),
	(8, 8, '2019-06-29 00:00:00', '2022-10-31 00:00:00', '2021-01-04', 'E:\\palak_project\\GMReports_Client\\/reports_test\\Gcontrol_20200703_network_registration_failure_2_1593779123736.csv');
/*!40000 ALTER TABLE `report_generation_details` ENABLE KEYS */;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
