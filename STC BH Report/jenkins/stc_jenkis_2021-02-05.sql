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
   
  SET @TEMP_BILLING_CYCLE = (SELECT YEAR(in_start_date) + MONTH(in_start_date) - YEAR(NOW()));

  
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
  report_metadata.ACCOUNT_NOTES AS CONTRACT_ID,

  -- gm_country_code_mapping.country_Code AS SUPPLIER_ACCOUNT_ID ,
  
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
   cdr_data_details_vw.LOCAL_SEQUENCE_NUMBER as Record_Sequence_Number,
   concat(cdr_data_details_vw.ULI_MCC,cdr_data_details_vw.ULI_MNC) AS PLNMID
  from  ((report_metadata
  INNER JOIN cdr_data_details_vw
  ON report_metadata.IMSI = cdr_data_details_vw.SERVED_IMSI
  left join gm_country_code_mapping on report_metadata.ACCOUNT_COUNTRIE=gm_country_code_mapping.account
  left join temp_wholesale_plan_history on temp_wholesale_plan_history.IMSI=report_metadata.IMSI
  and (cdr_data_details_vw.START_TIME between  temp_wholesale_plan_history.start_date and temp_wholesale_plan_history.end_date)))
     WHERE 
      date(cdr_data_details_vw.START_TIME) = date(start_date)
  group by cdr_data_details_vw.SERVED_IMSI, cdr_data_details_vw.CHARGING_ID,cdr_data_details_vw.SERVICE_DATA_FLOW_ID;


  SELECT temp_cdr_data_return_table.*,CASE WHEN ICCID IS NULL 
        OR MSISDN IS NULL
                OR IMSI IS NULL
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
		  OR PLNMID IS NULL 
		  OR CONTRACT_ID IS NULL
    THEN 1 ELSE 0 END AS MANDATORY_COL_NULL,
    CEIL(DATAUSAGE/1024) AS DATAUSAGE_ROUNDED FROM temp_cdr_data_return_table
   WHERE PLAN IS NOT NULL AND PLAN NOT IN ('null','NULL')
    ORDER BY MANDATORY_COL_NULL DESC;
END//
DELIMITER ;

-- Dumping structure for procedure stc_report.gm_sms_delivered_report
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
   
  SET @TEMP_BILLING_CYCLE_DATE = (SELECT YEAR(in_start_date)+MONTH(in_start_date)-YEAR(NOW()));
  
    
    
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
  report_metadata.ACCOUNT_NOTES AS CONTRACT_ID,
--   gm_country_code_mapping.country_Code AS SUPPLIER_ACCOUNT_ID ,
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
    LEFT(report_metadata.MSISDN,6) AS OPERATOR_NETWORK,
     case when cdr_sms_details.SMS_TYPE='MO' then substring(cdr_sms_details.ORIGINATION_GT,1,5)
  when cdr_sms_details.SMS_TYPE='MT' then substring(cdr_sms_details.DESTINATION_GT,1,5) 
  else NULL end AS PLMNID
  FROM (report_metadata
  INNER JOIN cdr_sms_details
  ON report_metadata.MSISDN = cdr_sms_details.SOURCE 
  OR report_metadata.MSISDN = cdr_sms_details.DESTINATION
  left join gm_country_code_mapping on report_metadata.ACCOUNT_COUNTRIE=gm_country_code_mapping.account
  left join temp_wholesale_plan_history on temp_wholesale_plan_history.IMSI=report_metadata.IMSI
  and (cdr_sms_details.FINAL_TIME between  temp_wholesale_plan_history.start_date and temp_wholesale_plan_history.end_date))  
   WHERE date(cdr_sms_details.FINAL_TIME)=date(start_date)
  and UPPER(cdr_sms_details.SMS_STATUS) = 'SUCCESS'
   AND case when cdr_sms_details.SMS_TYPE='MO' then length(cdr_sms_details.DESTINATION) = 5
   when cdr_sms_details.SMS_TYPE='MT' then length(cdr_sms_details.SOURCE)=5 END;
  
   

  SELECT temp_cdr_sms_delivered_return_table.*,
  CASE WHEN ICCID IS NULL OR MSISDN IS NULL OR IMSI IS NULL 
      OR BILLING_CYCLE_DATE IS NULL OR CALL_DIRECTION IS NULL OR PLAN IS NULL OR ORIGINATION_DATE IS NULL
      OR SERVING_SWITCH IS NULL OR ORIGINATION_ADDRESS IS NULL OR DESTINATION_ADDRESS IS NULL 
            OR OPERATOR_NETWORK IS NULL OR PLMNID IS NULL OR CONTRACT_ID IS NULL
    THEN 1 ELSE 0 END AS MANDATORY_COL_NULL
  FROM temp_cdr_sms_delivered_return_table
    WHERE PLAN IS NOT NULL AND PLAN NOT IN ('null','NULL')
    ORDER BY MANDATORY_COL_NULL DESC;
