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

-- Dumping structure for view stc_report.vw_network_registration_failure_level
DROP VIEW IF EXISTS `vw_network_registration_failure_level`;
-- Removing temporary table and create final VIEW structure
DROP TABLE IF EXISTS `vw_network_registration_failure_level`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `vw_network_registration_failure_level` AS select `fl1`.`level_name` AS `level_1`,`fl1`.`level_alias` AS `level_alias_1`,`fl2`.`level_name` AS `level_2`,`fl2`.`level_alias` AS `level_alias_2`,`fl3`.`level_name` AS `level_3`,`fl3`.`level_alias` AS `level_alias_3`,`fl4`.`level_name` AS `level_4`,`fl4`.`level_alias` AS `level_alias_4` from (((`network_registration_failure_level_1` `fl1` join `network_registration_failure_level_2` `fl2` on((`fl1`.`id` = `fl2`.`level_one_id`))) join `network_registration_failure_level_3` `fl3` on((`fl2`.`id` = `fl3`.`level_two_id`))) join `network_registration_failure_level_4` `fl4` on((`fl3`.`id` = `fl4`.`level_three_id`)));

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
