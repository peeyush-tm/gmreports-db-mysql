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

-- Dumping structure for table stc_report.cdr_data_details_vw_jan6th2021
DROP TABLE IF EXISTS `cdr_data_details_vw_jan6th2021`;
CREATE TABLE IF NOT EXISTS `cdr_data_details_vw_jan6th2021` (
  `ID` int(11) NOT NULL DEFAULT '0',
  `SERVED_IMSI` varchar(255) CHARACTER SET utf8 NOT NULL,
  `SERVED_MSISDN` varchar(255) CHARACTER SET utf8 NOT NULL,
  `RECORD_OPENING_TIME` datetime(6) DEFAULT NULL,
  `DURATION_SEC` int(11) NOT NULL,
  `CAUSE_FOR_CLOSING` int(11) NOT NULL,
  `SERVING_NODE_IPADDR` varchar(200) CHARACTER SET utf8 NOT NULL,
  `RAT_TYPE` int(11) NOT NULL,
  `PGW_ADDRESS` varchar(50) CHARACTER SET utf8 NOT NULL,
  `APN_ID` varchar(128) CHARACTER SET utf8 NOT NULL,
  `SERVED_PDP_ADDRESS` varchar(50) CHARACTER SET utf8 NOT NULL,
  `START_TIME` datetime(6) DEFAULT NULL,
  `STOP_TIME` datetime(6) DEFAULT NULL,
  `DOWNLINK_BYTES` bigint(20) NOT NULL,
  `UPLINK_BYTES` bigint(20) NOT NULL,
  `TOTAL_BYTES` bigint(20) NOT NULL,
  `LOCAL_SEQUENCE_NUMBER` bigint(20) NOT NULL,
  `ULI_MCC` bigint(20) NOT NULL,
  `ULI_MNC` bigint(20) NOT NULL,
  `CHARGING_ID` bigint(20) NOT NULL,
  `SERVICE_DATA_FLOW_ID` bigint(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Data exporting was unselected.

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
