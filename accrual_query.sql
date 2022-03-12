SELECT 
  OPS_NOT_CMPLT.THD_CARR_DINVC_ID, 
  COST_CTR.SAP_CO_NBR, 
  COST_CTR.COST_CTR_ID, 
  OPS_NOT_CMPLT.LOC_NBR, 
  OPS_NOT_CMPLT.INVC_GL_ACCT_ID, 
  OPS_NOT_CMPLT.GL_ACCT_AMT AS AMOUNT 
FROM 
  ( 
    SELECT 
      DINVC_SHP_TYP_CHRG.THD_CARR_DINVC_ID, 
      RIGHT( 
        '000' || DINVC_SHP_TYP_CHRG.LOC_NBR, 
        4 
      ) AS LOC_NBR, 
      DINVC_SHP_TYP_CHRG.INVC_GL_ACCT_ID, 
      SUM( DINVC_SHP_TYP_CHRG.GL_ACCT_AMT ) AS GL_ACCT_AMT 
    FROM 
      CARR_DINVC 
    INNER JOIN DINVC_SHP_TYP_CHRG ON 
      CARR_DINVC.THD_CARR_DINVC_ID = DINVC_SHP_TYP_CHRG.THD_CARR_DINVC_ID 
    WHERE 
      ( 
        ( 
          (CARR_DINVC.CARR_INVC_STAT_CD) NOT IN( 
            6, 
            10 
          ) 
        ) 
        AND( 
          (DINVC_SHP_TYP_CHRG.INVC_GL_ACCT_ID) IS NOT NULL 
        ) 
      ) 
    GROUP BY 
      DINVC_SHP_TYP_CHRG.THD_CARR_DINVC_ID, 
      RIGHT( 
        '000' || DINVC_SHP_TYP_CHRG.LOC_NBR, 
        4 
      ), 
      DINVC_SHP_TYP_CHRG.INVC_GL_ACCT_ID 
  ) AS OPS_NOT_CMPLT 
INNER JOIN COST_CTR ON 
  OPS_NOT_CMPLT.LOC_NBR = COST_CTR.SITE_ID 
INNER JOIN loc_cost_ctr_xref ON 
  loc_cost_ctr_xref.COST_CTR_ID = COST_CTR.COST_CTR_ID 
INNER JOIN sap_co_nbr_xref ON 
  sap_co_nbr_xref.SAP_CO_NBR = COST_CTR.SAP_CO_NBR 
WHERE 
  ( 
    ( 
      (COST_CTR.SAP_CO_NBR)= '1001' 
    ) 
    AND( 
      (COST_CTR.SITE_ID) IS NOT NULL 
      AND(COST_CTR.SITE_ID)<> '' 
     AND cost_ctr.blk_post_flg = 'N' 
     AND cost_ctr.EFF_BGN_DT <= CURRENT_DATE AND cost_ctr.EFF_END_DT >= CURRENT_DATE 
    ) 
  ) 
UNION SELECT 
  OPS_NOT_CMPLT.THD_CARR_DINVC_ID, 
  COST_CTR.SAP_CO_NBR, 
  COST_CTR.COST_CTR_ID, 
  OPS_NOT_CMPLT.LOC_NBR, 
  OPS_NOT_CMPLT.GL_ACCT_ID AS INVC_GL_ACCT_ID, 
  OPS_NOT_CMPLT.GL_ACCT_AMT 
FROM 
  ( 
    SELECT 
      DINVC_FSTYP_CHRG.THD_CARR_DINVC_ID, 
      RIGHT( 
        '000' || DINVC_FSTYP_CHRG.LOC_NBR, 
        4 
      ) AS LOC_NBR, 
      DINVC_FSTYP_CHRG.GL_ACCT_ID, 
      SUM( DINVC_FSTYP_CHRG.GL_ACCT_AMT ) AS GL_ACCT_AMT 
    FROM 
      ( 
        CARR_DINVC 
      INNER JOIN DINVC_FSTYP_CHRG ON 
        CARR_DINVC.THD_CARR_DINVC_ID = DINVC_FSTYP_CHRG.THD_CARR_DINVC_ID 
      ) 
    INNER JOIN CINVC_FEE_TYP_CD ON 
      DINVC_FSTYP_CHRG.CINVC_FEE_TYP_CD = CINVC_FEE_TYP_CD.CINVC_FEE_TYP_CD 
    GROUP BY 
      DINVC_FSTYP_CHRG.THD_CARR_DINVC_ID, 
      RIGHT( 
        '000' || DINVC_FSTYP_CHRG.LOC_NBR, 
        4 
      ), 
      DINVC_FSTYP_CHRG.GL_ACCT_ID, 
      CARR_DINVC.CARR_INVC_STAT_CD 
    HAVING 
      ( 
        ( 
          (DINVC_FSTYP_CHRG.GL_ACCT_ID) IS NOT NULL 
        ) 
        AND( 
          (CARR_DINVC.CARR_INVC_STAT_CD) NOT IN( 
            6, 
            10 
          ) 
        ) 
      ) 
  ) AS OPS_NOT_CMPLT 
