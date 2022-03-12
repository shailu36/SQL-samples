
Issue - mRDC 5086 - IM11902443 - IFC OB loads not reporting accurated cube

select distinct  x.load_nbr, sum ( FM_Weight )as weight, sum (LORP_weight) as weight 
from  ( select distinct ch.CARTON_NBR, ch.load_nbr,  round ((ch.EST_WT ), 4 ) as FM_Weight,  round(sum((cd.UNITS_PAKD * i.UNIT_wt) ),4) as LORP_weight
from carton_dtl cd
left outer join item_master i on ( cd.sku_id = i.SKU_ID )
left outer join carton_hdr ch on ( ch.CARTON_NBR = cd.carton_nbr )
where ch.load_nbr in ('000133562','000133604','000133567','000133732','000133602','000133561','000133600')
and ch.stat_code >=50 and ch.STAT_CODE < 99
group by ch.carton_nbr, ch.load_nbr ,EST_wt
) as x
group by x.load_nbr
order by 1 
with ur ;

--Volume


select distinct load_nbr, sum ( FM_volume) as volume,  sum (LORP_VOLUME) as volume
from  ( select distinct ch.CARTON_NBR, ch.load_nbr,  round ((ch.EST_VOL/1728), 4 ) as FM_VOLUME,  round(sum((cd.UNITS_PAKD * i.UNIT_VOL)/1728),4) as LORP_VOLUME
from carton_dtl cd
left outer join item_master i on ( cd.sku_id = i.SKU_ID )
left outer join carton_hdr ch on ( ch.CARTON_NBR = cd.carton_nbr )
where ch.load_nbr in ('000126027')
and ch.stat_code >=50 and ch.STAT_CODE < 99
group by ch.carton_nbr, ch.load_nbr ,EST_VOL
) as x
group by  x.load_nbr
order by 1
with ur

--select * from outbd_stop where RTE_ID = '5089' with ur  where pro_nbr like '%63980343' with ur
-- select load_nbr, CURR_VOL, CURR_WT, trlr_nbr from outbd_load where load_nbr in (  '000133562','000133604','000133567','000133732','000133602','000133561','000133600' ) with ur ;

/*

update outbd_load set curr_wt = 20784.1296 , curr_vol =                              1346.1377 where stat_code = 80 and load_nbr ='000133561' ;    
update outbd_load set curr_wt = 11079.9668 , curr_vol =                              1105.566  where stat_code = 80 and load_nbr ='000133562' ;    
update outbd_load set curr_wt = 16214.5544 , curr_vol =                              1114.9265 where stat_code = 80 and load_nbr ='000133567' ;    
update outbd_load set curr_wt = 28966.9213 , curr_vol =                              1382.18   where stat_code = 80 and load_nbr ='000133600' ;    
update outbd_load set curr_wt = 22506.2198 , curr_vol =                              1317.3328 where stat_code = 80 and load_nbr ='000133602' ;    
update outbd_load set curr_wt = 19043.3204 , curr_vol =                              1109.7982 where stat_code = 80 and load_nbr ='000133604' ;    
update outbd_load set curr_wt = 12410.7841 , curr_vol =                              1214.1594 where stat_code = 80 and load_nbr ='000133732' ;    

*/




printing argument list
# of args: 5
arg 0 : QM0.PR.US.CCAIDI7A
arg 1 : /opt/hd/dc/tmp/5089/dck744.20141027.172543.fdq_xml
arg 2 : QMX.DI.GSC00
arg 3 : DI.DC.IFC.ASN.CAN
arg 4 : N




/*
select load_nbr, trlr_nbr, stat_code, curr_vol, curr_wt, curr_nbr_of_ctns, curr_nbr_of_plts 
from outbd_load  where load_nbr in ('000126027') with ur ;
select load_nbr, rte_id, auth_nbr
from outbd_stop where load_nbr in ('000126027') with ur ;
*/
-- Outbound Load

select load_nbr, trlr_nbr, stat_code, curr_vol, curr_wt, curr_nbr_of_ctns, curr_nbr_of_plts 
from outbd_load  where load_nbr in ('000126027') with ur ;

--Weight - Load level

select load_nbr, sum (fm_weight ) as weight , sum ( lorp_weight ) as lorp_weight
,(max(sum (fm_weight )  , sum ( lorp_weight )) -min (sum (fm_weight )  , sum ( lorp_weight )) ) as weight_difference
from  ( select distinct ch.CARTON_NBR, ch.load_nbr,  round ((ch.EST_WT ), 4 ) as FM_Weight,  round(sum((cd.UNITS_PAKD * i.UNIT_wt) ),4) as LORP_weight
from carton_dtl cd
left outer join item_master i on ( cd.sku_id = i.SKU_ID )
left outer join carton_hdr ch on ( ch.CARTON_NBR = cd.carton_nbr )
where ch.load_nbr in ('000126027')
and ch.stat_code >=50 and ch.STAT_CODE < 99
group by ch.carton_nbr, ch.load_nbr ,EST_wt
) as x
group by load_nbr
order by 4 desc 
with ur ;

