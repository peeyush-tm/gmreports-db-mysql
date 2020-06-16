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

-- Dumping structure for table gm_reports.wholesale_plan_history
DROP TABLE IF EXISTS `wholesale_plan_history`;
CREATE TABLE IF NOT EXISTS `wholesale_plan_history` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `MESSAGE` varchar(200) DEFAULT '0',
  `OLD_VALUE` varchar(50) DEFAULT '0',
  `NEW_VALUE` varchar(50) DEFAULT '0',
  `RESULT` varchar(50) DEFAULT '0',
  `CREATE_DATE` varchar(50) DEFAULT '0',
  `ASSET_ID` varchar(50) DEFAULT '0',
  `ATTRIBUTE` varchar(50) DEFAULT '0',
  `ICCID` varchar(50) DEFAULT '0',
  `IMSI` varchar(50) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Data exporting was unselected.
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
