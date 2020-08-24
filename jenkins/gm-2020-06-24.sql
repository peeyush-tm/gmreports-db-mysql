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

-- Dumping structure for procedure gm_reports.gm_data_report
DROP PROCEDURE IF EXISTS `gm_data_report`;
DELIMITER //
CREATE  PROCEDURE `gm_data_report`(IN `in_start_date` varchar(50), IN `in_end_date` varchar(50)
, IN `in_account_id` VARCHAR(50))
    COMMENT 'gm_data_report_new'
BEGIN
  -- **********************************************************************
  -- Procedure: gm_data_report_new
  -- Author: Parul Shrivastava
  -- Date: Nov 1, 2019
   
  -- Inputs: in_start_date,in_end_date
  -- Output: This procedure is used to returns cdr data on the basis of 
  -- the served imsi and STOP_TIME
  
  -- Description: Procedure returns the report genarted 
  -- **********************************************************************

	-- Declaration of the variables 
	DECLARE date_duration VARCHAR(50);
	DECLARE start_date varchar(50);

   SET start_date:= CAST(in_start_date AS DATEtime);

	-- preparing billing dates accordign to current date month start date and end date 
    SET date_duration= LAST_DAY(CONVERT( in_start_date, DATE ));
    SET @temp_date = DATE_SUB(in_start_date,INTERVAL DAYOFMONTH(in_start_date)-1 DAY);
	-- select concat(@temp_date ,' - ',date_duration);
	 
	-- prepare the data report with the multiple tables joins 

Set @temp_start_date=concat(in_start_date ,' 00:00:00');
--  Set @recored_count=(select count(*) from wholesale_plan_history where date(wholesale_plan_history.CREATE_DATE)=date('2020-06-15 06:29:00'));
 Set @IMSI_count=(select count(distinct IMSI) from wholesale_plan_history where date(wholesale_plan_history.CREATE_DATE)=date(@temp_start_date));
-- select @recored_count;
-- select * from wholesale_plan_history where date(wholesale_plan_history.CREATE_DATE)=date('2020-06-15 06:29:00') limit 1 offset 3;
 
     DROP TEMPORARY TABLE IF EXISTS temp_wholesale_plan_history;
    CREATE TEMPORARY TABLE  temp_wholesale_plan_history
    (imsi varchar(20),
    start_date datetime,
    end_date datetime,
	 plan varchar(20));
 -- DECLARE  temp_start_date datetime;
 
  
   SET @j =0;
   loop_loop_1: LOOP
   Set @temp_start_date=concat(in_start_date ,' 00:00:00'); 
     IF @j+1 <= @IMSI_count THEN
--       SELECT @i,CAST(@i AS INT);
     -- SET @sql_statement = concat("insert into temp_wholesale_plan_history  select imsi, '",@temp_start_date,"' as start_date,CREATE_DATE as end_date,new_Value as plan  from wholesale_plan_history where date(wholesale_plan_history.CREATE_DATE)=date('",in_start_date,"') order by CREATE_DATE limit 1 offset ", @i,";");
     -- prepare stmt1 from @sql_statement;
     --  execute stmt1;
      -- deallocate prepare stmt1;
      
      SET @sql_statement = concat("set @temp_imsi_list=(select Distinct IMSI  from wholesale_plan_history where date(wholesale_plan_history.CREATE_DATE)=date('",in_start_date,"') order by CREATE_DATE limit 1 offset ", @j,");");
      prepare stmt1 from @sql_statement;
       execute stmt1;
      deallocate prepare stmt1;
      SET @j = @j + 1;
     -- select @temp_imsi_list;
     --  Set @temp_start_date=concat(in_start_date ,' 00:00:00');    
   Set @recored_count=(select count(*) from wholesale_plan_history where date(wholesale_plan_history.CREATE_DATE)=date(@temp_start_date)  and IMSI = @temp_imsi_list);
 --  select @recored_count;
   SET @i =0;
   loop_loop: LOOP
     IF @i+1 <= @recored_count THEN
     
       IF @i+2 <= @recored_count THEN
        SET @sql_statement = concat("set @temp_end_date=(select  CREATE_DATE  from wholesale_plan_history where date(wholesale_plan_history.CREATE_DATE)=date('",in_start_date,"') and IMSI ='",@temp_imsi_list,"'  order by CREATE_DATE limit 1 offset ", @i+1,");");
    -- select @sql_statement;
      prepare stmt1 from @sql_statement;
      execute stmt1;
      deallocate prepare stmt1;
      else 
      set @temp_end_date=concat(in_start_date,' 23:59:59');
      end if;
      -- SELECT @i,CAST(@i AS INT);
      -- SET @sql_statement = concat("insert into temp_wholesale_plan_history  select imsi, '",@temp_start_date,"' as start_date,CREATE_DATE as end_date,new_Value as plan  from wholesale_plan_history where date(wholesale_plan_history.CREATE_DATE)=date('",in_start_date,"') and IMSI ='",@temp_imsi_list,"' order by CREATE_DATE limit 1 offset ", @i,";");
      SET @sql_statement = concat("insert into temp_wholesale_plan_history  select imsi, CREATE_DATE as start_date,'",@temp_end_date,"' as end_date,new_Value as plan  from wholesale_plan_history where date(wholesale_plan_history.CREATE_DATE)=date('",in_start_date,"') and IMSI ='",@temp_imsi_list,"' order by CREATE_DATE limit 1 offset ", @i,";");
      prepare stmt1 from @sql_statement;
       execute stmt1;
      deallocate prepare stmt1;
	   SET @sql_statement = concat("set @temp_start_date=(select  date_add(CREATE_DATE, interval 1 second)  from wholesale_plan_history where date(wholesale_plan_history.CREATE_DATE)=date('",in_start_date,"') and IMSI ='",@temp_imsi_list,"'  order by CREATE_DATE limit 1 offset ", @i,");");
    -- select @sql_statement;
      prepare stmt1 from @sql_statement;
    execute stmt1;
      deallocate prepare stmt1;
     SET @i = @i + 1;
     -- select @sql_statement ;
       -- select * from wholesale_plan_history where date(wholesale_plan_history.CREATE_DATE)=date('2020-06-15 06:29:00') limit 1 offset CAST(@i AS INT);
       ITERATE loop_loop;
     END IF;
     LEAVE loop_loop;
   END LOOP loop_loop;
       
	
		  ITERATE loop_loop_1;
     END IF;
     LEAVE loop_loop_1;
   END LOOP loop_loop_1;



	
	
	SELECT 
	report_metadata.ICCID AS ICCID,
	report_metadata.MSISDN AS MSISDN,
	report_metadata.IMSI AS IMSI,
