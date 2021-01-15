SET FOREIGN_KEY_CHECKS=0;
use stc_report;

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

-- Dumping data for table stc_report.report_data_details: ~11 rows (approximately)
DELETE FROM `report_data_details`;
/*!40000 ALTER TABLE `report_data_details` DISABLE KEYS */;
INSERT INTO `report_data_details` (`ID`, `DATA_NODE`, `REPORT_NODE`, `DATA_PROCESSING_DATE`, `IS_PROCESSED`) VALUES
	(1, 'cdr_sms_details', 'SMS(Delivered)', '2019-12-02 06:35:56',1),
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


SET FOREIGN_KEY_CHECKS=1;