END//
DELIMITER ;

-- Dumping structure for procedure stc_report.gm_sms_undelivered_report
DROP PROCEDURE IF EXISTS `gm_sms_undelivered_report`;
DELIMITER //
CREATE PROCEDURE `gm_sms_undelivered_report`(
	IN `in_start_date` varchar(50),
	IN `in_end_date` varchar(50),
	IN `in_account_id` VARCHAR(50)
)
    COMMENT 'gm_sms_undelivered_report_new'
BEGIN
  
  
  
  
  
  
  
  
  
  

   
   DECLARE date_duration VARCHAR(50);
   DECLARE start_date VARCHAR(50);

    SET start_date:= CAST(in_start_date AS date);
    
  SET @TEMP_BILLING_CYCLE_DATE = (SELECT YEAR(in_start_date)+MONTH(in_start_date)-YEAR(NOW()));
   
    
    
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
   
  
  
   DROP TABLE IF EXISTS temp_cdr_sms_undelivered_return_table;
   CREATE TEMPORARY TABLE temp_cdr_sms_undelivered_return_table
   SELECT 
  report_metadata.ICCID as ICCID,
  report_metadata.MSISDN as MSISDN,
  report_metadata.IMSI as IMSI,
  report_metadata.ACCOUNT_NOTES AS CONTRACT_ID,
 

  -- gm_country_code_mapping.country_Code AS SUPPLIER_ACCOUNT_ID ,
   
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
    
  
    LEFT(report_metadata.MSISDN,6) as OPERATOR_NETWORK,
    CASE WHEN cdr_sms_details.REASON IN ('null','NULL') OR cdr_sms_details.REASON IS NULL THEN 6 ELSE REASON END AS CALL_TERMINATIONS_REASON,
case when cdr_sms_details.SMS_TYPE='MO' then substring(cdr_sms_details.ORIGINATION_GT,1,5)
  when cdr_sms_details.SMS_TYPE='MT' then substring(cdr_sms_details.DESTINATION_GT,1,5) 
  else NULL end AS PLMNID
    
   
  FROM (report_metadata
  INNER JOIN cdr_sms_details
  ON report_metadata.MSISDN = cdr_sms_details.SOURCE 
  OR report_metadata.MSISDN = cdr_sms_details.DESTINATION
  left join gm_country_code_mapping on report_metadata.ACCOUNT_COUNTRIE=gm_country_code_mapping.account
  left join temp_wholesale_plan_history on temp_wholesale_plan_history.IMSI=report_metadata.IMSI
  and (cdr_sms_details.FINAL_TIME between  temp_wholesale_plan_history.start_Date and temp_wholesale_plan_history.end_date))  
   WHERE date(cdr_sms_details.FINAL_TIME)=start_date
   and UPPER(cdr_sms_details.SMS_STATUS) NOT IN ('SUCCESS')
   AND case when cdr_sms_details.SMS_TYPE='MO' then length(cdr_sms_details.DESTINATION) = 5
  when cdr_sms_details.SMS_TYPE='MT' then length(cdr_sms_details.SOURCE)=5 END;
  
    
  SELECT temp_cdr_sms_undelivered_return_table.*,
  CASE WHEN ICCID IS NULL OR MSISDN IS NULL OR IMSI IS NULL 
      OR BILLING_CYCLE_DATE IS NULL OR CALL_DIRECTION IS NULL OR PLAN IS NULL OR ORIGINATION_DATE IS NULL
      OR SERVING_SWITCH IS NULL OR ORIGINATION_ADDRESS IS NULL OR DESTINATION_ADDRESS IS NULL 
            OR OPERATOR_NETWORK IS NULL OR CALL_TERMINATIONS_REASON IS NULL OR PLMNID IS NULL OR CONTRACT_ID IS NULL
    THEN 1 ELSE 0 END AS MANDATORY_COL_NULL
  FROM temp_cdr_sms_undelivered_return_table
  WHERE PLAN IS NOT NULL AND PLAN NOT IN ('null','NULL')
    ORDER BY MANDATORY_COL_NULL DESC;
   