-- 	report_metadata.ACCOUNT_NAME AS SUPPLIER_ACCOUNT_ID ,
   gm_country_code_mapping.country_Code AS SUPPLIER_ACCOUNT_ID ,
	-- concat(@temp_date ,' - ',date_duration) AS BILLING_CYCLE_DATE,
	'5' AS BILLING_CYCLE_DATE,
-- 	report_metadata.WHOLE_SALE_NAME AS PLAN,
	temp_wholesale_plan_history.plan AS PLAN,
   cdr_data_details_vw.START_TIME AS ORIGINATION_DATE,
   sum(cdr_data_details_vw.UPLINK_BYTES) AS TRANSMIT_BYTE,
   sum(cdr_data_details_vw.DOWNLINK_BYTES) AS RECEIVE_BYTES,
	sum(cdr_data_details_vw.TOTAL_BYTES) AS DATAUSAGE,
	-- sum(cdr_data_details_vw.TOTAL_BYTES * rounded_config ) AS DATAUSAGE_ROUNDING,
   cdr_data_details_vw.APN_ID AS APN,
	cdr_data_details_vw.SERVED_PDP_ADDRESS AS DEVICE_IP_ADDRESS,
--   cdr_data_details_vw.SERVED_IMSI AS OPERATOR_NETWORK,
   concat(cdr_data_details_vw.ULI_MCC,case when CHAR_LENGTH(cdr_data_details_vw.ULI_MNC)=1 then  concat('0',cdr_data_details_vw.ULI_MNC) else cdr_data_details_vw.ULI_MNC end ) AS OPERATOR_NETWORK,
	cdr_data_details_vw.RECORD_OPENING_TIME AS ORIGINATION_PLAN_DATE,
	sum(cdr_data_details_vw.DURATION_SEC) AS SESSION_DURATION,
   -- pgw_svc_data.SERVICE_DATA_FLOW_ID  ,
	cdr_data_details_vw.CAUSE_FOR_CLOSING AS CALL_TERMINATION_REASON,
  	cdr_data_details_vw.SERVICE_DATA_FLOW_ID AS RATING_STREAM_ID,
    -- 6 PARAMTER MISING     
   cdr_data_details_vw.SERVING_NODE_IPADDR AS SERVING_SWITCH,
   case when cdr_data_details_vw.RAT_TYPE=1 then 'UTRAN - 3G' when cdr_data_details_vw.RAT_TYPE=6 then 'EUTRAN - 4G' when cdr_data_details_vw.RAT_TYPE=2 then 'GERAN - 2G' else cdr_data_details_vw.RAT_TYPE end  AS CALL_TECHNOLOGY_TYPE,
   cdr_data_details_vw.PGW_ADDRESS AS GGSN_IP_ADDRESS,
   cdr_data_details_vw.LOCAL_SEQUENCE_NUMBER as Record_Sequence_Number
	from	((report_metadata
	INNER JOIN cdr_data_details_vw
 	ON report_metadata.IMSI = cdr_data_details_vw.SERVED_IMSI
	left join gm_country_code_mapping on report_metadata.ACCOUNT_COUNTRIE=gm_country_code_mapping.account
	left join temp_wholesale_plan_history on temp_wholesale_plan_history.IMSI=report_metadata.IMSI
	and (cdr_data_details_vw.START_TIME between  temp_wholesale_plan_history.start_date and temp_wholesale_plan_history.end_date)))
	   WHERE 
		  date(cdr_data_details_vw.STOP_TIME) = date(start_date)
	   and report_metadata.MNO_ACCOUNTID=in_account_id
	group by cdr_data_details_vw.SERVED_IMSI, cdr_data_details_vw.CHARGING_ID,cdr_data_details_vw.SERVICE_DATA_FLOW_ID;
	/*
	FROM ((report_metadata
	INNER JOIN cdr_data_details
	ON report_metadata.IMSI = cdr_data_details.SERVED_IMSI)
	INNER JOIN pgw_svc_data
	ON pgw_svc_data.SERVED_IMSI= cdr_data_details.SERVED_IMSI
	left join gm_country_code_mapping on report_metadata.ACCOUNT_COUNTRIE=gm_country_code_mapping.account)
	WHERE date(cdr_data_details.STOP_TIME) = date(start_date)
	group by cdr_data_details.SERVED_IMSI, pgw_svc_data.CHARGING_ID;
*/
 
END//
DELIMITER ;


-- Dumping structure for procedure gm_reports.gm_mobile_number_reconciliation_report
DROP PROCEDURE IF EXISTS `gm_mobile_number_reconciliation_report`;
DELIMITER //
CREATE  PROCEDURE `gm_mobile_number_reconciliation_report`(IN `in_account_id` VARCHAR(50))
    COMMENT 'gm_mobile_number_reconciliation_report'
BEGIN
  -- **********************************************************************
  -- Procedure: gm_mobile_number_reconciliation_report_new
  -- Author: Parul Shrivastava
  -- Date: Nov 2, 2019
  
  -- Output : Returns the updated status of the mobile report
  -- Description: Procedure is use to generate the Mobile Number Reconciliation  report according to the creation date  
  --  *****************************************************************************************************
   
  -- prepare the data from the updated meta data tables of gc data
    SELECT ICCID ,
    MSISDN , 
    IMSI ,
    gm_country_code_mapping.country_Code AS SUPPLIER_ACCOUNT_ID,
    SIM_STATE as SIM_STATE_GT,
    case when SIM_STATE='Warm' then 'Device Shipped'
	 when SIM_STATE='' or SIM_STATE is NULL or SIM_STATE ='NULL'  then 'UnSoldNewVehicle' 
	 when SIM_STATE='Active' then 'Subscribed' 
	 when SIM_STATE='Suspend' then 'Dormant' 
	 else SIM_STATE end as SIM_STATE_GM,
    RATE_PLAN_NAME AS PRICING_PLAN,
    RATE_PLAN_NAME AS COMMUNCATION_PLAN,
    ACTIVATION_DATE AS ICCID_ACTIVATION_DATE,
    -- ICCID as BOOTSTRAP_ICCID
    BOOTSTRAP_ICCID
    FROM report_metadata
	 left join gm_country_code_mapping on report_metadata.ACCOUNT_COUNTRIE=gm_country_code_mapping.account
	 where report_metadata.MNO_ACCOUNTID=in_account_id;
	 

