-- Find If you are transferring just rates or routes or both

SELECT SENDRATES,SENDROUTES FROM AWARDEXPORTCONFIG WHERE RFPID = <RFPID>;

-- If SENDRATES = 1 then transferring rates, If SENDVOLUME = 1 transferring routes, If both are 1 transferring both rates and routes.

--Find the roundnum of the scenario which was moved to final.

select round_num from scenario where rfpid = <RFPID> and isfinal = 1;

--Find the AWARDTYPE, BASEMODE, CONTRACTSTARTDATE etc.

select RFPNAME, MODEID, BASEDATAMODE, TCCOMPANYID, CONTRACTSTARTDT, CONTRACTENDDT, CURRENCYCODE,
 AWARDTYPE from rfp r where RFPID= <RFPID> and round_num = <ROUND_NUM>;
 
--- CONTRACTSTARTDT will be same as EFFECTIVE_DT in TP&E, CONTRACTENDDT will be same as EXPIRATION_DT in TP&E.
 
 -- AWARDTPE can be one of the following.
 
  AWARDTYPE     DESCRIPTION    
  ------------  -------------- 
  0             Volume         
  2             Rank           
  1             Percentage   
 
 
 ---- MASTER QUERY WHICH READS THE COMPLETE AWARDED RATES AND ROUTES FOR THE GIVEN RFP. You can download this into a spread sheet or to a temp table.

 SELECT l.rfpid                      ,
        l.LANEID                     ,
        l.BUSINESS_UNIT_ID           ,
        lb.OBCARRIERCODEID           ,
        lb.LANEEQUIPMENTTYPEID       ,
        CARRIERCODE                  ,
        lb.TPCOMPANYID               ,
        lb.EQUIPMENTTYPE_ID          ,
        lb.SERVICETYPE_ID            ,
        lb.PROTECTIONLEVEL_ID        ,
        lb.MOT                       ,
        lb.COMMODITYCODE_ID          ,
        lb.CURRENCYCODE              ,
        l.BUSINESS_UNIT_ID           ,
        l.ORIGINZONECODE             ,
        l.ORIGINFACILITYCODE         ,
        l.ORIGINCITY                 ,
        l.ORIGINSTATEPROV            ,
        l.ORIGINPOSTALCODE           ,
        l.ORIGINCOUNTRYCODE          ,
        l.SEASON_ID                  ,
        l.DESTINATIONZONECODE        ,
        l.DESTINATIONFACILITYCODE    ,
        l.DESTINATIONCITY            ,
        l.DESTINATIONSTATEPROV       ,
        l.DESTINATIONPOSTALCODE      ,
        l.DESTINATIONCOUNTRYCODE     ,
        l.AVERAGEWEIGHT              ,
        l.WEIGHTUOM LANEWEIGHTUOM    ,
        l.WEIGHTBREAK1               ,
        l.WEIGHTBREAK2               ,
        l.WEIGHTBREAK3               ,
        l.WEIGHTBREAK4               ,
        l.WEIGHTBREAK5               ,
        l.WEIGHTBREAK6               ,
        l.WEIGHTBREAK7               ,
        l.WEIGHTBREAK8               ,
        l.WEIGHTBREAK9               ,
        l.VOLUME                     ,
        l.VOLUMEFREQUENCY            ,
        l.DISTANCEUOM                ,
        lb.MINIMUMCHARGE             ,
        lb.WEIGHTUOM LANEBIDWEIGHTUOM,
        lb.FLATCHARGE                ,
        lb.BASERATE                  ,
        lb.INCLUSIVERATE             ,
        lb.RATEPERSIZE               ,
        lb.CHARGEBASIS               ,
        lb.RATEPERDISTANCE           ,
        ROUND(
               CASE l.VOLUMEFREQUENCY
                      WHEN 0
                      THEN lb.SURGECAPACITY
                      WHEN 1
                      THEN lb.SURGECAPACITY
                      WHEN 2
                      THEN (lb.SURGECAPACITY/14)*7
                      WHEN 3
                      THEN ((lb.SURGECAPACITY/CAST(30.4166666667 AS DOUBLE))*7)
                      WHEN 4
                      THEN (lb.SURGECAPACITY/182.5)*7
                      WHEN 5
                      THEN ((lb.SURGECAPACITY/365.0) *7)
               END ,0) SURGECAPACITY,
        ROUND(
               CASE l.VOLUMEFREQUENCY
                      WHEN 0
                      THEN lb.LANECAPACITY
                      WHEN 1
                      THEN lb.LANECAPACITY
                      WHEN 2
                      THEN (lb.LANECAPACITY/14)*7
                      WHEN 3
                      THEN ((lb.LANECAPACITY/CAST(30.4166666667 AS DOUBLE))*7)
                      WHEN 4
                      THEN (lb.LANECAPACITY/182.5)*7
                      WHEN 5
                      THEN ((lb.LANECAPACITY/365.0) *7)
               END ,0) LANEBIDCAPACITY,
        lb.WEIGHTBREAKCHARGE1         ,
        lb.WEIGHTBREAKCHARGE2         ,
        lb.WEIGHTBREAKCHARGE3         ,
        lb.WEIGHTBREAKCHARGE4         ,
        lb.WEIGHTBREAKCHARGE5         ,
        lb.WEIGHTBREAKCHARGE6         ,
        lb.WEIGHTBREAKCHARGE7         ,
        lb.WEIGHTBREAKCHARGE8         ,
        lb.WEIGHTBREAKCHARGE9         ,
        CASE lb.AWARDAMOUNT
               WHEN 0
               THEN NULL
               ELSE lb.AWARDAMOUNT
        END AWARDAMOUNT,
        lb.PACKAGEID
 FROM   lane l         ,
        lanebid lb     ,
        rfpresponse r  ,
        obcarriercode o,
        lane_active la
 WHERE  l.lane_type        <> 2
 AND   l.RFPID = <RFPID>

   AND l.RFPID             = lb.RFPID
   AND l.LANEID            = lb.LANEID
   AND o.OBCARRIERCODEID   = lb.OBCARRIERCODEID
   AND r.RFPID             = l.RFPID
   AND r.OBCARRIERCODEID   = lb.OBCARRIERCODEID
   AND la.rfpid            = l.rfpid
   AND la.laneid           = l.laneid
   AND la.active           = 1
   AND lb.historicalaward  = 0
   AND r.rfpresponsestatus <> 3
   AND l.round_num         =
   (SELECT MAX(ml.round_num)
   FROM    lane ml
   WHERE   ml.lane_type <> 2
   AND     ml.rfpid      = l.rfpid
   AND     ml.laneid     = l.laneid
   AND     ml.round_num <= <ROUND_NUM>
   )
   AND la.round_num =
   (SELECT MAX(mla.round_num)
   FROM    lane_active mla
   WHERE   mla.rfpid      = la.rfpid
   AND     mla.laneid     = la.laneid
   AND     mla.round_num <= <ROUND_NUM>
   )
   AND r.round_num =
   (SELECT MAX(mr.round_num)
   FROM    rfpresponse mr
   WHERE   mr.rfpid             = r.rfpid
   AND     mr.obcarriercodeid   = r.obcarriercodeid
   AND     mr.round_num        <= <ROUND_NUM>
   AND     mr.RFPRESPONSESTATUS = 1
   )
   AND lb.round_num =
   (SELECT MAX(mlb.round_num)
   FROM    lanebid mlb
   WHERE   mlb.rfpid               = lb.rfpid
   AND     mlb.laneid              = lb.laneid
   AND     mlb.obcarriercodeid     = lb.obcarriercodeid
   AND     mlb.packageid           = lb.packageid
   AND     mlb.laneequipmenttypeid = lb.laneequipmenttypeid
   AND     mlb.historicalaward     = 0
   AND     mlb.round_num          <= r.round_num
   )
   ;
   AND lb.PACKAGEID = 0
   AND NOT EXISTS
   (SELECT 'X'
   FROM    lanebid lb1
   WHERE   lb1.RFPID               = lb.rfpid
   AND     lb1.LANEID              = lb.LANEID
   AND     lb1.LANEEQUIPMENTTYPEID = lb.LANEEQUIPMENTTYPEID
   AND     lb1.OBCARRIERCODEID     = lb.OBCARRIERCODEID
   AND     lb1.PACKAGEID           > 0
   AND     lb1.HISTORICALAWARD     = 0
   AND     lb1.AWARDAMOUNT         > 0
   )
   AND lb.OBCARRIERCODEID IN
   ( SELECT lb2.OBCARRIERCODEID
   FROM    lanebid lb2
   WHERE   lb2.RFPID           = lb.rfpid
   AND     lb2.AWARDAMOUNT     > 0
   AND     lb2.HISTORICALAWARD = 0
)
ORDER BY l.LANEID, lb.EQUIPMENTTYPE_ID, lb.SERVICETYPE_id, lb.PROTECTIONLEVEL_id, lb.OBCARRIERCODEID, CARRIERCODE ;



