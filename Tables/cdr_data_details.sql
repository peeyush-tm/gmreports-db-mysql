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

-- Dumping structure for table cdr_data_details
DROP TABLE IF EXISTS `cdr_data_details`;
CREATE TABLE IF NOT EXISTS `cdr_data_details` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `SERVED_IMSI` varchar(20) NOT NULL,
  `RECORD_OPENING_TIME` datetime NOT NULL,
  `DURATION_SEC` int(11) NOT NULL,
  `CAUSE_FOR_CLOSING` int(11) NOT NULL,
  `SERVING_NODE_IPADDR` varchar(200) NOT NULL,
  `RAT_TYPE` int(11) NOT NULL,
  `PGW_ADDRESS` varchar(50) NOT NULL,
  `APN_ID` varchar(128) NOT NULL,
  `SERVED_PDP_ADDRESS` varchar(50) NOT NULL,
  `START_TIME` datetime NOT NULL,
  `STOP_TIME` datetime NOT NULL,
  `DOWNLINK_BYTES` bigint(20) NOT NULL,
  `UPLINK_BYTES` bigint(20) NOT NULL,
  `TOTAL_BYTES` bigint(20) NOT NULL,
  PRIMARY KEY (`ID`),
  KEY `SERVED_IMSI` (`SERVED_IMSI`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='This table is used for storing the cdr data records of the IMSI ';

-- Data exporting was unselected.

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