END//
DELIMITER ;


-- Dumping structure for procedure gm_reports.gm_sms_delivered_report
DROP PROCEDURE IF EXISTS `gm_sms_delivered_report`;
DELIMITER //
CREATE  PROCEDURE `gm_sms_delivered_report`(IN `in_start_date` varchar(50), IN `in_end_date` varchar(50)




















, IN `in_account_id` VARCHAR(50))
    COMMENT 'gm_sms_delivered_report_new'
BEGIN
  -- **********************************************************************
  -- Procedure: gm_sms_delivered_report_new
  -- Author: Parul Shrivastava
  -- Date: Nov 1, 2019
  
  -- Inputs: in_start_date,in_end_date
  -- Output: This procedure is returns the delivered sms report on the basis
  -- of the final time and sms status 
  -- Description: Procedure returns the sms delivered report genarted 
  -- **********************************************************************
	
   -- Declaring the variables 
	DECLARE date_duration VARCHAR(50);
	DECLARE start_date varchar(50);

   SET start_date:= CAST(in_start_date AS DATEtime);
   
  CALL `gm_utility_get__wholesale_plan_history`(in_start_date);

	-- Preparing the billing dates
    SET date_duration= LAST_DAY(CONVERT( in_start_date, DATE ));
    SET @temp_date = DATE_SUB(in_start_date,INTERVAL DAYOFMONTH(in_start_date)-1 DAY);
	-- select concat(@temp_date ,' - ',date_duration);
	
  -- preparing the reports data from the different table on the basis of the SMS type and time 
	SELECT 
    report_metadata.ICCID AS ICCID,
	report_metadata.MSISDN AS MSISDN,
	report_metadata.IMSI AS IMSI,
   gm_country_code_mapping.country_Code AS SUPPLIER_ACCOUNT_ID ,
   -- report_metadata.ACCOUNT_NAME AS SUPPLIER_ACCOUNT_ID ,
   -- concat(@temp_date ,' - ',date_duration) AS BILLING_CYCLE_DATE,
   '5' AS BILLING_CYCLE_DATE,
	cdr_sms_details.SMS_TYPE AS CALL_DIRECTION,
	-- report_metadata.WHOLE_SALE_NAME AS PLAN,
	 temp_wholesale_plan_history.plan AS PLAN,
   cdr_sms_details.SENT_TIME AS ORIGINATION_DATE,
   case when cdr_sms_details.SMS_TYPE='MO' then cdr_sms_details.ORIGINATION_GT
	when cdr_sms_details.SMS_TYPE='MT' then cdr_sms_details.DESTINATION_GT 
	else NULL end AS SERVING_SWITCH,
	case when cdr_sms_details.SMS_TYPE='MO' then cdr_sms_details.SOURCE
	when cdr_sms_details.SMS_TYPE='MT' then cdr_sms_details.DESTINATION
	else NULL end  AS ORIGINATION_ADDRESS ,
   case when cdr_sms_details.SMS_TYPE='MO' then cdr_sms_details.DESTINATION
	when cdr_sms_details.SMS_TYPE='MT' then cdr_sms_details.SOURCE
	else NULL end AS DESTINATION_ADDRESS,
    -- cdr_sms_details.DESTINATION_GT,
	  case when cdr_sms_details.SMS_TYPE='MO' then cdr_sms_details.ORIGINATION_GT
	when cdr_sms_details.SMS_TYPE='MT' then cdr_sms_details.DESTINATION_GT
	else NULL end  AS OPERATOR_NETWORK
	FROM (report_metadata
	INNER JOIN cdr_sms_details
	ON report_metadata.MSISDN = cdr_sms_details.SOURCE 
	OR report_metadata.MSISDN = cdr_sms_details.DESTINATION
	left join gm_country_code_mapping on report_metadata.ACCOUNT_COUNTRIE=gm_country_code_mapping.account
	left join temp_wholesale_plan_history on temp_wholesale_plan_history.IMSI=report_metadata.IMSI
	and (cdr_sms_details.FINAL_TIME between  temp_wholesale_plan_history.start_date and temp_wholesale_plan_history.end_date))	
   WHERE date(cdr_sms_details.FINAL_TIME)=date(start_date)
	and cdr_sms_details.SMS_STATUS = 'Success'
	and report_metadata.MNO_ACCOUNTID=in_account_id;
	-- GROUP BY IMSI,MSISDN ,CALL_DIRECTION ,ORIGINATION_DATE ;


END//
DELIMITER ;


-- Dumping structure for procedure gm_reports.gm_sms_undelivered_report
DROP PROCEDURE IF EXISTS `gm_sms_undelivered_report`;
DELIMITER //
CREATE  PROCEDURE `gm_sms_undelivered_report`(IN `in_start_date` varchar(50), IN `in_end_date` varchar(50)















, IN `in_account_id` VARCHAR(50))
    COMMENT 'gm_sms_undelivered_report_new'
BEGIN
  -- **********************************************************************
  -- Procedure: gm_sms_undelivered_report_new
  -- Author: Parul Shrivastava
  -- Date: Nov 1, 2019
  
  -- Inputs: in_start_date,in_end_date
  -- Output: This procedure is returns the undelivered sms report on the basis
  -- of the final time and sms status 
  -- Description: Procedure returns the sms undelivered report genarted 
  -- **********************************************************************

	 -- Declaring the variables 
 	 DECLARE date_duration VARCHAR(50);
 	 DECLARE start_date VARCHAR(50);

    SET start_date:= CAST(in_start_date AS date);
   
    CALL `gm_utility_get__wholesale_plan_history`(in_start_date);
	 -- preparing the billing dates 
    SET date_duration= LAST_DAY(CONVERT( in_start_date, DATE ));
    SET @temp_date = DATE_SUB(in_start_date,INTERVAL DAYOFMONTH(in_start_date)-1 DAY);
	 -- select concat(@temp_date ,' - ',date_duration);
	
	-- preparing the reports data from the different table on the basis of the SMS type and time 
   SELECT 
	report_metadata.ICCID as ICCID,
	report_metadata.MSISDN as MSISDN,
	report_metadata.IMSI as IMSI,
 --  report_metadata.MNO_ACCOUNTID as SUPPLIER_ACCOUNT_ID ,