--- To retrieve just the rates being transferred run the following query. Probably you can save to a spread sheet or a temp table.


 SELECT o.CARRIERCODE               ,
       l.ORIGINZONECODE          ,
       l.ORIGINFACILITYCODE      ,
       l.ORIGINCITY              ,
       l.ORIGINSTATEPROV         ,
       l.ORIGINPOSTALCODE        ,
       l.ORIGINCOUNTRYCODE       ,
       l.DESTINATIONZONECODE     ,
       l.DESTINATIONFACILITYCODE ,
       l.DESTINATIONCITY         ,
       l.DESTINATIONSTATEPROV    ,
       l.DESTINATIONPOSTALCODE   ,
       l.DESTINATIONCOUNTRYCODE  ,
       lb.EQUIPMENTTYPE_ID       ,
       lb.SERVICETYPE_ID         ,
       lb.PROTECTIONLEVEL_ID     ,
       lb.MOT                    ,
       lb.COMMODITYCODE_ID       ,
       lb.MINIMUMCHARGE          ,
       lb.FLATCHARGE             ,
       lb.BASERATE               ,
       lb.INCLUSIVERATE          ,
       lb.RATEPERSIZE            ,
       lb.RATEPERDISTANCE        ,
       lb.AWARDAMOUNT    
 FROM   lane l         ,
        lanebid lb     ,
        rfpresponse r  ,
        obcarriercode o,
        lane_active la
 WHERE  l.lane_type        <> 2
 AND   l.RFPID = <RFPID>

   AND l.RFPID             = lb.RFPID
   AND l.LANEID            = lb.LANEID
   AND o.OBCARRIERCODEID   = lb.OBCARRIERCODEID
   AND r.RFPID             = l.RFPID
   AND r.OBCARRIERCODEID   = lb.OBCARRIERCODEID
   AND la.rfpid            = l.rfpid
   AND la.laneid           = l.laneid
   AND la.active           = 1
   AND lb.historicalaward  = 0
   AND r.rfpresponsestatus <> 3
   AND l.round_num         =
   (SELECT MAX(ml.round_num)
   FROM    lane ml
   WHERE   ml.lane_type <> 2
   AND     ml.rfpid      = l.rfpid
   AND     ml.laneid     = l.laneid
   AND     ml.round_num <= <ROUND_NUM>
   )
   AND la.round_num =
   (SELECT MAX(mla.round_num)
   FROM    lane_active mla
   WHERE   mla.rfpid      = la.rfpid
   AND     mla.laneid     = la.laneid
   AND     mla.round_num <= <ROUND_NUM>
   )
   AND r.round_num =
   (SELECT MAX(mr.round_num)
   FROM    rfpresponse mr
   WHERE   mr.rfpid             = r.rfpid
   AND     mr.obcarriercodeid   = r.obcarriercodeid
   AND     mr.round_num        <= <ROUND_NUM>
   AND     mr.RFPRESPONSESTATUS = 1
   )
   AND lb.round_num =
   (SELECT MAX(mlb.round_num)
   FROM    lanebid mlb
   WHERE   mlb.rfpid               = lb.rfpid
   AND     mlb.laneid              = lb.laneid
   AND     mlb.obcarriercodeid     = lb.obcarriercodeid
   AND     mlb.packageid           = lb.packageid
   AND     mlb.laneequipmenttypeid = lb.laneequipmenttypeid
   AND     mlb.historicalaward     = 0
   AND     mlb.round_num          <= r.round_num
   )
   ;
   AND lb.PACKAGEID = 0
   AND NOT EXISTS
   (SELECT 'X'
   FROM    lanebid lb1
   WHERE   lb1.RFPID               = lb.rfpid
   AND     lb1.LANEID              = lb.LANEID
   AND     lb1.LANEEQUIPMENTTYPEID = lb.LANEEQUIPMENTTYPEID
   AND     lb1.OBCARRIERCODEID     = lb.OBCARRIERCODEID
   AND     lb1.PACKAGEID           > 0
   AND     lb1.HISTORICALAWARD     = 0
   AND     lb1.AWARDAMOUNT         > 0
   )
   AND lb.OBCARRIERCODEID IN
   ( SELECT lb2.OBCARRIERCODEID
   FROM    lanebid lb2
   WHERE   lb2.RFPID           = lb.rfpid
   AND     lb2.AWARDAMOUNT     > 0
   AND     lb2.HISTORICALAWARD = 0
)
ORDER BY l.LANEID, lb.EQUIPMENTTYPE_ID, lb.SERVICETYPE_id, lb.PROTECTIONLEVEL_id, lb.OBCARRIERCODEID, o.CARRIERCODE ;


