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

-- Dumping structure for procedure gmsa_reports.gm_data_report
DROP PROCEDURE IF EXISTS `gm_data_report`;
DELIMITER //
CREATE PROCEDURE `gm_data_report`(
	IN `in_start_date` varchar(50),
	IN `in_end_date` varchar(50),
	IN `in_account_id` VARCHAR(50)
)
    COMMENT 'gm_data_report_new'
BEGIN
 
  DECLARE date_duration VARCHAR(50);
  DECLARE start_date varchar(50);
  
   
   SET start_date:= CAST(in_start_date AS DATEtime);
   
--  SET @TEMP_BILLING_CYCLE = (SELECT YEAR(in_start_date) + MONTH(in_start_date) - year(NOW()));
 SET @TEMP_BILLING_CYCLE = (SELECT YEAR(in_start_date) + MONTH(in_start_date) - case when YEAR(in_start_date) < year(NOW()) then YEAR(in_start_date) ELSE YEAR(NOW()) END);

  
    SET date_duration= LAST_DAY(CONVERT( in_start_date, DATE ));
    SET @temp_date = DATE_SUB(in_start_date,INTERVAL DAYOFMONTH(in_start_date)-1 DAY);
  

    
    
  SET @row_number = 0;
  DROP TABLE IF EXISTS temp_first_wholesale_plan_history;
  CREATE TEMPORARY TABLE temp_first_wholesale_plan_history
  SELECT @row_number:= @row_number + 1 as row_id,IMSI,CREATE_DATE,NEW_VALUE FROM wholesale_plan_history ORDER BY IMSI,CREATE_DATE;

  
  DROP TABLE IF EXISTS temp_second_wholesale_plan_history;
  CREATE TEMPORARY TABLE temp_second_wholesale_plan_history
  SELECT row_id-1 as row_id,IMSI,CREATE_DATE,NEW_VALUE FROM temp_first_wholesale_plan_history;

  
  CREATE INDEX temp_idx_row_id_first_wholesale_history ON temp_first_wholesale_plan_history(row_id);
  CREATE INDEX temp_idx_row_id_second_wholesale_history ON temp_second_wholesale_plan_history(row_id);
    
  CREATE INDEX temp_idx_imsi_first_wholesale_history ON temp_first_wholesale_plan_history(IMSI);
  CREATE INDEX temp_idx_imsi_second_wholesale_history ON temp_second_wholesale_plan_history(IMSI);
  
    
  DROP TABLE IF EXISTS temp_wholesale_plan_history;
    CREATE TEMPORARY TABLE temp_wholesale_plan_history
  SELECT COALESCE(temp_first_wholesale_plan_history.CREATE_DATE,in_start_date) AS start_date,
      COALESCE(temp_second_wholesale_plan_history.CREATE_DATE,in_end_date) AS end_date,
      COALESCE(temp_second_wholesale_plan_history.IMSI,temp_first_wholesale_plan_history.IMSI) as imsi,
      COALESCE(temp_first_wholesale_plan_history.NEW_VALUE,temp_second_wholesale_plan_history.NEW_VALUE) as plan
  FROM temp_first_wholesale_plan_history 
  LEFT JOIN temp_second_wholesale_plan_history
    ON temp_first_wholesale_plan_history.row_id = temp_second_wholesale_plan_history.row_id
      AND temp_first_wholesale_plan_history.IMSI = temp_second_wholesale_plan_history.IMSI;
            
      
  CREATE INDEX temp_idx_imsi_wholesale_history ON temp_wholesale_plan_history(imsi);

  
  DROP TABLE IF EXISTS temp_cdr_data_return_table;
    CREATE TEMPORARY TABLE temp_cdr_data_return_table
  SELECT 
  report_metadata.ICCID AS ICCID,
  report_metadata.MSISDN AS MSISDN,
  report_metadata.IMSI AS IMSI,

   gm_country_code_mapping.country_Code AS SUPPLIER_ACCOUNT_ID ,
  
  @TEMP_BILLING_CYCLE AS BILLING_CYCLE_DATE,

  case when temp_wholesale_plan_history.IMSI=report_metadata.IMSI then  temp_wholesale_plan_history.plan ELSE report_metadata.WHOLE_SALE_NAME END AS PLAN,
   cdr_data_details_vw.START_TIME AS ORIGINATION_DATE,
   sum(cdr_data_details_vw.UPLINK_BYTES) AS TRANSMIT_BYTE,
   sum(cdr_data_details_vw.DOWNLINK_BYTES) AS RECEIVE_BYTES,
  sum(cdr_data_details_vw.TOTAL_BYTES) AS DATAUSAGE,
  
   cdr_data_details_vw.APN_ID AS APN,
  cdr_data_details_vw.SERVED_PDP_ADDRESS AS DEVICE_IP_ADDRESS,
  LEFT(report_metadata.MSISDN,6) AS OPERATOR_NETWORK,
  
  cdr_data_details_vw.RECORD_OPENING_TIME AS ORIGINATION_PLAN_DATE,
  sum(cdr_data_details_vw.DURATION_SEC) AS SESSION_DURATION,
   
  cdr_data_details_vw.CAUSE_FOR_CLOSING AS CALL_TERMINATION_REASON,
    cdr_data_details_vw.SERVICE_DATA_FLOW_ID AS RATING_STREAM_ID,
    
   cdr_data_details_vw.SERVING_NODE_IPADDR AS SERVING_SWITCH,
   case when cdr_data_details_vw.RAT_TYPE=1 then '3' when cdr_data_details_vw.RAT_TYPE=6 then '4' when cdr_data_details_vw.RAT_TYPE=2 then '2' else cdr_data_details_vw.RAT_TYPE end  AS CALL_TECHNOLOGY_TYPE,
   cdr_data_details_vw.PGW_ADDRESS AS GGSN_IP_ADDRESS,
   cdr_data_details_vw.LOCAL_SEQUENCE_NUMBER as Record_Sequence_Number
  from  ((report_metadata
  INNER JOIN cdr_data_details_vw
  ON report_metadata.IMSI = cdr_data_details_vw.SERVED_IMSI
  left join gm_country_code_mapping on report_metadata.ACCOUNT_COUNTRIE=gm_country_code_mapping.account
  left join temp_wholesale_plan_history on temp_wholesale_plan_history.IMSI=report_metadata.IMSI
  and (cdr_data_details_vw.START_TIME between  temp_wholesale_plan_history.start_date and temp_wholesale_plan_history.end_date)))
     WHERE 
      date(cdr_data_details_vw.START_TIME) = date(start_date)
     and report_metadata.ENT_ACCOUNTID=in_account_id
  group by cdr_data_details_vw.SERVED_IMSI, cdr_data_details_vw.CHARGING_ID,cdr_data_details_vw.SERVICE_DATA_FLOW_ID;


  SELECT temp_cdr_data_return_table.*,CASE WHEN ICCID IS NULL 
        OR MSISDN IS NULL
                OR IMSI IS NULL
                OR SUPPLIER_ACCOUNT_ID IS NULL
                OR BILLING_CYCLE_DATE IS NULL
                OR PLAN IS NULL
                OR ORIGINATION_DATE IS NULL
                OR TRANSMIT_BYTE IS NULL
                OR RECEIVE_BYTES IS NULL 
                OR DATAUSAGE IS NULL
                OR APN IS NULL
                OR DEVICE_IP_ADDRESS IS NULL
        OR OPERATOR_NETWORK IS NULL
        OR ORIGINATION_PLAN_DATE IS NULL
        OR SESSION_DURATION IS NULL
        OR CALL_TERMINATION_REASON IS NULL
        OR RATING_STREAM_ID IS NULL
        OR SERVING_SWITCH IS NULL
        OR CALL_TECHNOLOGY_TYPE IS NULL 
    THEN 1 ELSE 0 END AS MANDATORY_COL_NULL,
    CEIL(DATAUSAGE/1024) AS DATAUSAGE_ROUNDED FROM temp_cdr_data_return_table
   WHERE PLAN IS NOT NULL AND PLAN NOT IN ('null','NULL')
    ORDER BY MANDATORY_COL_NULL DESC;
END//
DELIMITER ;

-- Dumping structure for procedure gmsa_reports.gm_sms_delivered_report
DROP PROCEDURE IF EXISTS `gm_sms_delivered_report`;
DELIMITER //
CREATE PROCEDURE `gm_sms_delivered_report`(
	IN `in_start_date` varchar(50),
	IN `in_end_date` varchar(50),
	IN `in_account_id` VARCHAR(50)
)
    COMMENT 'gm_sms_delivered_report_new'
BEGIN
  
  
  
  
  
  
  
  
  
  
  
   
  DECLARE date_duration VARCHAR(50);
  DECLARE start_date varchar(50);

   SET start_date:= CAST(in_start_date AS DATEtime);
   
  -- SET @TEMP_BILLING_CYCLE_DATE = (SELECT YEAR(in_start_date)+MONTH(in_start_date)-YEAR(NOW()));
   SET @TEMP_BILLING_CYCLE_DATE = (SELECT YEAR(in_start_date) + MONTH(in_start_date) - case when YEAR(in_start_date) < year(NOW()) then YEAR(in_start_date) ELSE YEAR(NOW()) END);
    
    
  SET @row_number = 0;
  DROP TABLE IF EXISTS temp_first_wholesale_plan_history;
  CREATE TEMPORARY TABLE temp_first_wholesale_plan_history
  SELECT @row_number:= @row_number + 1 as row_id,IMSI,CREATE_DATE,NEW_VALUE FROM wholesale_plan_history ORDER BY IMSI,CREATE_DATE;

  
  DROP TABLE IF EXISTS temp_second_wholesale_plan_history;
  CREATE TEMPORARY TABLE temp_second_wholesale_plan_history
  SELECT row_id-1 as row_id,IMSI,CREATE_DATE,NEW_VALUE FROM temp_first_wholesale_plan_history;

  
  CREATE INDEX temp_idx_row_id_first_wholesale_history ON temp_first_wholesale_plan_history(row_id);
  CREATE INDEX temp_idx_row_id_second_wholesale_history ON temp_second_wholesale_plan_history(row_id);
    
  CREATE INDEX temp_idx_imsi_first_wholesale_history ON temp_first_wholesale_plan_history(IMSI);
  CREATE INDEX temp_idx_imsi_second_wholesale_history ON temp_second_wholesale_plan_history(IMSI);
  
    
  DROP TABLE IF EXISTS temp_wholesale_plan_history;
    CREATE TEMPORARY TABLE temp_wholesale_plan_history
  SELECT COALESCE(temp_first_wholesale_plan_history.CREATE_DATE,in_start_date) AS start_date,
      COALESCE(temp_second_wholesale_plan_history.CREATE_DATE,in_end_date) AS end_date,
      COALESCE(temp_second_wholesale_plan_history.IMSI,temp_first_wholesale_plan_history.IMSI) as imsi,
      COALESCE(temp_first_wholesale_plan_history.NEW_VALUE,temp_second_wholesale_plan_history.NEW_VALUE) as plan
  FROM temp_first_wholesale_plan_history 
  LEFT JOIN temp_second_wholesale_plan_history
    ON temp_first_wholesale_plan_history.row_id = temp_second_wholesale_plan_history.row_id
      AND temp_first_wholesale_plan_history.IMSI = temp_second_wholesale_plan_history.IMSI;
            
      
  CREATE INDEX temp_idx_imsi_wholesale_history ON temp_wholesale_plan_history(imsi);

  
    SET date_duration= LAST_DAY(CONVERT( in_start_date, DATE ));
    SET @temp_date = DATE_SUB(in_start_date,INTERVAL DAYOFMONTH(in_start_date)-1 DAY);
  
  
  
  DROP TABLE IF EXISTS temp_cdr_sms_delivered_return_table;
    CREATE TEMPORARY TABLE temp_cdr_sms_delivered_return_table
    SELECT 
    report_metadata.ICCID AS ICCID,
  report_metadata.MSISDN AS MSISDN,
  report_metadata.IMSI AS IMSI,
   gm_country_code_mapping.country_Code AS SUPPLIER_ACCOUNT_ID ,
   
   @TEMP_BILLING_CYCLE_DATE AS BILLING_CYCLE_DATE,
   
  cdr_sms_details.SMS_TYPE AS CALL_DIRECTION,
  case when temp_wholesale_plan_history.IMSI=report_metadata.IMSI then  temp_wholesale_plan_history.plan ELSE report_metadata.WHOLE_SALE_NAME END AS PLAN,
   -- temp_wholesale_plan_history.plan AS PLAN,
   cdr_sms_details.SENT_TIME AS ORIGINATION_DATE,
   case when cdr_sms_details.SMS_TYPE='MO' then cdr_sms_details.ORIGINATION_GT
  when cdr_sms_details.SMS_TYPE='MT' then cdr_sms_details.DESTINATION_GT 
  else NULL end AS SERVING_SWITCH,
  cdr_sms_details.SOURCE AS ORIGINATION_ADDRESS ,
  cdr_sms_details.DESTINATION AS DESTINATION_ADDRESS,
    
  
    LEFT(report_metadata.MSISDN,6) AS OPERATOR_NETWORK
  FROM (report_metadata
  INNER JOIN cdr_sms_details
  ON report_metadata.MSISDN = cdr_sms_details.SOURCE 
  OR report_metadata.MSISDN = cdr_sms_details.DESTINATION
  left join gm_country_code_mapping on report_metadata.ACCOUNT_COUNTRIE=gm_country_code_mapping.account
  left join temp_wholesale_plan_history on temp_wholesale_plan_history.IMSI=report_metadata.IMSI
  and (cdr_sms_details.FINAL_TIME between  temp_wholesale_plan_history.start_date and temp_wholesale_plan_history.end_date))  
   WHERE date(cdr_sms_details.FINAL_TIME)=date(start_date)
  and UPPER(cdr_sms_details.SMS_STATUS) = 'SUCCESS'
  and report_metadata.ENT_ACCOUNTID=in_account_id
    AND case when cdr_sms_details.SMS_TYPE='MO' then length(cdr_sms_details.DESTINATION) = 5
  when cdr_sms_details.SMS_TYPE='MT' then length(cdr_sms_details.SOURCE)=5 END;
  

  SELECT temp_cdr_sms_delivered_return_table.*,
  CASE WHEN ICCID IS NULL OR MSISDN IS NULL OR IMSI IS NULL OR SUPPLIER_ACCOUNT_ID IS NULL
      OR BILLING_CYCLE_DATE IS NULL OR CALL_DIRECTION IS NULL OR PLAN IS NULL OR ORIGINATION_DATE IS NULL
      OR SERVING_SWITCH IS NULL OR ORIGINATION_ADDRESS IS NULL OR DESTINATION_ADDRESS IS NULL 
            OR OPERATOR_NETWORK IS NULL
    THEN 1 ELSE 0 END AS MANDATORY_COL_NULL
  FROM temp_cdr_sms_delivered_return_table
    WHERE PLAN IS NOT NULL AND PLAN NOT IN ('null','NULL')
    ORDER BY MANDATORY_COL_NULL DESC;