-- 	concat(@temp_date ,' - ',date_duration) AS BILLING_CYCLE_DATE,
	 gm_country_code_mapping.country_Code AS SUPPLIER_ACCOUNT_ID ,
   '5' AS BILLING_CYCLE_DATE,
	cdr_sms_details.SMS_TYPE AS CALL_DIRECTION,
	-- report_metadata.WHOLE_SALE_NAME AS PLAN,
	temp_wholesale_plan_history.plan AS PLAN,
   cdr_sms_details.SENT_TIME AS ORIGINATION_DATE,
   /*cdr_sms_details.ORIGINATION_GT AS SERVING_SWITCH,
	cdr_sms_details.SOURCE AS ORIGINATION_ADDRESS ,
   cdr_sms_details.DESTINATION AS DESTINATION_ADDRESS,
	cdr_sms_details.SUBSCRIBER_IMSI AS OPERATOR_NETWORK,*/
	 case when cdr_sms_details.SMS_TYPE='MO' then cdr_sms_details.ORIGINATION_GT
	when cdr_sms_details.SMS_TYPE='MT' then cdr_sms_details.DESTINATION_GT 
	else NULL end AS SERVING_SWITCH,
	case when cdr_sms_details.SMS_TYPE='MO' then cdr_sms_details.SOURCE
	when cdr_sms_details.SMS_TYPE='MT' then cdr_sms_details.DESTINATION
	else NULL end  AS ORIGINATION_ADDRESS ,
   case when cdr_sms_details.SMS_TYPE='MO' then cdr_sms_details.DESTINATION
	when cdr_sms_details.SMS_TYPE='MT' then cdr_sms_details.SOURCE
	else NULL end AS DESTINATION_ADDRESS,
    -- cdr_sms_details.DESTINATION_GT,
	  case when cdr_sms_details.SMS_TYPE='MO' then cdr_sms_details.ORIGINATION_GT
	when cdr_sms_details.SMS_TYPE='MT' then cdr_sms_details.DESTINATION_GT
	else NULL end  AS OPERATOR_NETWORK,
   cdr_sms_details.REASON AS CALL_TERMINATIONS_REASON
	FROM (report_metadata
	INNER JOIN cdr_sms_details
	ON report_metadata.MSISDN = cdr_sms_details.SOURCE 
	OR report_metadata.MSISDN = cdr_sms_details.DESTINATION
	left join gm_country_code_mapping on report_metadata.ACCOUNT_COUNTRIE=gm_country_code_mapping.account
	left join temp_wholesale_plan_history on temp_wholesale_plan_history.IMSI=report_metadata.IMSI
	and (cdr_sms_details.FINAL_TIME between  temp_wholesale_plan_history.start_Date and temp_wholesale_plan_history.end_date))	
   WHERE date(cdr_sms_details.FINAL_TIME)=start_date
   and cdr_sms_details.SMS_STATUS ='Failed'
   and report_metadata.MNO_ACCOUNTID=in_account_id;
--   GROUP BY IMSI,MSISDN ,CALL_DIRECTION ,  ORIGINATION_DATE ;
   
END//
DELIMITER ;


-- Dumping structure for procedure gm_reports.gm_utility_get__wholesale_plan_history
DROP PROCEDURE IF EXISTS `gm_utility_get__wholesale_plan_history`;
DELIMITER //
CREATE  PROCEDURE `gm_utility_get__wholesale_plan_history`(IN `in_start_date` DATE)
BEGIN
Set @temp_start_date=concat(in_start_date ,' 00:00:00');
--  Set @recored_count=(select count(*) from wholesale_plan_history where date(wholesale_plan_history.CREATE_DATE)=date('2020-06-15 06:29:00'));
 Set @IMSI_count=(select count(distinct IMSI) from wholesale_plan_history where date(wholesale_plan_history.CREATE_DATE)=date(@temp_start_date));
-- select @recored_count;
-- select * from wholesale_plan_history where date(wholesale_plan_history.CREATE_DATE)=date('2020-06-15 06:29:00') limit 1 offset 3;
 
     DROP TEMPORARY TABLE IF EXISTS temp_wholesale_plan_history;
    CREATE TEMPORARY TABLE  temp_wholesale_plan_history
    (imsi varchar(20),
    start_date datetime,
    end_date datetime,
	 plan varchar(20));
 -- DECLARE  temp_start_date datetime;
 
  
   SET @j =0;
   loop_loop_1: LOOP
   Set @temp_start_date=concat(in_start_date ,' 00:00:00'); 
     IF @j+1 <= @IMSI_count THEN