-- A similar query to run in TP&E to get the equivalent data into a spread sheet or to a temp table.

SELECT
(SELECT CARRIER_CODE FROM CARRIER_CODE WHERE CARRIER_ID = cd.CARRIER_ID),
(SELECT ZONE_NAME FROM ZONE WHERE ZONE_ID = c.O_ZONE_ID),
c.O_FACILITY_ALIAS_ID,
c.O_CITY,
c.O_STATE_PROV
c.O_POSTAL_CODE,
c.O_COUNTRY_CODE,
(SELECT ZONE_NAME FROM ZONE WHERE ZONE_ID = c.D_ZONE_ID),
c.D_FACILITY_ALIAS_ID,
c.D_CITY,
c.D_STATE_PROV
c.D_POSTAL_CODE,
c.D_COUNTRY_CODE,
cd..EQUIPMENT_ID,
cd.SERVICE_LEVEL_ID,
cd..PROTECTION_LEVEL_ID,
(SELECT MOT FROM MOT WHERE MOT_ID = cd.MOT_ID),
cd.COMMODITY_CODE_ID,
rd.RATE,
rd.MINIMUM_RATE
FROM
COMB_LANE c,
COMB_LANE_DTL cd,
RATING_LANE_DTL r,
RATING_LANE_DTL_RATE rd
WHERE
c.LANE_STATUS = 0
AND c.LANE_ID = cd.LANE_ID
AND c.IS_RATING = 1
AND cd.IS_RATING = 1
AND cd.LANE_DTL_STATUS =0
AND cd.LANE_ID = r.LANE_ID
AND cd.LANE_DTL_SEQ = r.RATING_LANE_DTL_SEQ
AND cd.CARRIER_ID = r.CARRIER_ID
AND cd.SERVICE_LEVEL_ID = r.SERVICE_LEVEL_ID
AND cd..PROTECTION_LEVEL_ID = r.PROTECTION_LEVEL_ID
AND cd.MOT_ID = r.MOT_ID
AND cd.EFFECTIVE_DT = r.EFFECTIVE_DT
AND cd.EXPIRATION_DT = r.EXPIRATION_DT
AND r.LANE_ID = rd.LANE_ID
AND r.RATING_LANE_DTL_SEQ = rd.RATING_LANE_DTL_SEQ
AND cd.COMMODITY_CODE_ID = rd.COMMODITY_CODE_ID
AND cd.EFFECTIVE_DT = <CONTRACTSTARTDT>
AND cd.EXPIRATION_DT = <CONTRACTENDDT>;



---  You can also do a quick comparison of the counts by running the above queries, but just use coun(*) in the SELECT clause, to just get an idea how many rates in that RFP were transferred to TP&E.