END//
DELIMITER ;

-- Dumping structure for procedure stc_report.gm_voice_report
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
  
  
  SET @TEMP_BILLING_CYCLE_DATE = (SELECT YEAR(in_start_date)+MONTH(in_start_date)-YEAR(NOW()));

  
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
  report_metadata.WHOLE_SALE_NAME,
  report_metadata.ACCOUNT_NOTES AS ACCOUNT_NOTES
  FROM cdr_voice_incompleted 
  INNER JOIN report_metadata 
  ON (report_metadata.MSISDN = cdr_voice_incompleted.CALLEDNUMBER
  or report_metadata.MSISDN = cdr_voice_incompleted.CALLINGNUMBER)
  left join gm_country_code_mapping on report_metadata.ACCOUNT_COUNTRIE=gm_country_code_mapping.account
  WHERE date(cdr_voice_incompleted.ANMRECDAT) = start_date;
      
  
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
  report_metadata.WHOLE_SALE_NAME,
  report_metadata.ACCOUNT_NOTES AS ACCOUNT_NOTES
  FROM cdr_voice_completed 
  INNER JOIN report_metadata 
  ON (report_metadata.MSISDN = cdr_voice_completed.CALLEDNUMBER
    or report_metadata.MSISDN = cdr_voice_completed.CALLINGNUMBER)
  left join gm_country_code_mapping on report_metadata.ACCOUNT_COUNTRIE=gm_country_code_mapping.account
  WHERE date(cdr_voice_completed.ANMRECDAT) = start_date;
  

    
    
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
  
  -- COUNTRY_CODE AS 'ACCOUNT ID',
  ACCOUNT_NOTES AS CONTRACT_ID,
  
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

  
   
  SELECT temp_voice_data_return_table.*,CASE WHEN ICCID IS NULL OR IMSI IS NULL OR MSISDN IS NULL OR `CONTRACT_ID` IS NULL OR `BILLING CYCLE DATE` IS NULL
    OR `CALLING PARTY NUMBER` IS NULL OR `CALLED` IS NULL OR `ANSWER DURATION` IS NULL OR `ANSWER DURATION ROUNDED` IS NULL 
        OR `ORIGINATION DATE` IS NULL OR `OPERATOR NETWORK` IS NULL OR `CALL TERMINATION REASON` IS NULL OR `CALL TYPE` IS NULL
    OR `CALL DIRECTION` IS NULL OR PLAN IS NULL OR TAP_CODE IS NULL
    THEN 1 ELSE 0 END AS MANDATORY_COL_NULL
  FROM temp_voice_data_return_table 
  WHERE PLAN IS NOT NULL AND PLAN NOT IN ('null','NULL')
  ORDER BY MANDATORY_COL_NULL DESC;



END//
DELIMITER ;