--       SELECT @i,CAST(@i AS INT);
     -- SET @sql_statement = concat("insert into temp_wholesale_plan_history  select imsi, '",@temp_start_date,"' as start_date,CREATE_DATE as end_date,new_Value as plan  from wholesale_plan_history where date(wholesale_plan_history.CREATE_DATE)=date('",in_start_date,"') order by CREATE_DATE limit 1 offset ", @i,";");
     -- prepare stmt1 from @sql_statement;
     --  execute stmt1;
      -- deallocate prepare stmt1;
      
      SET @sql_statement = concat("set @temp_imsi_list=(select Distinct IMSI  from wholesale_plan_history where date(wholesale_plan_history.CREATE_DATE)=date('",in_start_date,"') order by CREATE_DATE limit 1 offset ", @j,");");
      prepare stmt1 from @sql_statement;
       execute stmt1;
      deallocate prepare stmt1;
      SET @j = @j + 1;
     -- select @temp_imsi_list;
     --  Set @temp_start_date=concat(in_start_date ,' 00:00:00');    
   Set @recored_count=(select count(*) from wholesale_plan_history where date(wholesale_plan_history.CREATE_DATE)=date(@temp_start_date)  and IMSI = @temp_imsi_list);
 --  select @recored_count;
   SET @i =0;
   loop_loop: LOOP
     IF @i+1 <= @recored_count THEN
     
       IF @i+2 <= @recored_count THEN
        SET @sql_statement = concat("set @temp_end_date=(select  CREATE_DATE  from wholesale_plan_history where date(wholesale_plan_history.CREATE_DATE)=date('",in_start_date,"') and IMSI ='",@temp_imsi_list,"'  order by CREATE_DATE limit 1 offset ", @i+1,");");
    -- select @sql_statement;
      prepare stmt1 from @sql_statement;
      execute stmt1;
      deallocate prepare stmt1;
      else 
      set @temp_end_date=concat(in_start_date,' 23:59:59');
      end if;
      -- SELECT @i,CAST(@i AS INT);
      -- SET @sql_statement = concat("insert into temp_wholesale_plan_history  select imsi, '",@temp_start_date,"' as start_date,CREATE_DATE as end_date,new_Value as plan  from wholesale_plan_history where date(wholesale_plan_history.CREATE_DATE)=date('",in_start_date,"') and IMSI ='",@temp_imsi_list,"' order by CREATE_DATE limit 1 offset ", @i,";");
      SET @sql_statement = concat("insert into temp_wholesale_plan_history  select imsi, CREATE_DATE as start_date,'",@temp_end_date,"' as end_date,new_Value as plan  from wholesale_plan_history where date(wholesale_plan_history.CREATE_DATE)=date('",in_start_date,"') and IMSI ='",@temp_imsi_list,"' order by CREATE_DATE limit 1 offset ", @i,";");
      prepare stmt1 from @sql_statement;
       execute stmt1;
      deallocate prepare stmt1;
	   SET @sql_statement = concat("set @temp_start_date=(select  date_add(CREATE_DATE, interval 1 second)  from wholesale_plan_history where date(wholesale_plan_history.CREATE_DATE)=date('",in_start_date,"') and IMSI ='",@temp_imsi_list,"'  order by CREATE_DATE limit 1 offset ", @i,");");
    -- select @sql_statement;
      prepare stmt1 from @sql_statement;
    execute stmt1;
      deallocate prepare stmt1;
     SET @i = @i + 1;
     -- select @sql_statement ;
       -- select * from wholesale_plan_history where date(wholesale_plan_history.CREATE_DATE)=date('2020-06-15 06:29:00') limit 1 offset CAST(@i AS INT);
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


-- Dumping structure for procedure gm_reports.gm_voice_report
DROP PROCEDURE IF EXISTS `gm_voice_report`;
DELIMITER //
CREATE  PROCEDURE `gm_voice_report`(IN `in_start_date` varchar(50)
, IN `in_end_date` varchar(50)

















, IN `in_account_id` VARCHAR(50))
    COMMENT 'gm_voice_report_new'
BEGIN
 -- **********************************************************************
  -- Procedure: gm_voice_report_new
  -- Author: Parul Shrivastava
  -- Date: Nov 2, 2019
   
  -- Inputs: in_start_date,in_end_date
  -- Output: This procedure is used to returns voice data  on the basis of 
  -- the served imsi and served flow id and ANMRECDAT
 
  -- Description: Procedure is use to generate the voice report according to the creation date  
  -- **********************************************************************
	
	DECLARE date_duration VARCHAR(50);
	DECLARE start_date varchar(50);

   SET start_date:= CAST(in_start_date AS DATEtime);

	-- preparing billing dates accordign to current date month start date and end date 
    SET date_duration= LAST_DAY(CONVERT( in_start_date, DATE ));
    SET @temp_date = DATE_SUB(in_start_date,INTERVAL DAYOFMONTH(in_start_date)-1 DAY);
	-- select concat(@temp_date ,' - ',date_duration);
	 
	-- generate a table to fetch the data from the incomplete voice table  	
	DROP  TEMPORARY TABLE if EXISTS temp_voice_complete;
	CREATE TEMPORARY TABLE temp_voice_complete
	SELECT 
	report_metadata.ICCID ,
	report_metadata.IMSI,
	report_metadata.WHOLESALE_PLAN_ID,
	report_metadata.MSISDN,
	report_metadata.MNO_ACCOUNTID,
	cdr_voice_incompleted.CALLINGNUMBER,
	cdr_voice_incompleted.CALLEDNUMBER,
	cdr_voice_incompleted.CALLDURATION,
	cdr_voice_incompleted.ANMRECDAT ,
	cdr_voice_incompleted.EVENTSRECD,
	cdr_voice_incompleted.MCC,
	cdr_voice_incompleted.MNC ,
	cdr_voice_incompleted.CAUSEINDCAUSEVALUE,
	cdr_voice_incompleted.MOCALL,
	cdr_voice_incompleted.LASTERBCSM,
	gm_country_code_mapping.country_Code AS COUNTRY_CODE
	FROM cdr_voice_incompleted 
	INNER JOIN report_metadata 
	ON (report_metadata.IMSI = cdr_voice_incompleted.CALLEDNUMBER
	or report_metadata.IMSI = cdr_voice_incompleted.CALLINGNUMBER)
	left join gm_country_code_mapping on report_metadata.ACCOUNT_COUNTRIE=gm_country_code_mapping.account
	WHERE date(cdr_voice_incompleted.ANMRECDAT) = start_date
	and report_metadata.MNO_ACCOUNTID=in_account_id;
	    
	-- generate a table to fetch the data from the complete voice table 
	DROP  TEMPORARY TABLE if EXISTS temp_voice_incomplete;
	CREATE TEMPORARY TABLE temp_voice_incomplete
	SELECT report_metadata.ICCID ,
	report_metadata.IMSI,
	report_metadata.WHOLESALE_PLAN_ID,
	report_metadata.MSISDN,
	report_metadata.MNO_ACCOUNTID,
	cdr_voice_completed.CALLINGNUMBER,
	cdr_voice_completed.CALLEDNUMBER,
	cdr_voice_completed.CALLDURATION,
	cdr_voice_completed.ANMRECDAT ,
	cdr_voice_completed.EVENTSRECD ,
	cdr_voice_completed.MCC,
	cdr_voice_completed.MNC ,
	cdr_voice_completed.CAUSEINDCAUSEVALUE,
	cdr_voice_completed.MOCALL,
	cdr_voice_completed.LASTERBCSM,
	gm_country_code_mapping.country_Code AS COUNTRY_CODE
	FROM cdr_voice_completed 
	INNER JOIN report_metadata 
	ON (report_metadata.IMSI = cdr_voice_completed.CALLEDNUMBER
		or report_metadata.IMSI = cdr_voice_completed.CALLINGNUMBER)
	left join gm_country_code_mapping on report_metadata.ACCOUNT_COUNTRIE=gm_country_code_mapping.account
	WHERE date(cdr_voice_completed.ANMRECDAT) = start_date
	and report_metadata.MNO_ACCOUNTID=in_account_id;

	-- preparing the data from merging the both table complete and incomplete	
	DROP  TEMPORARY TABLE if EXISTS temp_voice;
	CREATE TEMPORARY TABLE temp_voice
	SELECT * FROM temp_voice_complete                         
	UNION ALL 
	SELECT * FROM 	temp_voice_incomplete;

	-- final result report of the voice data 
	SELECT 
	ICCID  AS 'ICCID',
	IMSI AS 'IMSI',
	MSISDN AS 'MSISDN',
	-- WHOLESALE_PLAN_ID AS 'ACCOUNT ID',
	COUNTRY_CODE AS 'ACCOUNT ID',
	MNO_ACCOUNTID AS 'ACCOUNT ID',
	-- concat(@temp_date ,' - ',date_duration) AS 'BILLING CYCLE DATE',
	'5' AS 'BILLING CYCLE DATE',
	CALLINGNUMBER AS 'CALLING PARTY NUMBER',
	CALLEDNUMBER AS 'CALLED',
	CALLDURATION AS 'ANSWER DURATION',
	case when CALLDURATION=0  then CALLDURATION else CAST(CALLDURATION/60 AS INT)*60+60 end as 'ANSWER DURATION ROUNDED',
	ANMRECDAT AS 'ORIGINATION DATE',
	concat(MCC,case when CHAR_LENGTH(MNC)=1 then  concat('0',MNC) else MNC end ) AS 'OPERATOR NETWORK',
	-- CAUSEINDCAUSEVALUE AS 'CALL TERMINATION REASON',
	case when MOCALL=0 and (CALLDURATION is null or CALLDURATION =0) 
			then 
			case 
					 when LASTERBCSM = 13 
						  then 'Busy'   
					 when LASTERBCSM = 14 
						  then 'Not answered'   
					 when LASTERBCSM = 18 
						  then 'Abandoned i.e. Caller cut the call'
					 when LASTERBCSM = 13 
						  then 'Busy'      
			end 
	     when MOCALL=1 and (CALLDURATION is null or CALLDURATION =0) 
			then 
			case  when LASTERBCSM = 4
						  then 'Route selection failure' 
					when LASTERBCSM = 5 
						  then 'Busy'
					when LASTERBCSM = 6
						  then 'Not answered'
					when LASTERBCSM = 10
						  then 'Abandoned i.e. Caller cut the call'
			end
	end AS 'CALL TERMINATION REASON',
	'Circuit Switched' as 'CALL TYPE',
	case when MOCALL=1 then 'MO' ELSE 'MT' end 'CALL DIRECTION'
	FROM temp_voice;