INNER JOIN COST_CTR ON 
  OPS_NOT_CMPLT.LOC_NBR = COST_CTR.SITE_ID 
INNER JOIN loc_cost_ctr_xref ON 
  loc_cost_ctr_xref.COST_CTR_ID = COST_CTR.COST_CTR_ID 
INNER JOIN sap_co_nbr_xref ON 
  sap_co_nbr_xref.SAP_CO_NBR = COST_CTR.SAP_CO_NBR 
WHERE 
  ( 
    ( 
      (COST_CTR.SAP_CO_NBR)= '1001' 
    ) 
    AND( 
      (COST_CTR.SITE_ID) IS NOT NULL 
      AND(COST_CTR.SITE_ID)<> '' 
     AND cost_ctr.blk_post_flg = 'N' 
     AND cost_ctr.EFF_BGN_DT <= CURRENT_DATE AND cost_ctr.EFF_END_DT >= CURRENT_DATE 
    ) 
  ) 
UNION SELECT 
  INCR.THD_CARR_DINVC_ID, 
  COST_CTR.SAP_CO_NBR, 
  COST_CTR.COST_CTR_ID, 
  INCR.LOC_NBR, 
  INCR.INVC_GL_ACCT_ID, 
  ( 
    INCR.GL_ACCT_AMT / 3 
  ) AS GL_ACCT_AMT 
FROM 
  ( 
    SELECT 
      DINVC_SHP_TYP_CHRG.THD_CARR_DINVC_ID, 
      RIGHT( 
        '000' || DINVC_SHP_TYP_CHRG.LOC_NBR, 
        4 
      ) AS LOC_NBR, 
      DINVC_SHP_TYP_CHRG.INVC_GL_ACCT_ID, 
      SUM( DINVC_SHP_TYP_CHRG.GL_ACCT_AMT ) AS GL_ACCT_AMT 
    FROM 
      CARR_DINVC 
    INNER JOIN DINVC_SHP_TYP_CHRG ON 
      CARR_DINVC.THD_CARR_DINVC_ID = DINVC_SHP_TYP_CHRG.THD_CARR_DINVC_ID 
    WHERE 
      ( 
        ( 
          (CARR_DINVC.CARR_INVC_STAT_CD)= 10 
        ) 
        AND( 
          (DINVC_SHP_TYP_CHRG.CARR_INVC_TYP_IND)= 'I' 
        ) 
        AND( 
          (CARR_DINVC.FSCL_WK_END_DT)>=( 
            :detailsDate 
          ) 
        ) 
        AND( 
          ( 
            CAST(CARR_DINVC.LAST_UPD_TS AS DATE) 
          )>=( 
            :detailsDate 
          ) 
        ) 
        AND( 
          (DINVC_SHP_TYP_CHRG.INVC_GL_ACCT_ID) IS NOT NULL 
        ) 
      ) 
    GROUP BY 
      DINVC_SHP_TYP_CHRG.THD_CARR_DINVC_ID, 
      RIGHT( 
        '000' || DINVC_SHP_TYP_CHRG.LOC_NBR, 
        4 
      ), 
      DINVC_SHP_TYP_CHRG.INVC_GL_ACCT_ID 
  ) AS INCR 
INNER JOIN COST_CTR ON 
  INCR.LOC_NBR = COST_CTR.SITE_ID 
INNER JOIN loc_cost_ctr_xref ON 
  loc_cost_ctr_xref.COST_CTR_ID = COST_CTR.COST_CTR_ID 
INNER JOIN sap_co_nbr_xref ON 
  sap_co_nbr_xref.SAP_CO_NBR = COST_CTR.SAP_CO_NBR 
WHERE 
  ( 
    ( 
      (COST_CTR.SAP_CO_NBR)= '1001' 
    ) 
    AND( 
      (COST_CTR.SITE_ID) IS NOT NULL 
      AND(COST_CTR.SITE_ID)<> '' 
     AND cost_ctr.blk_post_flg = 'N' 
     AND cost_ctr.EFF_BGN_DT <= CURRENT_DATE AND cost_ctr.EFF_END_DT >= CURRENT_DATE 
    ) 
  ) WITH UR