END//
DELIMITER ;

-- Dumping structure for procedure gmsa_reports.gm_voice_report
DROP PROCEDURE IF EXISTS `gm_voice_report`;
DELIMITER //
CREATE PROCEDURE `gm_voice_report`(
	IN `in_start_date` varchar(50),
	IN `in_end_date` varchar(50),
	IN `in_account_id` VARCHAR(50)
)
    COMMENT 'gm_voice_report_new'
BEGIN
 
  
  
  
   
  
  
  
 
  
  
  
  DECLARE date_duration VARCHAR(50);
  DECLARE start_date varchar(50);

   SET start_date:= CAST(in_start_date AS DATEtime);
  
  
--  SET @TEMP_BILLING_CYCLE_DATE = (SELECT YEAR(in_start_date)+MONTH(in_start_date)-YEAR(NOW()));
 SET @TEMP_BILLING_CYCLE_DATE = (SELECT YEAR(in_start_date) + MONTH(in_start_date) - case when YEAR(in_start_date) < year(NOW()) then YEAR(in_start_date) ELSE YEAR(NOW()) END);
  
    SET date_duration= LAST_DAY(CONVERT( in_start_date, DATE ));
    SET @temp_date = DATE_SUB(in_start_date,INTERVAL DAYOFMONTH(in_start_date)-1 DAY);
  
   
  
  DROP  TEMPORARY TABLE if EXISTS temp_voice_incomplete;
  CREATE TEMPORARY TABLE temp_voice_incomplete
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
  gm_country_code_mapping.country_Code AS COUNTRY_CODE,
  report_metadata.WHOLE_SALE_NAME
  FROM cdr_voice_incompleted 
  INNER JOIN report_metadata 
  ON (report_metadata.MSISDN = cdr_voice_incompleted.CALLEDNUMBER
  or report_metadata.MSISDN = cdr_voice_incompleted.CALLINGNUMBER)
  left join gm_country_code_mapping on report_metadata.ACCOUNT_COUNTRIE=gm_country_code_mapping.account
  WHERE date(cdr_voice_incompleted.ANMRECDAT) = start_date
  and report_metadata.ENT_ACCOUNTID=in_account_id;
      
  
  DROP  TEMPORARY TABLE if EXISTS temp_voice_complete;
  CREATE TEMPORARY TABLE temp_voice_complete
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
  gm_country_code_mapping.country_Code AS COUNTRY_CODE,
  report_metadata.WHOLE_SALE_NAME
  FROM cdr_voice_completed 
  INNER JOIN report_metadata 
  ON (report_metadata.MSISDN = cdr_voice_completed.CALLEDNUMBER
    or report_metadata.MSISDN = cdr_voice_completed.CALLINGNUMBER)
  left join gm_country_code_mapping on report_metadata.ACCOUNT_COUNTRIE=gm_country_code_mapping.account
  WHERE date(cdr_voice_completed.ANMRECDAT) = start_date
  and report_metadata.ENT_ACCOUNTID=in_account_id;
  

    
    
  SET @row_number = 0;
  DROP TABLE IF EXISTS temp_first_wholesale_plan_history;
  CREATE TEMPORARY TABLE temp_first_wholesale_plan_history
  SELECT @row_number:= @row_number + 1 as row_id,IMSI,CREATE_DATE,NEW_VALUE FROM wholesale_plan_history ORDER BY IMSI,CREATE_DATE;

  
  DROP TABLE IF EXISTS temp_second_wholesale_plan_history;
  CREATE TEMPORARY TABLE temp_second_wholesale_plan_history
  SELECT row_id-1 as row_id,IMSI,CREATE_DATE,NEW_VALUE FROM temp_first_wholesale_plan_history;

  
  CREATE INDEX temp_idx_row_id_first_wholesale_history ON temp_first_wholesale_plan_history(row_id);
  CREATE INDEX temp_idx_row_id_second_wholesale_history ON temp_second_wholesale_plan_history(row_id);
    
  CREATE INDEX temp_idx_imsi_first_wholesale_history ON temp_first_wholesale_plan_history(IMSI);
  CREATE INDEX temp_idx_imsi_second_wholesale_history ON temp_second_wholesale_plan_history(IMSI);
  
    
  DROP TABLE IF EXISTS temp_wholesale_plan_history;
    CREATE TEMPORARY TABLE temp_wholesale_plan_history
  SELECT COALESCE(temp_first_wholesale_plan_history.CREATE_DATE,in_start_date) AS start_date,
      COALESCE(temp_second_wholesale_plan_history.CREATE_DATE,in_end_date) AS end_date,
      COALESCE(temp_second_wholesale_plan_history.IMSI,temp_first_wholesale_plan_history.IMSI) as imsi,
      COALESCE(temp_first_wholesale_plan_history.NEW_VALUE,temp_second_wholesale_plan_history.NEW_VALUE) as plan
  FROM temp_first_wholesale_plan_history 
  LEFT JOIN temp_second_wholesale_plan_history
    ON temp_first_wholesale_plan_history.row_id = temp_second_wholesale_plan_history.row_id
      AND temp_first_wholesale_plan_history.IMSI = temp_second_wholesale_plan_history.IMSI
  WHERE temp_first_wholesale_plan_history.CREATE_DATE <= in_end_date;
            
      
  CREATE INDEX temp_idx_imsi_wholesale_history ON temp_wholesale_plan_history(imsi);

  
  DROP  TEMPORARY TABLE if EXISTS temp_voice;
  CREATE TEMPORARY TABLE temp_voice
  SELECT * FROM temp_voice_complete                         
  UNION ALL 
  SELECT * FROM   temp_voice_incomplete;

  
  DROP TABLE IF EXISTS temp_voice_data_return_table;
    CREATE TEMPORARY TABLE temp_voice_data_return_table
    SELECT DISTINCT
  temp_voice.ICCID  AS 'ICCID',
  temp_voice.IMSI AS 'IMSI',
  temp_voice.MSISDN AS 'MSISDN',
  
  COUNTRY_CODE AS 'ACCOUNT ID',
  
  @TEMP_BILLING_CYCLE_DATE AS 'BILLING CYCLE DATE',
    
  CALLINGNUMBER AS 'CALLING PARTY NUMBER',
  CALLEDNUMBER AS 'CALLED',
  CALLDURATION AS 'ANSWER DURATION',
  CEILING(CALLDURATION/60) as 'ANSWER DURATION ROUNDED',
 -- case when CALLDURATION=0  then CALLDURATION else CAST(CALLDURATION/60 AS UNSIGNED)*60 end as 'ANSWER DURATION ROUNDED',
  ANMRECDAT AS 'ORIGINATION DATE',
    LEFT(MSISDN,6) AS 'OPERATOR NETWORK',
  
  
  case when MOCALL=0 OR MOCALL IS NULL 
      then LASTERBCSM
       when MOCALL=1 
      then COALESCE(LASTERBCSM,0)
  end AS 'CALL TERMINATION REASON',
  1 as 'CALL TYPE',
  case when MOCALL=1 then 'MO' ELSE 'MT' end 'CALL DIRECTION',
 case when temp_wholesale_plan_history.IMSI=temp_voice.IMSI then  temp_wholesale_plan_history.plan ELSE temp_voice.WHOLE_SALE_NAME END AS PLAN,
 -- temp_wholesale_plan_history.plan AS PLAN,
  cdr_voice_tadig_codes.TC_TADIG_CODE as TAP_CODE
  FROM temp_voice
  left join temp_wholesale_plan_history on temp_wholesale_plan_history.IMSI=temp_voice.IMSI
  and (ANMRECDAT between  temp_wholesale_plan_history.start_date and temp_wholesale_plan_history.end_date)
  left join cdr_voice_tadig_codes on temp_voice.MCC=cdr_voice_tadig_codes.TC_MCC
  and case when CHAR_LENGTH(temp_voice.MNC)=1 then  concat('0',temp_voice.MNC) else temp_voice.MNC END = case when CHAR_LENGTH(cdr_voice_tadig_codes.TC_MNC)=1 then  concat('0',cdr_voice_tadig_codes.TC_MNC) else cdr_voice_tadig_codes.TC_MNC end ;

  
   
  SELECT temp_voice_data_return_table.*,CASE WHEN ICCID IS NULL OR IMSI IS NULL OR MSISDN IS NULL OR `ACCOUNT ID` IS NULL OR `BILLING CYCLE DATE` IS NULL
    OR `CALLING PARTY NUMBER` IS NULL OR `CALLED` IS NULL OR `ANSWER DURATION` IS NULL OR `ANSWER DURATION ROUNDED` IS NULL 
        OR `ORIGINATION DATE` IS NULL OR `OPERATOR NETWORK` IS NULL OR `CALL TERMINATION REASON` IS NULL OR `CALL TYPE` IS NULL
    OR `CALL DIRECTION` IS NULL OR PLAN IS NULL OR TAP_CODE IS NULL
    THEN 1 ELSE 0 END AS MANDATORY_COL_NULL
  FROM temp_voice_data_return_table 
  WHERE PLAN IS NOT NULL AND PLAN NOT IN ('null','NULL')
  ORDER BY MANDATORY_COL_NULL DESC;



END//
DELIMITER ;

TRUNCATE cdr_voice_tadig_codes

INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('MYSYC',6020,502,152,'2013/04/04 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('USAGV',837,310,330,'2013/04/05 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('BLZK9',744,702,67,'2013/04/06 15:25','IRDB Team(Kamel)');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('SYCK9',280,633,1,'2013/04/07 15:25','IRDB Team(Kamel)');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('GMBK9',527,607,1,'2013/04/08 15:25','IRDB Team(Kamel)');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('SOMK9',5797,637,50,'2013/04/09 15:25','IRDB Team(Kamel)');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('BLRK8',5426,257,4,'2013/04/10 15:25','IRDB Team(Kamel)');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('MCOK8',5880,212,10,'2013/04/11 15:25','IRDB Team(Kamel)');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('MOZK9',5838,643,3,'2013/04/12 15:25','IRDB Team(Kamel)');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('HTIK9',5792,372,3,'2013/04/13 15:25','IRDB Team(Kamel)');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('LAOK9',5437,457,3,'2013/04/14 15:25','IRDB Team(Kamel)');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('BHSK8',5389,364,39,'2013/04/15 15:25','IRDB Team(Kamel)');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('TWNK9',5350,466,89,'2013/04/16 15:25','IRDB Team(Kamel)');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('BOLK9',5390,736,3,'2013/04/17 15:25','IRDB Team(Kamel)');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('PRYK8',847,744,4,'2013/04/18 15:25','IRDB Team(Kamel)');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('BFAK8',5450,613,1,'2013/04/19 15:25','IRDB Team(Kamel)');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('AGOK9',734,631,2,'2013/04/20 15:25','IRDB Team(Kamel)');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('ROMOV',32,226,1,'2013/04/21 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('TURVF',123,286,2,'2013/04/22 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('2018-03M3',5702,604,2,'2013/04/23 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('ESPOC',17,214,4,'2013/04/24 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('GHAOD',726,620,3,'2013/04/25 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('TZAOE',736,640,3,'2013/04/26 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('HKGK2',6015,454,35,'2013/04/27 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('USASL',6014,312,720,'2013/04/28 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('MEXNC',415,334,1,'2013/04/29 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('USAMF',410,310,280,'2013/04/30 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('REUMZ',6021,647,4,'2013/05/01 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('FINRL',63,244,5,'2013/05/02 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('FINES',63,244,21,'2013/05/03 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('FINTA',64,244,3,'2013/05/04 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('FIN2G',64,244,12,'2013/05/05 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('FINAM',65,244,14,'2013/05/06 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('LTUMT',68,246,2,'2013/05/07 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('ESTRE',72,248,2,'2013/05/08 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('RUS01',73,250,1,'2013/05/09 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('RUS07',77,250,7,'2013/05/10 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('RUSBD',87,250,99,'2013/05/11 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('UKRUM',88,255,1,'2013/05/12 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('UKRRS',90,255,2,'2013/05/13 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('UKRKS',90,255,3,'2013/05/14 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('BLRMD',92,257,1,'2013/05/15 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('MDAVX',93,259,1,'2013/05/16 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('POLKM',94,260,1,'2013/05/17 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('POL02',95,260,2,'2013/05/18 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('POL03',96,260,3,'2013/05/19 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('DEUD1',97,262,1,'2013/05/20 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('DEUD2',98,262,2,'2013/05/21 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('DEUE2',100,262,7,'2013/05/22 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('PRTTL',102,268,1,'2013/05/23 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('PRTOP',103,268,3,'2013/05/24 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('PRTTM',104,268,6,'2013/05/25 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('LUXPT',105,270,1,'2013/05/26 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('LUXTG',106,270,77,'2013/05/27 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('IRLEC',107,272,1,'2013/05/28 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('IRLDF',108,272,2,'2013/05/29 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('IRLME',109,272,3,'2013/05/30 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('ISLPS',110,274,1,'2013/05/31 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('ISLOC',5872,274,8,'2013/06/01 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('ALBAM',112,276,1,'2013/06/02 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('ALBVF',113,276,2,'2013/06/03 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('AAZVF',114,901,28,'2013/06/04 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('MLTTL',114,278,1,'2013/06/05 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('MLTGO',115,278,21,'2013/06/06 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('GEOGC',117,282,1,'2013/06/07 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('ARM01',119,283,1,'2013/06/08 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('BGR01',120,284,1,'2013/06/09 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('BGRCM',121,284,5,'2013/06/10 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('TURTC',122,286,1,'2013/06/11 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('TURTS',123,286,2,'2013/06/12 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('TURAC',124,286,4,'2013/06/13 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('TURIS',124,286,3,'2013/06/14 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('FROFT',125,288,1,'2013/06/15 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('SVNSM',126,293,40,'2013/06/16 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('SVNVG',128,293,70,'2013/06/17 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('MKDMM',129,294,1,'2013/06/18 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('LIEMK',130,295,5,'2013/06/19 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('BTNBM',131,402,11,'2013/06/20 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('BHRMV',133,426,2,'2013/06/21 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('TCDCT',136,622,1,'2013/06/22 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('SLVDC',138,706,2,'2013/06/23 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('GMBAC',139,607,2,'2013/06/24 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('CODCT',144,630,2,'2013/06/25 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('MNETM',145,297,2,'2013/06/26 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('GLP01',146,340,1,'2013/06/27 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('AZEAC',149,400,1,'2013/06/28 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('AZEBC',150,400,2,'2013/06/29 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('KAZKT',151,401,1,'2013/06/30 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('KAZKZ',152,401,2,'2013/07/01 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDA9',154,404,2,'2013/07/02 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDBL',155,404,3,'2013/07/03 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDF1',156,404,5,'2013/07/04 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('IND07',157,404,7,'2013/07/05 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDAT',159,404,10,'2013/07/06 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDE1',160,404,11,'2013/07/07 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDEH',161,404,12,'2013/07/08 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDSP',162,404,14,'2013/07/09 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDEK',165,404,19,'2013/07/10 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDBO',166,404,22,'2013/07/11 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDBI',167,404,24,'2013/07/12 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDBM',168,404,27,'2013/07/13 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDCC',169,404,30,'2013/07/14 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDMT',170,404,31,'2013/07/15 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDSC',172,404,40,'2013/07/16 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDRC',173,404,41,'2013/07/17 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDAC',174,404,42,'2013/07/18 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDBT',175,404,43,'2013/07/19 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDSK',176,404,44,'2013/07/20 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDJB',177,404,45,'2013/07/21 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDBK',178,404,46,'2013/07/22 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDJH',179,404,49,'2013/07/23 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDEU',182,404,56,'2013/07/24 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDH1',185,404,70,'2013/07/25 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDMP',186,404,78,'2013/07/26 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('LKADG',188,413,2,'2013/07/27 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('LBNFL',190,415,1,'2013/07/28 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('LBNLC',191,415,3,'2013/07/29 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('JORFL',192,416,1,'2013/07/30 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('JORMC',193,416,77,'2013/07/31 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('SYRSP',194,417,2,'2013/08/01 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('KWTMT',195,419,2,'2013/08/02 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('KWTNM',196,419,3,'2013/08/03 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('SAUAJ',197,420,1,'2013/08/04 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('YEMSA',198,421,1,'2013/08/05 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('YEMSP',199,421,2,'2013/08/06 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('OMNGT',200,422,2,'2013/08/07 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('ARETC',201,424,2,'2013/08/08 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('ISR01',202,425,1,'2013/08/09 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('PSEJE',203,425,5,'2013/08/10 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('QATQT',205,427,1,'2013/08/11 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('NPLNM',206,429,1,'2013/08/12 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('UZBDU',208,434,4,'2013/08/13 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('UZB05',209,434,5,'2013/08/14 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('TKMBC',210,438,1,'2013/08/15 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('VNMVI',211,452,2,'2013/08/16 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('HKGNW',216,454,10,'2013/08/17 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('HKGTC',216,454,0,'2013/08/18 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('HKGHT',213,454,4,'2013/08/19 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('HKGH3',213,454,3,'2013/08/20 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('HKGSM',214,454,6,'2013/08/21 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('HKGMC',216,454,16,'2013/08/22 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('HKGM3',216,454,19,'2013/08/23 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('MACHT',219,455,3,'2013/08/24 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('KHMGM',220,456,1,'2013/08/25 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('KHMSM',5597,456,2,'2013/08/26 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('CHNCT',223,460,0,'2013/08/27 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('CHNTD',223,460,7,'2013/08/28 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('CHNCM',223,460,2,'2013/08/29 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('CHNCU',224,460,1,'2013/08/30 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('TWNLD',226,466,92,'2013/08/31 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('TWNPC',227,466,97,'2013/09/01 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('BGDGP',229,470,1,'2013/09/02 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('MDV01',230,472,1,'2013/09/03 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('MYSBC',231,502,12,'2013/09/04 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('MYSMT',233,502,16,'2013/09/05 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('MYSMR',235,502,13,'2013/09/06 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('MYSCC',235,502,19,'2013/09/07 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('AUSOP',236,505,2,'2013/09/08 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('AUSVF',237,505,3,'2013/09/09 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('NGAMN',275,621,30,'2013/09/10 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('IDNIM',239,510,21,'2013/09/11 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('IDNSL',239,510,1,'2013/09/12 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('IDNTS',241,510,10,'2013/09/13 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('IDNEX',242,510,11,'2013/09/14 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('PHLGT',244,515,2,'2013/09/15 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('PHLSR',245,515,3,'2013/09/16 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('THAWP',5847,520,18,'2013/09/17 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('SGPML',251,525,2,'2013/09/18 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('SGPST',251,525,1,'2013/09/19 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('SGPM1',252,525,3,'2013/09/20 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('SGPSH',254,525,5,'2013/09/21 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('BRNDS',255,528,11,'2013/09/22 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('NZLBS',256,530,1,'2013/09/23 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('FJIVF',257,542,1,'2013/09/24 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('EGYAR',258,602,1,'2013/09/25 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('EGYMS',259,602,2,'2013/09/26 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('MARMT',260,604,0,'2013/09/27 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('MARM1',261,604,1,'2013/09/28 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('TUNTT',262,605,2,'2013/09/29 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('SENAZ',263,608,1,'2013/09/30 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('SENSG',264,608,2,'2013/10/01 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('MRTMM',265,609,10,'2013/10/02 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('CIVTL',269,612,5,'2013/10/03 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('TGOTC',271,615,1,'2013/10/04 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('MUSCP',272,617,1,'2013/10/05 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('MUSEM',273,617,10,'2013/10/06 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('GHASC',274,620,1,'2013/10/07 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('CMRMT',276,624,1,'2013/10/08 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('GAB01',277,628,1,'2013/10/09 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('GABTL',277,628,2,'2013/10/10 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('GHAGM',5795,620,7,'2013/10/11 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('COGCT',279,629,1,'2013/10/12 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('SYCCW',280,633,1,'2013/10/13 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('RUSNW',74,250,2,'2013/10/14 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('SYCAT',281,633,10,'2013/10/15 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('SUDMO',282,634,1,'2013/10/16 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('RWAMN',283,635,10,'2013/10/17 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('KENSA',284,639,2,'2013/10/18 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('KENKC',285,639,3,'2013/10/19 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('MMRVG',5987,414,9,'2013/10/20 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('K0001',5988,221,2,'2013/10/21 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('USABG',5989,311,810,'2013/10/22 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('USASV',320,312,530,'2013/10/23 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('USAVT',5991,311,990,'2013/10/24 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('GBRRT',5995,234,22,'2013/10/25 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('EGYTE',5996,602,4,'2013/10/26 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('HKGCU',685,454,7,'2013/10/27 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('CHNDX',5916,460,11,'2013/10/28 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('USAMH',5998,313,70,'2013/10/29 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('AAMT1',5999,242,99,'2013/10/30 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('CANMM',5589,302,690,'2013/10/31 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('USA6G',6002,312,420,'2013/11/01 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('SOMST',5800,637,82,'2013/11/02 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('USAT0',842,311,210,'2013/11/03 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('USA1E',6003,310,130,'2013/11/04 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('DNK42',6004,238,42,'2013/11/05 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('TZAMB',287,640,2,'2013/11/06 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('TZACT',288,640,5,'2013/11/07 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('THACT',250,520,0,'2013/11/08 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('UGAMN',290,641,10,'2013/11/09 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('BDITL',5622,642,82,'2013/11/10 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('MOZ01',293,643,1,'2013/11/11 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('ZMBCE',294,645,1,'2013/11/12 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('MDGCO',295,646,1,'2013/11/13 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('MDGAN',296,646,2,'2013/11/14 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('SVNMT',127,293,41,'2013/11/15 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('REU02',297,647,0,'2013/11/16 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('FRARE',298,647,10,'2013/11/17 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('ZWEN1',299,648,1,'2013/11/18 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('ZWEN3',300,648,3,'2013/11/19 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('SWETR',58,240,1,'2013/11/20 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('ZWEET',301,648,4,'2013/11/21 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('NAM01',302,649,1,'2013/11/22 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('BWAGA',303,652,1,'2013/11/23 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('BWAVC',304,652,2,'2013/11/24 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('ZAFMN',306,655,10,'2013/11/25 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('SLVTP',307,706,1,'2013/11/26 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('PERTM',308,716,10,'2013/11/27 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('CHLMV',309,730,1,'2013/11/28 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('MLTMA',5878,901,19,'2013/11/29 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('MNEPM',314,297,1,'2013/11/30 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('CANRW',316,302,720,'2013/12/01 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('CANMC',316,302,370,'2013/12/02 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('ITAGT',5937,901,26,'2013/12/03 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('MOZVT',5838,643,3,'2013/12/04 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('USAW4',318,310,240,'2013/12/05 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('USAW5',318,310,250,'2013/12/06 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('USA31',318,310,310,'2013/12/07 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('FRA09',13,208,9,'2013/12/08 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('USAW0',318,310,200,'2013/12/09 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('USASC',318,310,490,'2013/12/10 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('USAW6',318,310,260,'2013/12/11 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('USA27',318,310,270,'2013/12/12 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('USA16',318,310,160,'2013/12/13 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('USANC',320,316,10,'2013/12/14 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('UKRAS',134,255,6,'2013/12/15 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('BHRBT',326,426,1,'2013/12/16 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDHM',332,404,20,'2013/12/17 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('URYAN',5262,748,1,'2013/12/18 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('VNMMO',333,452,1,'2013/12/19 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('HKGPP',335,454,12,'2013/12/20 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('TWNFE',402,466,1,'2013/12/21 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('USAAT',410,310,380,'2013/12/22 15:25','datamgmt');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('USABS',410,310,150,'2013/12/23 15:25','datamgmt');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('USACG',410,310,410,'2013/12/24 15:25','datamgmt');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('USAPB',410,310,170,'2013/12/25 15:25','datamgmt');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('AUSTA',405,505,1,'2013/12/26 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('PERNC',406,716,7,'2013/12/27 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('PAKMK',408,410,1,'2013/12/28 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('KORSK',413,450,5,'2013/12/29 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('BRANC',416,724,0,'2013/12/30 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('ARGNC',417,722,2,'2013/12/31 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('MNGMC',420,428,99,'2014/01/01 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('ISRCL',421,425,2,'2014/01/02 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDA1',422,404,92,'2014/01/03 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDA3',424,404,98,'2014/01/04 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('GBRHU',438,234,20,'2014/01/05 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('ISLVW',439,274,4,'2014/01/06 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('CMR02',442,624,2,'2014/01/07 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDID',443,404,4,'2014/01/08 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('KGZ01',444,437,1,'2014/01/09 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('ZAFVC',305,655,1,'2014/01/10 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('ZAFCC',448,655,7,'2014/01/11 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('SWZMN',454,653,10,'2014/01/12 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('PANCW',458,714,1,'2014/01/13 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('ARGTP',459,722,34,'2014/01/14 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('DZAOT',460,603,2,'2014/01/15 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('ARMKT',461,283,4,'2014/01/16 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('BOLME',464,736,2,'2014/01/17 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('BENSP',465,616,3,'2014/01/18 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDA7',472,404,95,'2014/01/19 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDA2',473,404,90,'2014/01/20 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDA5',474,404,96,'2014/01/21 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDA6',475,404,97,'2014/01/22 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDA8',476,404,93,'2014/01/23 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDA4',477,404,94,'2014/01/24 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('BFACT',481,613,2,'2014/01/25 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('BRARN',503,724,2,'2014/01/26 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('GRLTG',504,290,1,'2014/01/27 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('PHLNC',507,515,88,'2014/01/28 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('CPVCV',508,625,1,'2014/01/29 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('DZAA1',509,603,1,'2014/01/30 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('MEXTL',513,334,20,'2014/01/31 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('JPNJP',514,440,20,'2014/02/01 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('KORKF',515,450,8,'2014/02/02 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('SYR01',517,417,1,'2014/02/03 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('JAMDC',518,338,50,'2014/02/04 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('ATG03',519,344,3,'2014/02/05 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('LAOTL',520,457,8,'2014/02/06 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('IRNKI',523,432,14,'2014/02/07 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('MRTMT',525,609,1,'2014/02/08 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('TZAVC',526,640,4,'2014/02/09 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('GMB01',527,607,1,'2014/02/10 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('MCOM1',5962,212,1,'2014/02/11 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('CUB01',531,368,1,'2014/02/12 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('GNQ01',533,627,1,'2014/02/13 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('BGRVA',140,284,3,'2014/02/14 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('CODVC',534,630,1,'2014/02/15 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('ARETH',546,901,5,'2014/02/16 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('BLR02',455,257,2,'2014/02/17 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('FRATK',599,547,20,'2014/02/18 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('ITAH3',605,222,99,'2014/02/19 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('DNKHU',614,238,6,'2014/02/20 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('SWEHU',616,240,2,'2014/02/21 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('RUST2',622,250,20,'2014/02/22 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('PRT05',626,268,5,'2014/02/23 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('LIEVE',628,295,2,'2014/02/24 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('FRAF4',633,340,20,'2014/02/25 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('BRBCW',635,342,600,'2014/02/26 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('CYMCW',636,346,140,'2014/02/27 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('ANTTC',637,362,51,'2014/02/28 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('ANTCT',638,362,69,'2014/03/01 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDWB',657,404,74,'2014/03/02 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDIH',663,404,82,'2014/03/03 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDIR',665,404,87,'2014/03/04 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDIU',667,404,89,'2014/03/05 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('PAKUF',668,410,3,'2014/03/06 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('AFGAW',669,412,1,'2014/03/07 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('LKA71',670,413,1,'2014/03/08 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('MMRPT',671,414,1,'2014/03/09 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('CIV03',268,612,3,'2014/03/10 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('IRQAC',672,418,5,'2014/03/11 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('IRQOR',673,418,30,'2014/03/12 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('IRQAT',673,418,20,'2014/03/13 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('IRN11',677,432,11,'2014/03/14 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('UZB07',679,434,7,'2014/03/15 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('TJKIT',681,436,2,'2014/03/16 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('CYPCT',116,280,1,'2014/03/17 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('TJK01',681,436,1,'2014/03/18 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('TJKBM',683,436,4,'2014/03/19 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('TJK91',684,436,5,'2014/03/20 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('BGDAK',690,470,2,'2014/03/21 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('BGDBL',691,470,3,'2014/03/22 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('MYSMI',693,502,18,'2014/03/23 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('PHLDG',697,515,5,'2014/03/24 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('MNPPT',5447,310,110,'2014/03/25 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('MDAUN',5498,259,5,'2014/03/26 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('MNGSK',5851,428,1,'2014/03/27 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('NORNN',62,242,5,'2014/03/28 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('TELA1',6006,901,46,'2014/03/29 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('AZENT',149,400,6,'2014/03/30 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('CHNCN',224,460,9,'2014/03/31 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('DEUE1',100,262,3,'2014/04/01 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('GNBSB',5621,632,2,'2014/04/02 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('KAZAL',5869,401,7,'2014/04/03 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('PNGTM',5966,537,2,'2014/04/04 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('REUFM',739,647,3,'2014/04/05 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('USAEZ',5965,310,990,'2014/04/06 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('NLDLM',5964,204,9,'2014/04/07 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('BHSNC',5963,364,49,'2014/04/08 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('LBRCM',5438,618,4,'2014/04/09 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('CODSA',5832,630,89,'2014/04/10 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('ZAFMM',306,655,12,'2014/04/11 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('AAMOM',5979,901,27,'2014/04/12 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('BELTN',5733,206,5,'2014/04/13 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('GBRKY',5961,234,57,'2014/04/14 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('HUND1',5972,216,3,'2014/04/15 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('IRNST',5867,432,1,'2014/04/16 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('IRQFL',5973,418,66,'2014/04/17 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('ITAFM',5974,222,50,'2014/04/18 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('PRTEP',104,268,80,'2014/04/19 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('ROUIM',5970,226,13,'2014/04/20 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('RUS50',5977,250,50,'2014/04/21 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('RUSTM',5978,250,62,'2014/04/22 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('SWEIB',5969,240,23,'2014/04/23 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('SWETG',60,240,6,'2014/04/24 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('SWZ02',5975,653,2,'2014/04/25 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('USA4G',5971,311,580,'2014/04/26 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('USA55',5976,312,630,'2014/04/27 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('NPLST',5984,429,4,'2014/04/28 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('ZAF38',5985,655,38,'2014/04/29 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('NLDT1',602,204,2,'2014/04/30 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('CYPSC',788,280,10,'2014/05/01 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('MDVWM',791,472,2,'2014/05/02 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('USACB',795,310,420,'2014/05/03 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('CHLB2',797,730,7,'2014/05/04 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('CHLTM',797,730,2,'2014/05/05 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('BRNBR',798,528,2,'2014/05/06 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('ESTEM',71,248,1,'2014/05/07 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('ESTRB',522,248,3,'2014/05/08 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('SLVTM',799,706,3,'2014/05/09 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('NORMC',801,901,12,'2014/05/10 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('PRYHT',807,744,2,'2014/05/11 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('SDNBT',809,634,2,'2014/05/12 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('USACI',827,310,450,'2014/05/13 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('FINTF',66,244,91,'2014/05/14 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('USACW',830,310,690,'2014/05/15 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('GUMHT',845,310,470,'2014/05/16 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('ATGCW',846,344,920,'2014/05/17 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('PRYTC',847,744,4,'2014/05/18 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('GTMSC',848,704,1,'2014/05/19 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('URYAM',850,748,10,'2014/05/20 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('COLCM',851,732,101,'2014/05/21 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('HND02',854,708,2,'2014/05/22 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('NICEN',858,710,21,'2014/05/23 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('LKAHT',860,413,8,'2014/05/24 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('JORUM',861,416,3,'2014/05/25 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('JORXT',862,416,2,'2014/05/26 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('MOZVC',863,643,4,'2014/05/27 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('AFGTD',865,412,20,'2014/05/28 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('TLSTL',867,514,2,'2014/05/29 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('DJIDJ',868,638,1,'2014/05/30 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('IND06',1000,404,29,'2014/05/31 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('IND01',1002,404,37,'2014/06/01 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('IND08',1003,404,33,'2014/06/02 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('IND05',1006,404,28,'2014/06/03 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('IND03',1009,404,17,'2014/06/04 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('IND02',1010,404,35,'2014/06/05 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('IND04',1011,404,25,'2014/06/06 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('MWICT',5023,650,10,'2014/06/07 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('MEXMS',5025,334,30,'2014/06/08 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('AUTHU',5028,232,10,'2014/06/09 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('TGOTL',5051,615,3,'2014/06/10 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('NGAET',5054,621,20,'2014/06/11 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('GABCT',5055,628,3,'2014/06/12 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('ZMB02',5056,645,2,'2014/06/13 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('BRATM',5060,724,31,'2014/06/14 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('COLCO',5062,732,111,'2014/06/15 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('MKDCC',5131,294,2,'2014/06/16 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('ETH01',5142,636,1,'2014/06/17 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('ARGCM',5201,722,310,'2014/06/18 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('HNDME',5203,708,1,'2014/06/19 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('HNDDC',5203,708,40,'2014/06/20 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('LBY01',5205,606,1,'2014/06/21 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('CRICR',5252,712,1,'2014/06/22 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('JPNDO',5283,440,10,'2014/06/23 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('NERCT',5284,614,2,'2014/06/24 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('SAUET',5324,420,3,'2014/06/25 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('OMNNT',5344,422,3,'2014/06/26 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('VGBCC',5345,348,570,'2014/06/27 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('VNMVT',5346,452,4,'2014/06/28 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('TWNTG',5350,466,89,'2014/06/29 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('DMACW',5353,366,110,'2014/06/30 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('GRDCW',5354,352,110,'2014/07/01 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('MSRCW',5355,354,860,'2014/07/02 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('KNACW',5356,356,110,'2014/07/03 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('TTO12',5360,374,12,'2014/07/04 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('PRYNP',5367,744,5,'2014/07/05 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('SVKET',5373,231,2,'2014/07/06 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('IDN89',5385,510,89,'2014/07/07 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('ARM05',5387,283,5,'2014/07/08 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('AZEAF',5388,400,4,'2014/07/09 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('BHSBH',5389,364,39,'2014/07/10 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('CIV02',5392,612,2,'2014/07/11 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('GLPDT',5394,340,8,'2014/07/12 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('PAKTP',5397,410,6,'2014/07/13 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('POLP4',5398,260,6,'2014/07/14 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('BGDTT',5400,470,4,'2014/07/15 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('AREDU',5402,424,3,'2014/07/16 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('LVABT',5403,247,5,'2014/07/17 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('NPLM2',5404,429,2,'2014/07/18 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDRM',184,404,67,'2014/07/19 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('SVKO2',5406,231,6,'2014/07/20 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('SLVTS',5407,706,4,'2014/07/21 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('ARGTM',5408,722,7,'2014/07/22 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('PERMO',5409,716,6,'2014/07/23 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('COLTM',5410,732,123,'2014/07/24 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('URYTM',5411,748,7,'2014/07/25 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('LBR07',5414,618,7,'2014/07/26 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('JAMCW',5415,338,180,'2014/07/27 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('NAM03',5418,649,3,'2014/07/28 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('IRQKK',675,418,40,'2014/07/29 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('CHEOA',5419,901,15,'2014/07/30 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('ISLTL',111,274,2,'2014/07/31 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('PLWPM',5420,552,80,'2014/08/01 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('EGYEM',5422,602,3,'2014/08/02 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('BRAV1',5424,724,10,'2014/08/03 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('BRAV2',5424,724,6,'2014/08/04 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('BRAV3',5424,724,11,'2014/08/05 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('BGDWT',690,470,7,'2014/08/06 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('GUYUM',5430,738,1,'2014/08/07 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('LBRLC',5438,618,1,'2014/08/08 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('KGZMC',5440,437,5,'2014/08/09 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('ECUOT',5442,740,0,'2014/08/10 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('ISLNO',5444,274,11,'2014/08/11 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('SMOSM',5449,292,1,'2014/08/12 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('BFAON',5450,613,1,'2014/08/13 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('GEOMT',5451,282,4,'2014/08/14 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('IRNRI',5452,432,32,'2014/08/15 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('AIACW',5453,365,840,'2014/08/16 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('LCACW',5454,358,110,'2014/08/17 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('VCTCW',5455,360,110,'2014/08/18 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('TCACW',5456,376,350,'2014/08/19 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('VGBCW',5457,348,170,'2014/08/20 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('PNGDP',5458,537,3,'2014/08/21 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('CHLSM',5459,730,3,'2014/08/22 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('NICMS',5460,710,300,'2014/08/23 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('USAPU',5461,310,140,'2014/08/24 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('NORAM',5462,901,14,'2014/08/25 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('MDGTM',5463,646,4,'2014/08/26 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('TTODL',5465,374,130,'2014/08/27 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('LKACT',189,413,3,'2014/08/28 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('GBRAJ',5466,234,3,'2014/08/29 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INTJS',5467,901,16,'2014/08/30 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('LTU03',521,246,3,'2014/08/31 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('USAJS',5467,310,650,'2014/09/01 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('SLEAC',5468,619,5,'2014/09/02 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('IND09',5471,404,91,'2014/09/03 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('LVABC',70,247,2,'2014/09/04 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('LVALM',69,247,1,'2014/09/05 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('MACCT',218,455,1,'2014/09/06 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('IRNMI',5476,432,35,'2014/09/07 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('BWABC',5477,652,4,'2014/09/08 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('AFGAR',5479,412,40,'2014/09/09 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('MKDNO',5131,294,3,'2014/09/10 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('VENMS',5482,734,4,'2014/09/11 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('SRBNO',5483,220,5,'2014/09/12 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('MLI01',266,610,1,'2014/09/13 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('GBRGT',52,234,55,'2014/09/14 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('ANDMA',411,213,3,'2014/09/15 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('BLRBT',5426,257,4,'2014/09/16 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('YUGTS',445,220,3,'2014/09/17 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('GIBGT',101,266,1,'2014/09/18 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('DZAWT',706,603,3,'2014/09/19 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('PAKPL',5261,410,4,'2014/09/20 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('MNEMT',5423,297,3,'2014/09/21 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('BIHMS',23,218,5,'2014/09/22 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('BIHER',22,218,3,'2014/09/23 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('GEOMA',118,282,2,'2014/09/24 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('MDAMC',143,259,2,'2014/09/25 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('SURTG',524,746,2,'2014/09/26 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('LTUOM',67,246,1,'2014/09/27 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('SLBSI',700,540,1,'2014/09/28 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('NCLPT',703,546,1,'2014/09/29 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('TUNTA',707,605,3,'2014/09/30 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('MLI02',708,610,2,'2014/10/01 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('NERTL',713,614,3,'2014/10/02 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('BENLI',716,616,1,'2014/10/03 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('BEN02',717,616,2,'2014/10/04 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('SLECT',722,619,1,'2014/10/05 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('GHAGT',725,620,2,'2014/10/06 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('GHAMT',726,620,3,'2014/10/07 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('NGAGM',728,621,50,'2014/10/08 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('CAFAT',729,623,1,'2014/10/09 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('CAF02',730,623,2,'2014/10/10 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('CAF03',731,623,3,'2014/10/11 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('COGLB',732,629,10,'2014/10/12 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('AGOUT',734,631,2,'2014/10/13 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('TZAZN',736,640,3,'2014/10/14 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('ZMBCZ',738,645,3,'2014/10/15 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('REUOT',739,647,2,'2014/10/16 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('MWICP',740,650,1,'2014/10/17 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('LSOVL',741,651,1,'2014/10/18 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('LSOET',742,651,2,'2014/10/19 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('COMHR',743,654,1,'2014/10/20 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('BLZ67',744,702,67,'2014/10/21 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('GTMTG',745,704,3,'2014/10/22 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('BRASP',503,724,3,'2014/10/23 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('BRACS',503,724,4,'2014/10/24 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('VEND2',750,734,2,'2014/10/25 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('BOLNT',752,736,1,'2014/10/26 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('ECUPG',753,740,1,'2014/10/27 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('PRYVX',754,744,1,'2014/10/28 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('BRACL',781,724,5,'2014/10/29 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('PAKWA',782,410,7,'2014/10/30 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('IRLH3',108,272,5,'2014/10/31 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('GTMCM',785,704,2,'2014/11/01 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('HRVT2',786,219,2,'2014/11/02 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('AUTCA',5028,232,5,'2014/11/03 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('LUXVM',5282,270,99,'2014/11/04 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('LKAAT',5488,413,5,'2014/11/05 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('NZLNH',5489,530,24,'2014/11/06 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('DOMCL',5490,370,2,'2014/11/07 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('UKRUT',5491,255,7,'2014/11/08 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('AFGEA',5492,412,50,'2014/11/09 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('BTNTC',5493,402,77,'2014/11/10 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDIM',5494,405,799,'2014/11/11 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDIB',5495,405,70,'2014/11/12 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('SURDC',5499,746,3,'2014/11/13 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('LBYLM',5500,606,0,'2014/11/14 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('CHNMM',223,460,13,'2014/11/15 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('USAGM',6011,310,970,'2014/11/16 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('LAOET',5405,457,2,'2014/11/17 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('CANTE',6008,302,760,'2014/11/18 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('BMU01',5871,901,18,'2014/11/19 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('ISRPL',5501,425,3,'2014/11/20 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('ALBEM',5505,276,3,'2014/11/21 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('VUTDP',5506,541,5,'2014/11/22 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('GIN03',5507,611,3,'2014/11/23 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('SAUZN',5509,420,4,'2014/11/24 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('DOMAC',5513,370,4,'2014/11/25 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('FJIDP',5518,542,2,'2014/11/26 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('CPVTM',5519,625,2,'2014/11/27 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('GHAZN',726,620,6,'2014/11/28 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('TONDP',5529,539,88,'2014/11/29 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('NEROR',5530,614,4,'2014/11/30 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDTD',5546,405,29,'2014/12/01 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDT8',5547,405,46,'2014/12/02 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDTH',5548,405,31,'2014/12/03 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDT6',5549,405,37,'2014/12/04 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDTG',5550,405,30,'2014/12/05 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDTM',5551,405,39,'2014/12/06 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDT5',5552,405,38,'2014/12/07 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDT2',5553,405,44,'2014/12/08 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDT3',5554,405,35,'2014/12/09 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDTP',5555,405,42,'2014/12/10 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDT0',5556,405,25,'2014/12/11 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDT1',5557,405,34,'2014/12/12 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDT4',5558,405,32,'2014/12/13 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDTB',5559,405,27,'2014/12/14 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDTK',5560,405,36,'2014/12/15 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDTR',5561,405,43,'2014/12/16 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDT7',5562,405,45,'2014/12/17 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDT9',5563,405,47,'2014/12/18 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDTO',5564,405,41,'2014/12/19 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('KGZNT',5565,437,9,'2014/12/20 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('PRICL',5566,330,110,'2014/12/21 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('KENTK',5567,639,7,'2014/12/22 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('KWTKT',5568,419,4,'2014/12/23 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('MLTMM',5570,278,77,'2014/12/24 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('KENEC',285,639,5,'2014/12/25 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('PANDC',5573,714,4,'2014/12/26 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('IND19',5574,405,800,'2014/12/27 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('IND18',5576,405,811,'2014/12/28 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('IND21',5577,405,805,'2014/12/29 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('IND20',5578,405,809,'2014/12/30 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('IND22',5579,405,803,'2014/12/31 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('IND23',5580,405,801,'2015/01/01 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('GMBCM',5583,607,3,'2015/01/02 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('CIVOR',5584,612,6,'2015/01/03 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('KHMSC',5587,456,5,'2015/01/04 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('CANTS',5588,302,220,'2015/01/05 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('CANBM',5589,302,610,'2015/01/06 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('ALBM4',5781,276,4,'2015/01/07 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('GINAG',5591,611,4,'2015/01/08 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDIT',5593,405,852,'2015/01/09 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDIO',5594,405,850,'2015/01/10 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('TCDML',5595,622,3,'2015/01/11 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('KHML1',5597,456,6,'2015/01/12 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('AAAWL',5598,901,21,'2015/01/13 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('NZLTM',5599,530,5,'2015/01/14 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('CIVCM',5600,612,4,'2015/01/15 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('PNGPM',5601,537,1,'2015/01/16 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('VENMV',5602,734,6,'2015/01/17 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDIK',5603,405,848,'2015/01/18 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDIW',5604,405,853,'2015/01/19 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDAM',5605,405,845,'2015/01/20 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDIE',5606,405,849,'2015/01/21 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDIJ',5607,405,846,'2015/01/22 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('MNGMN',5610,428,88,'2015/01/23 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('SVNT2',5611,293,64,'2015/01/24 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('IND24',5613,405,804,'2015/01/25 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('ROM05',5614,226,5,'2015/01/26 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('KHMVC',5616,456,8,'2015/01/27 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('COGWC',279,629,7,'2015/01/28 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('BRATC',5424,724,23,'2015/01/29 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDE4',163,404,15,'2015/01/30 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('BDIET',5622,642,1,'2015/01/31 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDNW',5628,405,818,'2015/02/01 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDSA',5629,405,819,'2015/02/02 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('SAUVG',197,420,5,'2015/02/03 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('BHRB2',326,426,5,'2015/02/04 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDMB',412,404,69,'2015/02/05 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDEB',5635,405,876,'2015/02/06 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDDL',440,404,68,'2015/02/07 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDEE',5638,405,879,'2015/02/08 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('ARGVO',459,722,36,'2015/02/09 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDHA',471,404,13,'2015/02/10 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('COLTI',5062,732,103,'2015/02/11 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDWG',5642,405,927,'2015/02/12 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDMW',5644,405,929,'2015/02/13 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('PANCL',5645,714,3,'2015/02/14 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('ARMOR',5647,283,10,'2015/02/15 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('BHRST',5650,426,4,'2015/02/16 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('YEMYY',5651,421,4,'2015/02/17 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('CANVT',5653,302,500,'2015/02/18 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('PSEWM',5654,425,6,'2015/02/19 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('IND29',5681,405,807,'2015/02/20 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('IND26',5683,405,806,'2015/02/21 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('IND28',5684,405,802,'2015/02/22 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('IND27',5685,405,808,'2015/02/23 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('MARM3',5702,604,2,'2015/02/24 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('VNMVM',5709,452,5,'2015/02/25 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('QATB1',5710,427,2,'2015/02/26 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('VNMBL',5711,452,7,'2015/02/27 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('LIETG',5723,295,77,'2015/02/28 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('TUNOR',5732,605,1,'2015/03/01 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('RWATG',5812,635,13,'2015/03/02 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('GNQHT',5757,627,3,'2015/03/03 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('GIN07',5764,611,5,'2015/03/04 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('GMBQC',5765,607,4,'2015/03/05 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('RWART',5766,635,12,'2015/03/06 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('FRAFM',5778,208,15,'2015/03/07 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('BDI02',5784,642,2,'2015/03/08 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('SLBBM',5786,540,2,'2015/03/09 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('CRITC',5794,712,4,'2015/03/10 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('SOM01',5799,637,1,'2015/03/11 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('MUSMT',5805,617,3,'2015/03/12 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('JPNKD',5807,440,50,'2015/03/13 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('USAVZ',5808,310,890,'2015/03/14 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('USAVZ',5808,310,590,'2015/03/15 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('CRICL',5809,712,3,'2015/03/16 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('CANEL',5817,302,270,'2015/03/17 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('SENEX',5818,608,3,'2015/03/18 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('AAZ24',5822,208,24,'2015/03/19 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('MRTCH',5825,609,2,'2015/03/20 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('TLSTC',5829,514,1,'2015/03/21 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('GBRTR',5835,234,25,'2015/03/22 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('GBRC9',5469,234,18,'2015/03/23 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('AGOMV',5803,631,4,'2015/03/24 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('ABWSE',5349,363,1,'2015/03/25 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('ABWDC',5485,363,2,'2015/03/26 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('BENGM',5612,616,5,'2015/03/27 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('BOLTE',5390,736,3,'2015/03/28 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('BFATL',855,613,3,'2015/03/29 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('KHMCC',5609,456,4,'2015/03/30 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('COKTC',704,548,1,'2015/03/31 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('CYPPT',5793,280,20,'2015/04/01 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('CODOR',5832,630,86,'2015/04/02 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('GABAZ',5816,628,4,'2015/04/03 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('GIBCS',5783,266,6,'2015/04/04 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('GIBSH',5791,266,9,'2015/04/05 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('GINGS',709,611,1,'2015/04/06 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('GIN02',710,611,2,'2015/04/07 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('GNB03',5481,632,3,'2015/04/08 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('GUYGT',5395,738,2,'2015/04/09 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('IND17',5575,405,810,'2015/04/10 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('IND25',5682,405,812,'2015/04/11 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('IDNM8',5413,510,28,'2015/04/12 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('KAZ77',5441,401,77,'2015/04/13 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('LAOTC',688,457,1,'2015/04/14 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('GUF01',779,340,2,'2015/04/15 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('ANTUT',137,362,91,'2015/04/16 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('PANMS',5412,714,20,'2015/04/17 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('RUSEC',5401,250,35,'2015/04/18 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('WSMDP',5804,549,0,'2015/04/19 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('STPST',5620,626,1,'2015/04/20 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('SLECM',5427,619,4,'2015/04/21 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('KORLU',5831,450,6,'2015/04/22 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('SSDVC',5806,659,4,'2015/04/23 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('SPM01',5448,308,1,'2015/04/24 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('TKMAA',5814,438,2,'2015/04/25 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('UGATL',291,641,11,'2015/04/26 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('UGAOR',5646,641,14,'2015/04/27 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('USAUN',814,310,20,'2015/04/28 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('VUT01',701,541,1,'2015/04/29 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDE6',5374,405,66,'2015/04/30 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDV2',5514,405,751,'2015/05/01 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDV7',5585,405,756,'2015/05/02 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDV1',5586,405,750,'2015/05/03 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('BMUBD',5608,350,0,'2015/05/04 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDTA',5634,405,875,'2015/05/05 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('CANKO',5652,302,380,'2015/05/06 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDDM',5658,405,825,'2015/05/07 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDDN',5661,405,828,'2015/05/08 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('UGAWT',289,641,22,'2015/05/09 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('UGACE',289,641,1,'2015/05/10 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDHL',5677,405,932,'2015/05/11 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('CANST',5724,302,780,'2015/05/12 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('JPNKI',5807,440,51,'2015/05/13 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('THADT',5847,520,5,'2015/05/14 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('PYFVF',5863,547,15,'2015/05/15 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('UPCAT',5864,232,13,'2015/05/16 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('IRNTT',5867,432,20,'2015/05/17 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('UGASU',5870,641,18,'2015/05/18 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('BRAN3',5873,724,39,'2015/05/19 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('THAWN',5874,520,3,'2015/05/20 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('MMRTN',5879,414,6,'2015/05/21 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('MCOM3',5880,212,2,'2015/05/22 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('MCOM2',5880,212,10,'2015/05/23 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('NORTD',5883,242,8,'2015/05/24 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('SWETD',5884,240,14,'2015/05/25 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('TZAYA',5912,640,8,'2015/05/26 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('AAZOR',5915,901,31,'2015/05/27 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('CMRVT',5919,624,4,'2015/05/28 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('UZB00',5931,434,8,'2015/05/29 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('SWECN',60,240,42,'2015/05/30 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('AAZTC',60,901,29,'2015/05/31 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDE5',666,404,88,'2015/06/01 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('PLWPC',5446,552,1,'2015/06/02 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('USASP',320,310,120,'2015/06/03 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('USATL',5758,310,840,'2015/06/04 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('AAZTR',5935,901,37,'2015/06/05 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('RUS48',5936,250,48,'2015/06/06 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('KHM3A',5934,456,11,'2015/06/07 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('SGPMM',254,525,8,'2015/06/08 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('ISRMS',5464,425,7,'2015/06/09 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('CANET',5810,302,340,'2015/06/10 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('CANWT',5811,302,940,'2015/06/11 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('RWAAR',5812,635,14,'2015/06/12 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('IRLIE',5882,272,15,'2015/06/13 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('BDIL1',5887,642,7,'2015/06/14 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('IRLLT',5888,272,11,'2015/06/15 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('BELLM',5932,206,6,'2015/06/16 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('AUTMR',5933,232,17,'2015/06/17 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('GRCCT',2,202,14,'2015/06/18 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('MMROM',5877,414,5,'2015/06/19 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDJ2',5890,405,854,'2015/06/20 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDJ3',5891,405,855,'2015/06/21 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDJ4',5892,405,856,'2015/06/22 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDJV',5893,405,872,'2015/06/23 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDJ5',5894,405,857,'2015/06/24 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDJ6',5895,405,858,'2015/06/25 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDJ7',5896,405,859,'2015/06/26 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDJ8',5897,405,860,'2015/06/27 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDJ9',5898,405,861,'2015/06/28 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDJL',5899,405,862,'2015/06/29 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDJW',5900,405,873,'2015/06/30 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDJM',5901,405,863,'2015/07/01 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDJN',5902,405,864,'2015/07/02 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDJX',5903,405,874,'2015/07/03 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDJO',5904,405,865,'2015/07/04 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDJP',5905,405,866,'2015/07/05 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDJQ',5906,405,867,'2015/07/06 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDJR',5907,405,868,'2015/07/07 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDJS',5908,405,869,'2015/07/08 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDJU',5909,405,871,'2015/07/09 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDJT',5910,405,870,'2015/07/10 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDJ1',5911,405,840,'2015/07/11 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('NORC4',5918,242,9,'2015/07/12 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('MLTWF',5920,278,11,'2015/07/13 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('CODAC',5921,630,90,'2015/07/14 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('LUXEL',5922,270,81,'2015/07/15 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('TELA1',5923,295,7,'2015/07/16 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('AAQGN',5924,901,13,'2015/07/17 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('SVKSW',5925,231,3,'2015/07/18 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('MTX01',5926,270,2,'2015/07/19 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('USANT',5927,312,480,'2015/07/20 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('BDIVG',5928,642,8,'2015/07/21 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('BDIVT',5928,642,8,'2015/07/22 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('CANIW',5862,302,620,'2015/07/23 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('FRALS',5885,208,17,'2015/07/24 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('GUMDP',845,310,370,'2015/07/25 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('MNGGM',5865,428,6,'2015/07/26 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('PRIOM',5938,330,120,'2015/07/27 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('STPUT',5913,626,2,'2015/07/28 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('USAVZ',5808,311,480,'2015/07/29 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('RUS27',77,250,27,'2015/07/30 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('UKRGT',91,255,5,'2015/07/31 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('SAULB',5324,420,60,'2015/08/01 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('BGRMT',5942,284,13,'2015/08/02 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('BLZSC',5944,702,69,'2015/08/03 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('ISRGT',5945,425,8,'2015/08/04 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('FSMFM',5820,550,1,'2015/08/05 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('NICSC',858,710,73,'2015/08/06 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('NORIC',5943,242,14,'2015/08/07 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('PERN3',5679,716,17,'2015/08/08 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('SOMGT',5802,637,30,'2015/08/09 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('TON01',5649,539,1,'2015/08/10 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('TWNGT',5833,466,5,'2015/08/11 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('AAMOW',5872,274,8,'2015/08/12 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('AAZTD',5939,901,40,'2015/08/13 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('ARG01',5408,722,10,'2015/08/14 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('BRABT',5060,724,16,'2015/08/15 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('CANGW',5648,302,490,'2015/08/16 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('CANLM',5947,302,560,'2015/08/17 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('CHLN3',5819,730,9,'2015/08/18 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('ECUAL',5763,740,2,'2015/08/19 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('FLKCW',5787,750,1,'2015/08/20 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('FRA0F',5959,208,94,'2015/08/21 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('FSMTU',5960,553,1,'2015/08/22 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('IND10',866,405,54,'2015/08/23 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('IND11',1007,405,53,'2015/08/24 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('IND12',1001,405,52,'2015/08/25 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('IND13',1004,405,55,'2015/08/26 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('IND14',1012,405,51,'2015/08/27 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('IND15',1008,405,56,'2015/08/28 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('IND16',641,404,16,'2015/08/29 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INXIX',5948,901,11,'2015/08/30 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('KIRKL',5951,545,1,'2015/08/31 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('MEXN3',5841,334,90,'2015/09/01 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('MHLMI',5952,551,1,'2015/09/02 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('MYSP1',5946,502,153,'2015/09/03 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('NGAEM',5592,621,60,'2015/09/04 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('THACA',250,520,4,'2015/09/05 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('TURTK',122,286,1,'2015/09/06 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('USA1L',5773,310,460,'2015/09/07 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('USAAE',803,310,640,'2015/09/08 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('USAAP',5949,312,210,'2015/09/09 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('USAAS',5655,310,710,'2015/09/10 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('USACH',5712,310,570,'2015/09/11 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('USACL',5773,312,260,'2015/09/12 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('USACO',837,311,40,'2015/09/13 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('USACP',834,311,190,'2015/09/14 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('USAET',5861,310,610,'2015/09/15 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('USAGC',5714,311,370,'2015/09/16 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('USAHM',810,310,340,'2015/09/17 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('USAMI',5715,310,300,'2015/09/18 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('USANW',5773,311,530,'2015/09/19 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('USAPC',822,311,80,'2015/09/20 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('USAPE',825,311,170,'2015/09/21 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('USASB',818,310,320,'2015/09/22 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('USATA',5950,311,740,'2015/09/23 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('USAWC',812,310,180,'2015/09/24 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('VGBDC',5528,348,770,'2015/09/25 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('IDNLT',242,510,8,'2015/09/26 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('DOM01',148,370,1,'2015/09/27 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('GRCCO',1,202,1,'2015/09/28 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('GRCPF',2,202,5,'2015/09/29 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('GRCQT',3,202,9,'2015/09/30 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('GRCSH',3,202,10,'2015/10/01 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('NLDLT',4,204,4,'2015/10/02 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('NLDPT',5,204,8,'2015/10/03 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('NLDTM',6,204,12,'2015/10/04 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('NLDPN',7,204,16,'2015/10/05 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('NLDDT',7,204,20,'2015/10/06 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('BELTB',9,206,1,'2015/10/07 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('BELMO',10,206,10,'2015/10/08 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('BELKO',11,206,20,'2015/10/09 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('FRAF1',12,208,1,'2015/10/10 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('FRAF2',13,208,10,'2015/10/11 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('FRAF3',14,208,20,'2015/10/12 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('ESPVV',15,214,6,'2015/10/13 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('ESPAT',15,214,1,'2015/10/14 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('ESPRT',16,214,3,'2015/10/15 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('ESPXF',17,214,4,'2015/10/16 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('ESPTE',18,214,7,'2015/10/17 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('ESPT2',18,214,5,'2015/10/18 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('HUNH1',19,216,1,'2015/10/19 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('HUNH2',20,216,30,'2015/10/20 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('HUNVR',21,216,70,'2015/10/21 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('BIHPT',24,218,90,'2015/10/22 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('HRVCN',25,219,1,'2015/10/23 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('HRVVI',26,219,10,'2015/10/24 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('YUGMT',27,220,1,'2015/10/25 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('ITASI',28,222,1,'2015/10/26 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('ITAOM',29,222,10,'2015/10/27 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('ITAWI',30,222,88,'2015/10/28 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('ROMMF',32,226,1,'2015/10/29 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('ROMCS',33,226,3,'2015/10/30 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('ROMMR',34,226,10,'2015/10/31 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('CHEC1',35,228,1,'2015/11/01 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('CHEDX',36,228,2,'2015/11/02 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('CHEOR',37,228,3,'2015/11/03 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('CZERM',38,230,1,'2015/11/04 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('CZEET',39,230,2,'2015/11/05 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('CZECM',40,230,3,'2015/11/06 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('SVKGT',41,231,1,'2015/11/07 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('AUTMK',43,232,11,'2015/11/08 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('AUTPT',43,232,1,'2015/11/09 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('AUTMM',44,232,3,'2015/11/10 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('AUTTR',44,232,7,'2015/11/11 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('GBRCN',47,234,10,'2015/11/12 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('GBRVF',48,234,15,'2015/11/13 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('GBRME',49,234,30,'2015/11/14 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('GBROR',49,234,33,'2015/11/15 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('GBRJT',51,234,50,'2015/11/16 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('GBRMT',53,234,58,'2015/11/17 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('DNKTD',54,238,1,'2015/11/18 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('DNKDM',55,238,2,'2015/11/19 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('DNKIA',56,238,20,'2015/11/20 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('SWEIQ',59,240,7,'2015/11/21 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('SWESM',59,240,10,'2015/11/22 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('SWEEP',60,240,8,'2015/11/23 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('NORTM',61,242,1,'2015/11/24 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('NORNC',62,242,2,'2015/11/25 15:25','Mitesh');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('CANGS',6010,302,710,'2015/11/26 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('USAPI',5997,312,280,'2015/11/27 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('GBRGA',5967,234,39,'2015/11/28 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('SGPT1',6012,525,10,'2015/11/29 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('LIESO',130,295,10,'2015/11/30 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('USAC2',6009,311,840,'2015/12/01 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('EMNLI',6019,295,9,'2015/12/02 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('DNKT2',55,238,77,'2015/12/03 15:25','IRDB(Ankit Dwivedi)');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('CHNCC',224,460,6,'2015/12/04 15:25','IRDB(Ankit Dwivedi)');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('AAZTE',6022,204,7,'2015/12/05 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('NLDTE',6022,901,54,'2015/12/06 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('TEUM',6026,204,5,'2015/12/07 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('ASMAS',5826,544,110,'2015/12/08 15:25','IRDB Team(Anand)');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('NFKNT',5701,505,10,'2015/12/09 15:25','IRDB Team(Anand)');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('SSDMN',5828,659,2,'2015/12/10 15:25','IRDB Team(Anand)');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('USARB',5875,310,72,'2015/12/11 15:25','IRDB Team(Anand)');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('WSMGS',5734,549,27,'2015/12/12 15:25','IRDB Team(Anand)');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('ZAFTM',5849,655,2,'2015/12/13 15:25','IRDB Team(Anand)');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('USAK4',5808,311,480,'2015/12/14 15:25','IRDB Team(IR85)');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('USAKU',5808,311,270,'2015/12/15 15:25','IRDB Team(IR85)');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('USAOP',6024,313,380,'2015/12/16 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('USACD',837,311,320,'2015/12/17 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('SLEQC',6025,619,7,'2015/12/18 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('LAOAS',5437,457,3,'2015/12/19 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('MEXIU',5841,334,50,'2015/12/20 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('MEXAT',5841,334,70,'2015/12/21 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('AAZAT',5841,901,44,'2015/12/22 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('USASN',6018,312,290,'2015/12/23 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('USASS',6018,312,430,'2015/12/24 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('MACSM',217,455,0,'2015/12/25 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('CANDW',316,302,320,'2015/12/26 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('AUTON',43,232,12,'2015/12/27 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('MDAUN',5498,259,3,'2015/12/28 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('SOMST',5800,637,71,'2015/12/29 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('USAVM',5808,311,270,'2015/12/30 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('AAZ24',5822,208,3,'2015/12/31 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('SSDZS',5840,659,6,'2016/01/01 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('THATC',5842,520,15,'2016/01/02 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('MTX02',5926,901,39,'2016/01/03 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('USACM',5981,311,230,'2016/01/04 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('BELML',5982,206,30,'2016/01/05 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('WLF02',5986,543,1,'2016/01/06 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('USALW',830,312,180,'2016/01/07 15:25','IRDB Team');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('URYK9',5262,748,1,'2016/01/08 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('THAK9',5874,520,3,'2016/01/09 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDO1',5579,405,803,'2016/01/10 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDK3',5579,405,803,'2016/01/11 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDOS',5580,405,801,'2016/01/12 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDK5',5580,405,801,'2016/01/13 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDON',5574,405,800,'2016/01/14 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDK8',5574,405,800,'2016/01/15 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDOT',5613,405,804,'2016/01/16 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDK2',5613,405,804,'2016/01/17 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDOQ',5577,405,805,'2016/01/18 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDK6',5577,405,805,'2016/01/19 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDOL',5575,405,810,'2016/01/20 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDKF',5575,405,810,'2016/01/21 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDKG',5575,405,810,'2016/01/22 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDOG',1011,404,25,'2016/01/23 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDKJ',1011,404,25,'2016/01/24 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDKK',1010,404,35,'2016/01/25 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDOK',5471,404,91,'2016/01/26 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDK7',5471,404,91,'2016/01/27 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDOH',1006,404,28,'2016/01/28 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDKN',1006,404,28,'2016/01/29 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDOF',1009,404,17,'2016/01/30 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDKH',1009,404,17,'2016/01/31 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDOU',5682,405,812,'2016/02/01 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDOW',5683,405,806,'2016/02/02 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDOA',173,404,41,'2016/02/03 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDK9',173,404,41,'2016/02/04 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDOY',5684,405,802,'2016/02/05 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDOB',174,404,42,'2016/02/06 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDK1',174,404,42,'2016/02/07 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('SYCOC',281,633,10,'2016/02/08 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('GABOB',5055,628,3,'2016/02/09 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('MDGOC',295,646,1,'2016/02/10 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('MWIOC',5023,650,10,'2016/02/11 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('KENOD',285,639,3,'2016/02/12 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('TCDOC',136,622,1,'2016/02/13 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('UGAOB',289,641,1,'2016/02/14 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('KGZOC',5440,437,5,'2016/02/15 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('KGZK7',5440,437,5,'2016/02/16 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('USAOZ',5808,310,590,'2016/02/17 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('AFGOC',5479,412,40,'2016/02/18 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('GINOC',5591,611,4,'2016/02/19 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('MEXOC',5841,334,90,'2016/02/20 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('CIVOD',5392,612,2,'2016/02/21 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('NERK9',713,614,3,'2016/02/22 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('GHAOV',725,620,2,'2016/02/23 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('BELOC',9,206,1,'2016/02/24 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('PNGK9',5601,537,1,'2016/02/25 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('BIHOD',24,218,90,'2016/02/26 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('LUXOC',106,270,77,'2016/02/27 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('LTUOC',68,246,2,'2016/02/28 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('LVAOC',5403,247,5,'2016/02/29 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('BRAK7',5060,724,16,'2016/03/01 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('SHNCW',52,234,55,'2016/03/02 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('GBRK6',52,234,55,'2016/03/03 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('KHMK8',5609,456,4,'2016/03/04 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('ZAFOB',448,655,7,'2016/03/05 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('NAMK9',5418,649,3,'2016/03/06 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('ISRK9',421,425,2,'2016/03/07 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('MUSOD',272,617,1,'2016/03/08 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('MUSK9',272,617,1,'2016/03/09 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('CODOD',144,630,2,'2016/03/10 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('CHNK8',224,460,1,'2016/03/11 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('CHNK9',224,460,1,'2016/03/12 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('MRTOC',5825,609,2,'2016/03/13 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('CRIK9',5809,712,3,'2016/03/14 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('COLK9',5062,732,111,'2016/03/15 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('ABWK9',5349,363,1,'2016/03/16 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('ARMK7',5387,283,5,'2016/03/17 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('BIHK9',23,218,5,'2016/03/18 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('BRAK9',5424,724,6,'2016/03/19 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('BRAK0',5060,724,16,'2016/03/20 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('BRAK4',5424,724,6,'2016/03/21 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('BRAK5',5424,724,6,'2016/03/22 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('BRAK6',5424,724,6,'2016/03/23 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('CHLK9',309,730,1,'2016/03/24 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('CZEK9',38,230,1,'2016/03/25 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('DEUK9',97,262,1,'2016/03/26 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('EGYK9',258,602,1,'2016/03/27 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('ESTK9',71,248,1,'2016/03/28 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('ESTK8',72,248,2,'2016/03/29 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('FJIK9',257,542,1,'2016/03/30 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('GEOK9',118,282,2,'2016/03/31 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDKG',5576,405,811,'2016/04/01 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDK1',5471,404,91,'2016/04/02 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('ISRK6',421,425,2,'2016/04/03 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('ISRK5',5464,425,7,'2016/04/04 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('ISRK7',5501,425,3,'2016/04/05 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('KAZK9',5441,401,77,'2016/04/06 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('LKAK8',189,413,3,'2016/04/07 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('LTUK9',68,246,2,'2016/04/08 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('LTUK8',67,246,1,'2016/04/09 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('LVAK9',5403,247,5,'2016/04/10 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('MDGK8',296,646,2,'2016/04/11 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('MNEK7',314,297,1,'2016/04/12 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('NZLK9',5489,530,24,'2016/04/13 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('NZLK8',5599,530,5,'2016/04/14 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('PANK9',5573,714,4,'2016/04/15 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('POLK9',94,260,1,'2016/04/16 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('PRYK9',5367,744,5,'2016/04/17 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('QATK9',5710,427,2,'2016/04/18 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('RUSK7',73,250,1,'2016/04/19 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('SVNK8',127,293,41,'2016/04/20 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('SVNK9',128,293,70,'2016/04/21 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('THAK8',5847,520,5,'2016/04/22 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('THAK7',5847,520,18,'2016/04/23 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('TKMK9',210,438,1,'2016/04/24 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('TWNK8',402,466,1,'2016/04/25 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('USAK5',818,310,320,'2016/04/26 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('VNMK7',333,452,1,'2016/04/27 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('VNMK6',211,452,2,'2016/04/28 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('VNMK9',5709,452,5,'2016/04/29 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('VNMK8',5346,452,4,'2016/04/30 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('COMOC',743,654,1,'2016/05/01 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('CODOB',5832,630,86,'2016/05/02 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('GRCOK',1,202,1,'2016/05/03 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('HRVOC',25,219,1,'2016/05/04 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('CPVOC',508,625,1,'2016/05/05 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('CPVK8',508,625,1,'2016/05/06 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('POLCP',508,625,1,'2016/05/07 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('MDVK8',230,472,1,'2016/05/08 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('VUTK9',5506,541,5,'2016/05/09 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('SURK9',5499,746,3,'2016/05/10 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('MUSOB',273,617,10,'2016/05/11 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('TKMOC',210,438,1,'2016/05/12 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('BENOD',717,616,2,'2016/05/13 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('SENOC',5818,608,3,'2016/05/14 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('FROOC',125,288,1,'2016/05/15 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('FRAOB',5778,208,15,'2016/05/16 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('CANOD',5648,302,490,'2016/05/17 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('GNQOC',5757,627,3,'2016/05/18 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('SWEOK',616,240,2,'2016/05/19 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('DNKOK',614,238,6,'2016/05/20 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('AUTOG',5028,232,5,'2016/05/21 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('IRNOC',5476,432,35,'2016/05/22 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('ZAFJT',5849,655,2,'2016/05/23 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('ARMOC',5387,283,5,'2016/05/24 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('JPNOC',5807,440,50,'2016/05/25 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('JPNOD',5807,440,50,'2016/05/26 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('BDIOC',5887,642,7,'2016/05/27 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('KOROB',5831,450,6,'2016/05/28 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('NLDOV',4,204,4,'2016/05/29 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('GABOC',277,628,1,'2016/05/30 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('COGOC',732,629,10,'2016/05/31 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('LBROC',5438,618,1,'2016/06/01 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('ANTK8',137,362,91,'2016/06/02 15:25','IRDB Team(Anand)');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('ANTK9',637,362,51,'2016/06/03 15:25','IRDB Team(Anand)');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('AZEK8',150,400,2,'2016/06/04 15:25','IRDB Team(Anand)');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('CANK5',5648,302,490,'2016/06/05 15:25','IRDB Team(Anand)');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('DJIK9',868,638,1,'2016/06/06 15:25','IRDB Team(Anand)');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('GUYK9',5430,738,1,'2016/06/07 15:25','IRDB Team(Anand)');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('LIEK9',628,295,2,'2016/06/08 15:25','IRDB Team(Anand)');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('MDAK8',5498,259,5,'2016/06/09 15:25','IRDB Team(Anand)');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('MDAK8',5498,259,3,'2016/06/10 15:25','IRDB Team(Anand)');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('MLIK8',708,610,2,'2016/06/11 15:25','IRDB Team(Anand)');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('MRTK9',525,609,1,'2016/06/12 15:25','IRDB Team(Anand)');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('NGAK7',728,621,50,'2016/06/13 15:25','IRDB Team(Anand)');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('TKMK8',5814,438,2,'2016/06/14 15:25','IRDB Team(Anand)');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('TONK8',5649,539,1,'2016/06/15 15:25','IRDB Team(Anand)');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('ZMBK8',738,645,3,'2016/06/16 15:25','IRDB Team(Anand)');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('BHRBT',326,426,5,'2016/06/17 15:25','IRDB Team(Anand)');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('ARGTP',459,722,36,'2016/06/18 15:25','IRDB Team(Anand)');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('AUTCA',5028,232,10,'2016/06/19 15:25','IRDB Team(Anand)');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('LAOLA',5437,457,3,'2016/06/20 15:25','IRDB Team(Anand)');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('SVNK7',5611,293,64,'2016/06/21 15:25','IRDB Team(Anand)');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('KHMVT',5616,456,8,'2016/06/22 15:25','IRDB Team(Anand)');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('GHAK9',5795,620,7,'2016/06/23 15:25','IRDB Team(Anand)');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('USAWW',5808,310,890,'2016/06/24 15:25','IRDB Team(Anand)');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('CHLK8',5819,730,9,'2016/06/25 15:25','IRDB Team(Anand)');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('AAM26',6006,901,46,'2016/06/26 15:25','IRDB Team(Anand)');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('KHMK1',5934,456,11,'2016/06/27 15:25','IRDB Team(Anand)');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('BMU01',147,350,1,'2016/06/28 15:25','IRDB Team(Anand)');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('HTIHT',5792,372,3,'2016/06/29 15:25','IRDB Team(Anand)');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('PLW3G',5848,552,88,'2016/06/30 15:25','IRDB Team(Anand)');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('PERVT',5858,716,15,'2016/07/01 15:25','IRDB Team(Anand)');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('GBRLI',5866,234,53,'2016/07/02 15:25','IRDB Team(Anand)');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('COGEQ',5930,629,2,'2016/07/03 15:25','IRDB Team(Anand)');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('USAW1',318,310,210,'2016/07/04 15:25','IRDB Team(Ankit)');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('USAW2',318,310,220,'2016/07/05 15:25','IRDB Team(Ankit)');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('USAW3',318,310,230,'2016/07/06 15:25','IRDB Team(Ankit)');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('TZAK6',5929,640,9,'2016/07/07 15:25','IRDB Team(Ankit)');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('ESPON',15,214,18,'2016/07/08 15:25','IRDB Team(Ankit)');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('GABK7',5055,628,3,'2016/07/09 15:25','IRDB Team(Ankit)');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('BDIK8',5887,642,7,'2016/07/10 15:25','IRDB Team(Ankit)');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('MACK9',217,455,0,'2016/07/11 15:25','IRDB Team(Ankit)');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('BRAK3',503,724,4,'2016/07/12 15:25','IRDB Team(Ankit)');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('BRAK2',503,724,3,'2016/07/13 15:25','IRDB Team(Ankit)');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('BRAK1',503,724,2,'2016/07/14 15:25','IRDB Team(Ankit)');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('TLSK8',5857,514,3,'2016/07/15 15:25','IRDB Team(Ankit)');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('PERK9',5679,716,17,'2016/07/16 15:25','IRDB Team(Ankit)');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('BMUK9',5608,350,0,'2016/07/17 15:25','IRDB Team(Ankit)');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('USASG',320,310,120,'2016/07/18 15:25','IRDB Team(Ankit)');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('MUSOC',5805,617,3,'2016/07/19 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('BWAOC',303,652,1,'2016/07/20 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('TZAOA',287,640,2,'2016/07/21 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('TCDOB',5595,622,3,'2016/07/22 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('GHAOB',726,620,3,'2016/07/23 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('RUSOC',73,250,1,'2016/07/24 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('EGYOC',258,602,1,'2016/07/25 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('AAZOC',5822,208,3,'2016/07/26 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('MCOK9',5962,212,1,'2016/07/27 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('TGOOC',5051,615,3,'2016/07/28 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('MOZVG',5838,643,3,'2016/07/29 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('CMROC',276,624,1,'2016/07/30 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('CIVOC',269,612,5,'2016/07/31 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('CYPOC',788,280,10,'2016/08/01 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('GHAOC',274,620,1,'2016/08/02 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('YEMOC',199,421,2,'2016/08/03 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('BENOC',465,616,3,'2016/08/04 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('SDNOC',809,634,2,'2016/08/05 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('GNBOC',5621,632,2,'2016/08/06 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('GINOC',5621,632,2,'2016/08/07 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('LBROC',5414,618,7,'2016/08/08 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('NGAOC',275,621,30,'2016/08/09 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('RWAOC',283,635,10,'2016/08/10 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('ZAFOC',306,655,10,'2016/08/11 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('SSDOD',5828,659,2,'2016/08/12 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('SWZOC',454,653,10,'2016/08/13 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('UGAOC',290,641,10,'2016/08/14 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('ZMBOC',5056,645,2,'2016/08/15 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('UKROC',88,255,1,'2016/08/16 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('HTIVT',5792,372,3,'2016/08/17 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('ZWEOC',299,648,1,'2016/08/18 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('PRTOC',103,268,3,'2016/08/19 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('ISLOD',5444,274,11,'2016/08/20 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('AUTOF',5028,232,5,'2016/08/21 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('NEROD',5530,614,4,'2016/08/22 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('CODOC',5832,630,86,'2016/08/23 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('CZEOV',40,230,3,'2016/08/24 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('BRNOC',798,528,2,'2016/08/25 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('BELHB',9,206,1,'2016/08/26 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDP1',5911,405,840,'2016/08/27 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDP2',5890,405,854,'2016/08/28 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDP4',5892,405,856,'2016/08/29 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDP5',5894,405,857,'2016/08/30 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDP6',5895,405,858,'2016/08/31 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDP7',5896,405,859,'2016/09/01 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDP9',5898,405,861,'2016/09/02 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDPL',5899,405,862,'2016/09/03 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDPM',5901,405,863,'2016/09/04 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDPY',5902,405,864,'2016/09/05 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDPP',5905,405,866,'2016/09/06 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDPQ',5906,405,867,'2016/09/07 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDPR',5907,405,868,'2016/09/08 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDPS',5908,405,869,'2016/09/09 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDPT',5910,405,870,'2016/09/10 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDPU',5909,405,871,'2016/09/11 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDPV',5893,405,872,'2016/09/12 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDPZ',5900,405,873,'2016/09/13 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDPX',5903,405,874,'2016/09/14 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('INDOC',184,404,67,'2016/09/15 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('IRNOD',5867,432,1,'2016/09/16 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('BIHOC',23,218,5,'2016/09/17 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('UGAOD',5870,641,18,'2016/09/18 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('CANOB',5724,302,750,'2016/09/19 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('MNGOC',5851,428,1,'2016/09/20 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('TZAOB',5912,640,8,'2016/09/21 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('SSDOC',5840,659,6,'2016/09/22 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('CHEOG',36,228,2,'2016/09/23 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('SWZOD',5975,653,2,'2016/09/24 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('SVNOC',5611,293,64,'2016/09/25 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('TWNOC',227,466,97,'2016/09/26 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('USAOD',5758,310,840,'2016/09/27 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('SVNOD',127,293,41,'2016/09/28 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('YUGOC',445,220,3,'2016/09/29 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('BELOD',5733,206,5,'2016/09/30 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('SRBOD',27,220,1,'2016/10/01 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('NOROC',62,242,2,'2016/10/02 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('BRAOI',503,724,2,'2016/10/03 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('BRAOG',503,724,2,'2016/10/04 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('BRAOH',503,724,2,'2016/10/05 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('NZL99',5599,530,5,'2016/10/06 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('TUROC',124,286,4,'2016/10/07 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('NZLOC',5489,530,24,'2016/10/08 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('USAOC',5808,310,590,'2016/10/09 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('KHMK5',5616,456,8,'2016/10/10 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('CMRVG',5919,624,4,'2016/10/11 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('PERVG',5679,716,17,'2016/10/12 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('TZAVG',5929,640,9,'2016/10/13 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('TZAVT',5929,640,9,'2016/10/14 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('BRAOC',5424,724,6,'2016/10/15 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('BRAOD',5424,724,6,'2016/10/16 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('BRAOE',5424,724,6,'2016/10/17 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('BRAOF',5424,724,6,'2016/10/18 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('CODOV',534,630,1,'2016/10/19 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('ZAFOV',305,655,1,'2016/10/20 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('LSOOV',741,651,1,'2016/10/21 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('MOZOV',863,643,4,'2016/10/22 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('TZAOV',526,640,4,'2016/10/23 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('ALBOV',113,276,2,'2016/10/24 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('GRCOV',2,202,5,'2016/10/25 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('HUNOV',21,216,70,'2016/10/26 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('ITAOV',29,222,10,'2016/10/27 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('AUSOV',237,505,3,'2016/10/28 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('DEUOV',98,262,2,'2016/10/29 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('ESPVF',15,214,1,'2016/10/30 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('ESPV2',15,214,1,'2016/10/31 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('MLTOV',114,278,1,'2016/11/01 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('NZLOV',256,530,1,'2016/11/02 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('GBROV',48,234,15,'2016/11/03 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('IRLOV',107,272,1,'2016/11/04 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('PRTOV',102,268,1,'2016/11/05 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('GBROV',107,272,1,'2016/11/06 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('MLTV2',5878,901,19,'2016/11/07 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('AAZOV',114,278,1,'2016/11/08 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('QATV2',5710,427,2,'2016/11/09 15:25','Ankit Dwivedi');
INSERT INTO cdr_voice_tadig_codes(TC_TADIG_CODE,TC_NETWORK_ID,TC_MCC,TC_MNC,TC_REC_CHANGED_AT,TC_REC_CHANGED_BY) VALUES ('CAN02',6017,302,130,'2016/11/10 15:25','IRDB Team');

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