-- 	GROUP BY IMSI,'ANSWER DURATION','ORIGINATION DATE';

END//
DELIMITER ;


-- Dumping structure for procedure gm_reports.gm_voice_report
DROP PROCEDURE IF EXISTS `gm_voice_report`;
DELIMITER //
CREATE PROCEDURE `gm_voice_report`(IN `in_start_date` varchar(50)
, IN `in_end_date` varchar(50)

















, IN `in_account_id` VARCHAR(50))
    COMMENT 'gm_voice_report_new'
BEGIN
 -- **********************************************************************
  -- Procedure: gm_voice_report_new
  -- Author: Parul Shrivastava
  -- Date: Nov 2, 2019
   
  -- Inputs: in_start_date,in_end_date
  -- Output: This procedure is used to returns voice data  on the basis of 
  -- the served imsi and served flow id and ANMRECDAT
 
  -- Description: Procedure is use to generate the voice report according to the creation date  
  -- **********************************************************************
  
  DECLARE date_duration VARCHAR(50);
  DECLARE start_date varchar(50);

   SET start_date:= CAST(in_start_date AS DATEtime);

  -- preparing billing dates accordign to current date month start date and end date 
    SET date_duration= LAST_DAY(CONVERT( in_start_date, DATE ));
    SET @temp_date = DATE_SUB(in_start_date,INTERVAL DAYOFMONTH(in_start_date)-1 DAY);
  -- select concat(@temp_date ,' - ',date_duration);
   
  -- generate a table to fetch the data from the incomplete voice table   
  DROP  TEMPORARY TABLE if EXISTS temp_voice_complete;
  CREATE TEMPORARY TABLE temp_voice_complete
  SELECT 
  report_metadata.ICCID ,
  report_metadata.IMSI,
  report_metadata.WHOLESALE_PLAN_ID,
  report_metadata.MSISDN,
  report_metadata.MNO_ACCOUNTID,
  cdr_voice_incompleted.CALLINGNUMBER,
  cdr_voice_incompleted.CALLEDNUMBER,
  cdr_voice_incompleted.CALLDURATION,
  cdr_voice_incompleted.ANMRECDAT ,
  cdr_voice_incompleted.EVENTSRECD,
  cdr_voice_incompleted.MCC,
  cdr_voice_incompleted.MNC ,
  cdr_voice_incompleted.CAUSEINDCAUSEVALUE,
  cdr_voice_incompleted.MOCALL,
  cdr_voice_incompleted.LASTERBCSM,
  gm_country_code_mapping.country_Code AS COUNTRY_CODE
  FROM cdr_voice_incompleted 
  INNER JOIN report_metadata 
  ON (report_metadata.IMSI = cdr_voice_incompleted.CALLEDNUMBER
  or report_metadata.IMSI = cdr_voice_incompleted.CALLINGNUMBER)
  left join gm_country_code_mapping on report_metadata.ACCOUNT_COUNTRIE=gm_country_code_mapping.account
  WHERE date(cdr_voice_incompleted.ANMRECDAT) = start_date
  and report_metadata.MNO_ACCOUNTID=in_account_id;
      
  -- generate a table to fetch the data from the complete voice table 
  DROP  TEMPORARY TABLE if EXISTS temp_voice_incomplete;
  CREATE TEMPORARY TABLE temp_voice_incomplete
  SELECT report_metadata.ICCID ,
  report_metadata.IMSI,
  report_metadata.WHOLESALE_PLAN_ID,
  report_metadata.MSISDN,
  report_metadata.MNO_ACCOUNTID,
  cdr_voice_completed.CALLINGNUMBER,
  cdr_voice_completed.CALLEDNUMBER,
  cdr_voice_completed.CALLDURATION,
  cdr_voice_completed.ANMRECDAT ,
  cdr_voice_completed.EVENTSRECD ,
  cdr_voice_completed.MCC,
  cdr_voice_completed.MNC ,
  cdr_voice_completed.CAUSEINDCAUSEVALUE,
  cdr_voice_completed.MOCALL,
  cdr_voice_completed.LASTERBCSM,
  gm_country_code_mapping.country_Code AS COUNTRY_CODE
  FROM cdr_voice_completed 
  INNER JOIN report_metadata 
  ON (report_metadata.IMSI = cdr_voice_completed.CALLEDNUMBER
    or report_metadata.IMSI = cdr_voice_completed.CALLINGNUMBER)
  left join gm_country_code_mapping on report_metadata.ACCOUNT_COUNTRIE=gm_country_code_mapping.account
  WHERE date(cdr_voice_completed.ANMRECDAT) = start_date
  and report_metadata.MNO_ACCOUNTID=in_account_id;
  

  CALL `gm_utility_get__wholesale_plan_history`(in_start_date);

  -- preparing the data from merging the both table complete and incomplete 
  DROP  TEMPORARY TABLE if EXISTS temp_voice;
  CREATE TEMPORARY TABLE temp_voice
  SELECT * FROM temp_voice_complete                         
  UNION ALL 
  SELECT * FROM   temp_voice_incomplete;

  -- final result report of the voice data 
  SELECT 
  temp_voice.ICCID  AS 'ICCID',
  temp_voice.IMSI AS 'IMSI',
  temp_voice.MSISDN AS 'MSISDN',
  -- WHOLESALE_PLAN_ID AS 'ACCOUNT ID',
  COUNTRY_CODE AS 'ACCOUNT ID',
  -- MNO_ACCOUNTID AS 'ACCOUNT ID',
  -- concat(@temp_date ,' - ',date_duration) AS 'BILLING CYCLE DATE',
  '5' AS 'BILLING CYCLE DATE',
  CALLINGNUMBER AS 'CALLING PARTY NUMBER',
  CALLEDNUMBER AS 'CALLED',
  CALLDURATION AS 'ANSWER DURATION',
  case when CALLDURATION=0  then CALLDURATION else CAST(CALLDURATION/60 AS INT)*60+60 end as 'ANSWER DURATION ROUNDED',
  ANMRECDAT AS 'ORIGINATION DATE',
  concat(MCC,case when CHAR_LENGTH(MNC)=1 then  concat('0',MNC) else MNC end ) AS 'OPERATOR NETWORK',
  -- CAUSEINDCAUSEVALUE AS 'CALL TERMINATION REASON',
  case when MOCALL=0 and (CALLDURATION is null or CALLDURATION =0) 
      then 
      case 
           when LASTERBCSM = 13 
              then 'Busy'   
           when LASTERBCSM = 14 
              then 'Not answered'   
           when LASTERBCSM = 18 
              then 'Abandoned i.e. Caller cut the call'
           when LASTERBCSM = 13 
              then 'Busy'      
      end 
       when MOCALL=1 and (CALLDURATION is null or CALLDURATION =0) 
      then 
      case  when LASTERBCSM = 4
              then 'Route selection failure' 
          when LASTERBCSM = 5 
              then 'Busy'
          when LASTERBCSM = 6
              then 'Not answered'
          when LASTERBCSM = 10
              then 'Abandoned i.e. Caller cut the call'
      end
  end AS 'CALL TERMINATION REASON',
  'Circuit Switched' as 'CALL TYPE',
  case when MOCALL=1 then 'MO' ELSE 'MT' end 'CALL DIRECTION',
  temp_wholesale_plan_history.plan AS PLAN
  FROM temp_voice
  left join temp_wholesale_plan_history on temp_wholesale_plan_history.IMSI=temp_voice.IMSI
  and (ANMRECDAT between  temp_wholesale_plan_history.start_date and temp_wholesale_plan_history.end_date);
