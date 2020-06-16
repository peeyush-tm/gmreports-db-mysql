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

-- Dumping structure for table gm_reports.cdr_voice_incompleted
DROP TABLE IF EXISTS `cdr_voice_incompleted`;
CREATE TABLE IF NOT EXISTS `cdr_voice_incompleted` (
  `ID` bigint(20) NOT NULL AUTO_INCREMENT,
  `CALLID` varchar(50) NOT NULL DEFAULT '0',
  `EVENTSRECD` bigint(20) DEFAULT NULL,
  `IAMRECDAT` datetime DEFAULT NULL,
  `ANMRECDAT` datetime DEFAULT NULL,
  `CALLREFERENCE` varchar(256) DEFAULT NULL,
  `CALLEDNUMBER` varchar(256) DEFAULT NULL,
  `MSRNNAI` bigint(20) DEFAULT NULL,
  `MSRNNPI` bigint(20) DEFAULT NULL,
  `CALLINGNUMBER` varchar(256) DEFAULT NULL,
  `MCC` varchar(256) DEFAULT NULL,
  `MNC` varchar(256) DEFAULT NULL,
  `CAUSEINDCAUSEVALUE` bigint(20) DEFAULT NULL,
  `CELLID` varchar(256) DEFAULT NULL,
  `CALLDURATION` bigint(20) DEFAULT NULL,
  `MOCALL` int(11) DEFAULT NULL,
  `LASTERBCSM` int(11) DEFAULT NULL,
  PRIMARY KEY (`ID`),
  KEY `ANMRECDAT` (`ANMRECDAT`),
  KEY `CALLEDNUMBER` (`CALLEDNUMBER`(255))
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Data exporting was unselected.
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
