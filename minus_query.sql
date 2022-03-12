
WITH temp1 AS(select  distinct a.carr_ow_invc_id from prthd.carr_ow_invc a
where a.carr_invc_stat_cd = 43)
,
temp2 as (select distinct carr_ow_invc_id from prthd.OW_CHRG_ALLOC where carr_ow_invc_id in
(select a.carr_ow_invc_id from prthd.carr_ow_invc a
where a.carr_invc_stat_cd = 43 ))
select * from temp1 where carr_ow_invc_id not in (select carr_ow_invc_id from temp2)

select * from prthd.OW_CHRG_ALLOC where carr_ow_invc_id  in (1886818,2125837,2126924,2249836,2263511,2379258)


WITH temp1 (carr_ow_invc_id) AS (SELECT DISTINCT carr_ow_invc_id FROM CARR_OW_INVC
WHERE CARR_INVC_STAT_CD = 7 AND LAST_UPD_TS <= CURRENT_TIMESTAMP - 1 DAYS ),
 temp2 (carr_ow_invc_id) AS (SELECT DISTINCT carr_ow_invc_id FROM CARR_OW_INVC WHERE carr_ow_invc_id in (
28683194,28713696,28795617,28795851,29041538,29041554) )
SELECT * FROM temp1 WHERE CARR_OW_INVC_ID NOT IN (SELECT carr_ow_invc_id FROM temp2 )

WITH temp1 AS(SELECT d.THD_CARR_DINVC_ID,sum(s.GL_ACCT_AMT) SUM_S FROM DINVC_SHP_TYP_CHRG S , CARR_DINVC d
WHERE s.CARR_INVC_TYP_IND = 'I'
AND d.THD_CARR_DINVC_ID = s.THD_CARR_DINVC_ID
AND date(d.CRT_TS)>= date(CURRENT_TIMESTAMP - 300 days)
GROUP BY d.THD_CARR_DINVC_ID),
temp2 as (SELECT d.THD_CARR_DINVC_ID,sum(i.INCRM_FEE_AMT) SUM_I FROM DINVC_INCRM_FEE i, CARR_DINVC d
WHERE d.THD_CARR_DINVC_ID = i.THD_CARR_DINVC_ID
AND date(d.CRT_TS)>= date(CURRENT_TIMESTAMP - 300 days)
GROUP BY d.THD_CARR_DINVC_ID )
SELECT temp1.THD_CARR_DINVC_ID,(SUM_S - SUM_I) DIFF FROM temp1, temp2
WHERE temp1.THD_CARR_DINVC_ID = temp2.THD_CARR_DINVC_ID
