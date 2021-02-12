

-- Dumping structure for procedure gm_reports.gm_voice_report
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
DROP TEMPORARY TABLE if EXISTS temp_voice_incomplete;
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
cdr_voice_incompleted.CIC AS cic
FROM cdr_voice_incompleted
INNER JOIN report_metadata
ON (report_metadata.MSISDN = cdr_voice_incompleted.CALLEDNUMBER
or report_metadata.MSISDN = cdr_voice_incompleted.CALLINGNUMBER)
left join gm_country_code_mapping on report_metadata.ACCOUNT_COUNTRIE=gm_country_code_mapping.account
WHERE date(cdr_voice_incompleted.ANMRECDAT) = start_date
and report_metadata.ENT_ACCOUNTID=in_account_id;

DROP TEMPORARY TABLE if EXISTS temp_voice_complete;
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
cdr_voice_completed.CIC AS cic
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

DROP TEMPORARY TABLE if EXISTS temp_voice;
CREATE TEMPORARY TABLE temp_voice
SELECT * FROM temp_voice_complete
UNION ALL
SELECT * FROM temp_voice_incomplete;

DROP TABLE IF EXISTS temp_voice_data_return_table;
CREATE TEMPORARY TABLE temp_voice_data_return_table
SELECT DISTINCT
temp_voice.ICCID AS 'ICCID',
temp_voice.IMSI AS 'IMSI',
temp_voice.MSISDN AS 'MSISDN',

 COUNTRY_CODE AS 'ACCOUNT ID',

 @TEMP_BILLING_CYCLE_DATE AS 'BILLING CYCLE DATE',

 CALLINGNUMBER AS 'CALLING PARTY NUMBER',
CALLEDNUMBER AS 'CALLED',
CALLDURATION AS 'ANSWER DURATION',
CEILING(CALLDURATION/60) as 'ANSWER DURATION ROUNDED',

 ANMRECDAT AS 'ORIGINATION DATE',
LEFT(MSISDN,6) AS 'OPERATOR NETWORK',

case when MOCALL=0 OR MOCALL IS NULL
then LASTERBCSM
when MOCALL=1
then COALESCE(LASTERBCSM,0)
end AS 'CALL TERMINATION REASON',
case when cic= '1' then '2' ELSE '1' end as 'CALL TYPE',
case when MOCALL=1 then 'MO' ELSE 'MT' end 'CALL DIRECTION',
case when temp_wholesale_plan_history.IMSI=temp_voice.IMSI then temp_wholesale_plan_history.plan ELSE temp_voice.WHOLE_SALE_NAME END AS PLAN,

 cdr_voice_tadig_codes.TC_TADIG_CODE as TAP_CODE
FROM temp_voice
left join temp_wholesale_plan_history on temp_wholesale_plan_history.IMSI=temp_voice.IMSI
and (ANMRECDAT between temp_wholesale_plan_history.start_date and temp_wholesale_plan_history.end_date)
left join cdr_voice_tadig_codes on temp_voice.MCC=cdr_voice_tadig_codes.TC_MCC
and case when CHAR_LENGTH(temp_voice.MNC)=1 then concat('0',temp_voice.MNC) else temp_voice.MNC END = case when CHAR_LENGTH(cdr_voice_tadig_codes.TC_MNC)=1 then concat('0',cdr_voice_tadig_codes.TC_MNC) else cdr_voice_tadig_codes.TC_MNC end ;


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