--  GROUP BY IMSI,'ANSWER DURATION','ORIGINATION DATE';
  




END//
DELIMITER ;

DROP PROCEDURE IF EXISTS gm_voice_report;
DELIMITER $$
CREATE PROCEDURE `gm_voice_report`(
	IN `in_start_date` varchar(50),
	IN `in_end_date` varchar(50),
	IN `in_account_id` VARCHAR(50)
)
    COMMENT 'gm_voice_report_new'
BEGIN
 -- **********************************************************************
  -- Procedure: gm_voice_report_new
  -- Author: Parul Shrivastava
  -- Date: Nov 2, 2019
   
  -- Inputs: in_start_date,in_end_date
  -- Output: This procedure is used to returns voice data  on the basis of 
  -- the served imsi and served flow id and ANMRECDAT
 
  -- Description: Procedure is use to generate the voice report according to the creation date  
  -- **********************************************************************
	
	DECLARE date_duration VARCHAR(50);
	DECLARE start_date varchar(50);

   SET start_date:= CAST(in_start_date AS DATEtime);

	-- preparing billing dates accordign to current date month start date and end date 
    SET date_duration= LAST_DAY(CONVERT( in_start_date, DATE ));
    SET @temp_date = DATE_SUB(in_start_date,INTERVAL DAYOFMONTH(in_start_date)-1 DAY);
	-- select concat(@temp_date ,' - ',date_duration);
	 
	-- generate a table to fetch the data from the incomplete voice table  	
	DROP  TEMPORARY TABLE if EXISTS temp_voice_complete;
	CREATE TEMPORARY TABLE temp_voice_complete
	SELECT 
	report_metadata.ICCID ,
	report_metadata.IMSI,
	report_metadata.WHOLESALE_PLAN_ID,
	report_metadata.MSISDN,
	report_metadata.MNO_ACCOUNTID,
	cdr_voice_incompleted.CALLINGNUMBER,
	cdr_voice_incompleted.CALLEDNUMBER,
	cdr_voice_incompleted.CALLDURATION,
	cdr_voice_incompleted.ANMRECDAT ,
	cdr_voice_incompleted.EVENTSRECD,
	cdr_voice_incompleted.MCC,
	cdr_voice_incompleted.MNC ,
	cdr_voice_incompleted.CAUSEINDCAUSEVALUE,
	cdr_voice_incompleted.MOCALL,
	cdr_voice_incompleted.LASTERBCSM,
	gm_country_code_mapping.country_Code AS COUNTRY_CODE
	FROM cdr_voice_incompleted 
	INNER JOIN report_metadata 
	ON (report_metadata.IMSI = cdr_voice_incompleted.CALLEDNUMBER
	or report_metadata.IMSI = cdr_voice_incompleted.CALLINGNUMBER)
	left join gm_country_code_mapping on report_metadata.ACCOUNT_COUNTRIE=gm_country_code_mapping.account
	WHERE date(cdr_voice_incompleted.ANMRECDAT) = start_date
	and report_metadata.MNO_ACCOUNTID=in_account_id;
	    
	-- generate a table to fetch the data from the complete voice table 
	DROP  TEMPORARY TABLE if EXISTS temp_voice_incomplete;
	CREATE TEMPORARY TABLE temp_voice_incomplete
	SELECT report_metadata.ICCID ,
	report_metadata.IMSI,
	report_metadata.WHOLESALE_PLAN_ID,
	report_metadata.MSISDN,
	report_metadata.MNO_ACCOUNTID,
	cdr_voice_completed.CALLINGNUMBER,
	cdr_voice_completed.CALLEDNUMBER,
	cdr_voice_completed.CALLDURATION,
	cdr_voice_completed.ANMRECDAT ,
	cdr_voice_completed.EVENTSRECD ,
	cdr_voice_completed.MCC,
	cdr_voice_completed.MNC ,
	cdr_voice_completed.CAUSEINDCAUSEVALUE,
	cdr_voice_completed.MOCALL,
	cdr_voice_completed.LASTERBCSM,
	gm_country_code_mapping.country_Code AS COUNTRY_CODE
	FROM cdr_voice_completed 
	INNER JOIN report_metadata 
	ON (report_metadata.IMSI = cdr_voice_completed.CALLEDNUMBER
		or report_metadata.IMSI = cdr_voice_completed.CALLINGNUMBER)
	left join gm_country_code_mapping on report_metadata.ACCOUNT_COUNTRIE=gm_country_code_mapping.account
	WHERE date(cdr_voice_completed.ANMRECDAT) = start_date
	and report_metadata.MNO_ACCOUNTID=in_account_id;
	

	CALL `gm_utility_get__wholesale_plan_history`(in_start_date);

	-- preparing the data from merging the both table complete and incomplete	
	DROP  TEMPORARY TABLE if EXISTS temp_voice;
	CREATE TEMPORARY TABLE temp_voice
	SELECT * FROM temp_voice_complete                         
	UNION ALL 
	SELECT * FROM 	temp_voice_incomplete;

	-- final result report of the voice data 
	SELECT 
	temp_voice.ICCID  AS 'ICCID',
	temp_voice.IMSI AS 'IMSI',
	temp_voice.MSISDN AS 'MSISDN',
	-- WHOLESALE_PLAN_ID AS 'ACCOUNT ID',
	COUNTRY_CODE AS 'ACCOUNT ID',
	-- MNO_ACCOUNTID AS 'ACCOUNT ID',
	-- concat(@temp_date ,' - ',date_duration) AS 'BILLING CYCLE DATE',
	'5' AS 'BILLING CYCLE DATE',
	CALLINGNUMBER AS 'CALLING PARTY NUMBER',
	CALLEDNUMBER AS 'CALLED',
	CALLDURATION AS 'ANSWER DURATION',
	case when CALLDURATION=0  then CALLDURATION else CAST(CALLDURATION/60 AS UNSIGNED)*60 end as 'ANSWER DURATION ROUNDED',
	ANMRECDAT AS 'ORIGINATION DATE',
	concat(MCC,case when CHAR_LENGTH(MNC)=1 then  concat('0',MNC) else MNC end ) AS 'OPERATOR NETWORK',
	-- CAUSEINDCAUSEVALUE AS 'CALL TERMINATION REASON',
	case when MOCALL=0 and (CALLDURATION is null or CALLDURATION =0) 
			then 
			case 
					 when LASTERBCSM = 13 
						  then 'Busy'   
					 when LASTERBCSM = 14 
						  then 'Not answered'   
					 when LASTERBCSM = 18 
						  then 'Abandoned i.e. Caller cut the call'
					 when LASTERBCSM = 13 
						  then 'Busy'      
			end 
	     when MOCALL=1 and (CALLDURATION is null or CALLDURATION =0) 
			then 
			case  when LASTERBCSM = 4
						  then 'Route selection failure' 
					when LASTERBCSM = 5 
						  then 'Busy'
					when LASTERBCSM = 6
						  then 'Not answered'
					when LASTERBCSM = 10
						  then 'Abandoned i.e. Caller cut the call'
			end
	end AS 'CALL TERMINATION REASON',
	'Circuit Switched' as 'CALL TYPE',
	case when MOCALL=1 then 'MO' ELSE 'MT' end 'CALL DIRECTION',
	temp_wholesale_plan_history.plan AS PLAN,
	cdr_voice_tadig_codes.TC_TADIG_CODE as TAP_CODE
	FROM temp_voice
	left join temp_wholesale_plan_history on temp_wholesale_plan_history.IMSI=temp_voice.IMSI
	and (ANMRECDAT between  temp_wholesale_plan_history.start_date and temp_wholesale_plan_history.end_date)
	left join cdr_voice_tadig_codes on temp_voice.MCC=cdr_voice_tadig_codes.TC_MCC
	and case when CHAR_LENGTH(temp_voice.MNC)=1 then  concat('0',temp_voice.MNC) else temp_voice.MNC end = cdr_voice_tadig_codes.TC_MNC ;
-- 	GROUP BY IMSI,'ANSWER DURATION','ORIGINATION DATE';
	




END$$
DELIMITER ;


/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