-- Volume - Load level


select load_nbr, sum ( fm_volume) as volume , sum ( lorp_volume ) as lorp_vol
,(max(sum ( fm_volume)  , sum ( lorp_volume )) - min(sum ( fm_volume)  , sum ( lorp_volume )) ) as VOL_DIFFERENCE 
from  ( select distinct ch.CARTON_NBR, ch.load_nbr,  round ((ch.EST_VOL/1728), 4 ) as FM_VOLUME,  round(sum((cd.UNITS_PAKD * i.UNIT_VOL)/1728),4) as LORP_VOLUME
from carton_dtl cd
left outer join item_master i on ( cd.sku_id = i.SKU_ID )
left outer join carton_hdr ch on ( ch.CARTON_NBR = cd.carton_nbr )
where ch.load_nbr in ('000126027')
and ch.stat_code >=50 and ch.STAT_CODE < 99
group by ch.carton_nbr, ch.load_nbr ,EST_VOL
) as x
group by load_nbr
order by 4 desc 
with ur ;


 -- Weight - Carton Level

select x.*
, ( max(x.FM_Weight, x.LORP_weight ) - min(x.FM_Weight, x.LORP_weight ) ) WEIGHT_DIFFERENCE 
from  ( select distinct ch.CARTON_NBR, ch.load_nbr , round ((ch.EST_WT ), 4 ) as FM_Weight,  round(sum((cd.UNITS_PAKD * i.UNIT_wt) ),4) as LORP_weight
from carton_dtl cd
left outer join item_master i on ( cd.sku_id = i.SKU_ID )
left outer join carton_hdr ch on ( ch.CARTON_NBR = cd.carton_nbr )
where ch.load_nbr in ('000126027')
and ch.stat_code >=50 and ch.STAT_CODE < 99
group by ch.carton_nbr, ch.load_nbr  , EST_wt
) as x
order by 5 desc 
 with ur ;

 -- Volume - Carton Level


select x.*
, ( max(x.LORP_VOLUME, x.FM_VOLUME ) - min(x.LORP_VOLUME, x.FM_VOLUME ) ) VOL_DIFFERENCE 
from  ( select distinct ch.CARTON_NBR, ch.load_nbr, round ((ch.EST_VOL/1728), 4 ) as FM_VOLUME,  round(sum((cd.UNITS_PAKD * i.UNIT_VOL)/1728),4) as LORP_VOLUME
from carton_dtl cd
left outer join item_master i on ( cd.sku_id = i.SKU_ID )
left outer join carton_hdr ch on ( ch.CARTON_NBR = cd.carton_nbr )
where ch.load_nbr in ('000126027')
--and ch.stat_code >=50 and ch.STAT_CODE < 99
group by ch.carton_nbr, ch.load_nbr , EST_VOL
) as x
order by 5 desc 
with ur ;



/*



 -- Weight - Carton Level

select x.*
, ( max(x.FM_Weight, x.LORP_weight ) - min(x.FM_Weight, x.LORP_weight ) ) VOL_DIFFERENCE 
from  ( select distinct ch.CARTON_NBR, ch.load_nbr, i.size_desc,  round ((ch.EST_WT ), 4 ) as FM_Weight,  round(sum((cd.UNITS_PAKD * i.UNIT_wt) ),4) as LORP_weight
from carton_dtl cd
left outer join item_master i on ( cd.sku_id = i.SKU_ID )
left outer join carton_hdr ch on ( ch.CARTON_NBR = cd.carton_nbr )
where cd.sku_id in ('111266405','111266399','111266400','111266404')
and ch.stat_code >=50 and ch.STAT_CODE < 99
group by ch.carton_nbr, ch.load_nbr ,i.size_desc, EST_wt
) as x
order by 6 desc 
 with ur

 -- Volume - Carton Level


select x.*
, ( max(x.LORP_VOLUME, x.FM_VOLUME ) - min(x.LORP_VOLUME, x.FM_VOLUME ) ) VOL_DIFFERENCE 
from  ( select distinct ch.CARTON_NBR, ch.load_nbr, i.size_desc,  round ((ch.EST_VOL/1728), 4 ) as FM_VOLUME,  round(sum((cd.UNITS_PAKD * i.UNIT_VOL)/1728),4) as LORP_VOLUME
from carton_dtl cd
left outer join item_master i on ( cd.sku_id = i.SKU_ID )
left outer join carton_hdr ch on ( ch.CARTON_NBR = cd.carton_nbr )
where cd.sku_id in ('111266405','111266399','111266400','111266404')
--and ch.stat_code >=50 and ch.STAT_CODE < 99
group by ch.carton_nbr, ch.load_nbr ,i.size_desc,EST_VOL
) as x
order by 6 desc 
with ur

*/


select * From case_hdr where case_nbr ='0881838316' with ur  1

select * From case_dtl where case_nbr ='0881838316' with ur   

select * from asn_dtl where shpmt_nbr ='12685262' and sku_id = '111266404' 

 