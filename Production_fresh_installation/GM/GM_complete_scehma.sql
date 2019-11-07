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

-- Dumping data for table gm_reports.reports: ~5 rows (approximately)
/*!40000 ALTER TABLE `reports` DISABLE KEYS */;
INSERT INTO `reports` (`id`, `name`, `interval_value`, `interval_unit`, `remarks`) VALUES
	(1, 'SMS(Delivered)', 24, 'hr', 'gm_sms_delivered_report'),
	(2, 'SMS(Undelivered)', 24, 'hr', 'gm_sms_undelivered_report'),
	(3, 'Voice', 24, 'hr', 'gm_voice_report'),
	(4, 'Data', 24, 'hr', 'gm_data_report'),
	(5, 'SMS2', 24, 'hr', 'Procedure');
/*!40000 ALTER TABLE `reports` ENABLE KEYS */;

-- Dumping data for table gm_reports.report_data_details: ~5 rows (approximately)
/*!40000 ALTER TABLE `report_data_details` DISABLE KEYS */;
INSERT INTO `report_data_details` (`id`, `data_node`, `data_processing_date`, `is_processed`) VALUES
	(1, 'SMS(Delivered)', '2019-11-07 12:46:55', 1),
	(2, 'SMS(Undelivered)', '2019-11-07 12:46:55', 1),
	(3, 'Data', '2019-11-06 05:14:48', 1),
	(4, 'Voice', '2019-11-04 09:46:14', 0),
	(5, 'metadata', '0000-00-00 00:00:00', 0);
/*!40000 ALTER TABLE `report_data_details` ENABLE KEYS */;

-- Dumping data for table gm_reports.report_genration_details: ~2 rows (approximately)
/*!40000 ALTER TABLE `report_genration_details` DISABLE KEYS */;
INSERT INTO `report_genration_details` (`id`, `report_id`, `start_date`, `end_date`, `last_execution_time`, `report_file_path`) VALUES
	(1, 1, '2019-09-10 00:00:00', '2019-10-31 00:00:00', '2019-08-27', 'globetouch/gm_reports/sms(delivered)Reports'),
	(2, 2, '2019-08-10 00:00:00', '2019-10-30 00:00:00', '2091-08-26', 'globetouch/gm_reports/sms(Undelivered)');
/*!40000 ALTER TABLE `report_genration_details` ENABLE KEYS */;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
