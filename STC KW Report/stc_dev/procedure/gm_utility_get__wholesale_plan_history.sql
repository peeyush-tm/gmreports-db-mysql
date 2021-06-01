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

-- Dumping structure for procedure stc_report.gm_utility_get__wholesale_plan_history
DROP PROCEDURE IF EXISTS `gm_utility_get__wholesale_plan_history`;
DELIMITER //
CREATE PROCEDURE `gm_utility_get__wholesale_plan_history`(IN `in_start_date` DATE)
BEGIN
Set @temp_start_date=concat(in_start_date ,' 00:00:00');

 Set @IMSI_count=(select count(distinct IMSI) from wholesale_plan_history where date(wholesale_plan_history.CREATE_DATE)=date(@temp_start_date));


 
     DROP TEMPORARY TABLE IF EXISTS temp_wholesale_plan_history;
    CREATE TEMPORARY TABLE  temp_wholesale_plan_history
    (imsi varchar(20),
    start_date datetime,
    end_date datetime,
	 plan varchar(20));
 
 
  
   SET @j =0;
   loop_loop_1: LOOP
   Set @temp_start_date=concat(in_start_date ,' 00:00:00'); 
     IF @j+1 <= @IMSI_count THEN

     
     
     
      
      
      SET @sql_statement = concat("set @temp_imsi_list=(select Distinct IMSI  from wholesale_plan_history where date(wholesale_plan_history.CREATE_DATE)=date('",in_start_date,"') order by CREATE_DATE limit 1 offset ", @j,");");
      prepare stmt1 from @sql_statement;
       execute stmt1;
      deallocate prepare stmt1;
      SET @j = @j + 1;
     
     
   Set @recored_count=(select count(*) from wholesale_plan_history where date(wholesale_plan_history.CREATE_DATE)=date(@temp_start_date)  and IMSI = @temp_imsi_list);
 
   SET @i =0;
   loop_loop: LOOP
     IF @i+1 <= @recored_count THEN
     
       IF @i+2 <= @recored_count THEN
        SET @sql_statement = concat("set @temp_end_date=(select  CREATE_DATE  from wholesale_plan_history where date(wholesale_plan_history.CREATE_DATE)=date('",in_start_date,"') and IMSI ='",@temp_imsi_list,"'  order by CREATE_DATE limit 1 offset ", @i+1,");");
    
      prepare stmt1 from @sql_statement;
      execute stmt1;
      deallocate prepare stmt1;
      else 
      set @temp_end_date=concat(in_start_date,' 23:59:59');
      end if;
      
      
      SET @sql_statement = concat("insert into temp_wholesale_plan_history  select imsi, CREATE_DATE as start_date,'",@temp_end_date,"' as end_date,new_Value as plan  from wholesale_plan_history where date(wholesale_plan_history.CREATE_DATE)=date('",in_start_date,"') and IMSI ='",@temp_imsi_list,"' order by CREATE_DATE limit 1 offset ", @i,";");
      prepare stmt1 from @sql_statement;
       execute stmt1;
      deallocate prepare stmt1;
	   SET @sql_statement = concat("set @temp_start_date=(select  date_add(CREATE_DATE, interval 1 second)  from wholesale_plan_history where date(wholesale_plan_history.CREATE_DATE)=date('",in_start_date,"') and IMSI ='",@temp_imsi_list,"'  order by CREATE_DATE limit 1 offset ", @i,");");
    
      prepare stmt1 from @sql_statement;
    execute stmt1;
      deallocate prepare stmt1;
     SET @i = @i + 1;
     
       
       ITERATE loop_loop;
     END IF;
     LEAVE loop_loop;
   END LOOP loop_loop;
       
	
		  ITERATE loop_loop_1;
     END IF;
     LEAVE loop_loop_1;
   END LOOP loop_loop_1;


END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
