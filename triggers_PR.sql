
CREATE TRIGGER TPESHIP.INVOICE_SHIP_A_U_1
  AFTER UPDATE
  ON "TPESHIP"."INVOICE_SHIPMENT"
  REFERENCING 
              OLD AS "O"
              NEW AS "N"
  FOR EACH ROW
BEGIN ATOMIC
	  DECLARE vOldValue VARCHAR(500);
  	  DECLARE vfield_name varchar(500);
  	  DECLARE vNewValue VARCHAR(500);
  	  DECLARE VCHGFLAG SMALLINT;
  	  DECLARE TIME_NOW TIMESTAMP;
  	  DECLARE VEVENTSEQ INTEGER;
  	  DECLARE INVOICETYPE INTEGER;
  	  SET VCHGFLAG = 0;
  	  SET TIME_NOW = CURRENT TIMESTAMP ;

  	  IF (o.INV_ID <> n.INV_ID) THEN
      	 SET VFIELD_NAME = 'SHIPMENT'||char(o.tc_company_id)||' INVOICE_ID' ;
    	 SET VOLDVALUE = char(o.INV_ID);
    	 SET VNEWVALUE = char(n.INV_ID);
    	 set (vEventSeq) = (SELECT tmsutils.ROUND(COALESCE(MAX(EVENT_SEQ), 0) + 1)
         	 			    FROM   TPESHIP.INVOICE_EVENT
        					WHERE INV_ID = o.INV_ID) ;

    	 INSERT INTO TPESHIP.INVOICE_EVENT ( INV_ID, EVENT_SEQ, FIELD_NAME, OLD_VALUE, NEW_VALUE, CREATED_SOURCE_TYPE, CREATED_SOURCE, CREATED_DTTM)
      	 VALUES ( o.INV_ID, vEventSeq, vField_Name, vOldValue, vNewValue, n.LAST_UPDATED_SOURCE_TYPE, n.LAST_UPDATED_SOURCE, current timestamp);
    	 SET VCHGFLAG = 1;
  	  END IF;

  	  IF (o.LH_COST != n.LH_COST) or ((o.LH_COST is NULL) and (n.LH_COST is not NULL)) or ((o.LH_COST is not NULL) and (n.LH_COST is NULL)) THEN
      	 SET VFIELD_NAME = 'SHIPMENT '|| coalesce(cast(o.TC_SHIPMENT_ID as varchar(500)),' ') ||' LINEHAUL COST';
    	 SET VOLDVALUE = tmsutils.decimal_to_char(cast(o.LH_COST as decimal(13,2)));
    	 SET VNEWVALUE = tmsutils.decimal_to_char(cast(n.LH_COST as decimal(13,2)));

    	 set (vEventSeq) = (SELECT tmsutils.ROUND(COALESCE(MAX(EVENT_SEQ), 0) + 1)
         	 			    FROM   TPESHIP.INVOICE_EVENT
        					WHERE  INV_ID = o.INV_ID) ;

    	 INSERT INTO TPESHIP.INVOICE_EVENT (INV_ID, EVENT_SEQ, FIELD_NAME, OLD_VALUE, NEW_VALUE, CREATED_SOURCE_TYPE, CREATED_SOURCE, CREATED_DTTM)
      	 VALUES (o.INV_ID, vEventSeq, vField_Name, vOldValue, vNewValue, n.LAST_UPDATED_SOURCE_TYPE, n.LAST_UPDATED_SOURCE, current timestamp);
    	 SET VCHGFLAG = 1;
  	  END IF;
  
  	  IF (o.INV_SHIPMENT_STATUS != n.INV_SHIPMENT_STATUS) or ((o.INV_SHIPMENT_STATUS is NULL) and (n.INV_SHIPMENT_STATUS is not NULL))
  	  	 or ((o.INV_SHIPMENT_STATUS is not NULL) and (n.INV_SHIPMENT_STATUS is NULL)) THEN
    
		 IF (o.INV_SHIPMENT_STATUS IS NULL) THEN
      	 	SET vOldValue = NULL;
    	 ELSE
      	 	SET vOldValue = (SELECT DESCRIPTION
          				  	 FROM 	TPESHIP.INV_SHIPMENT_STATUS
          					 WHERE 	INV_SHIPMENT_STATUS = o.INV_SHIPMENT_STATUS);
    	 END IF;
    	 
		 IF (n.INV_SHIPMENT_STATUS IS NULL) THEN
      	 	SET vNewValue = NULL;
    	 ELSE
      	 	SET vNewValue = (SELECT DESCRIPTION
          				  	 FROM 	TPESHIP.INV_SHIPMENT_STATUS
          					 WHERE 	INV_SHIPMENT_STATUS = n.INV_SHIPMENT_STATUS);
    	 END IF;
		 
    	 -- Added the block For TT 52892,52954
         SET INVOICETYPE = (select INV_ENTRY_TYPE
              			    FROM   TPESHIP.INVOICE i
              				where  i.inv_id = n.inv_id );
         IF (INVOICETYPE=4) THEN
    	 -- Addition End For TT 52892,52954
    	 	SET vField_Name = 'SHIPMENT ' || coalesce(cast(o.TC_SHIPMENT_ID as varchar (500)),' ') || ' STATUS' ;
    		set (vEventSeq) = (SELECT tmsutils.ROUND(COALESCE(MAX(EVENT_SEQ), 0) + 1)
        					   FROM   TPESHIP.INVOICE_EVENT
        					   WHERE  INV_ID = o.INV_ID) ;

    		INSERT INTO TPESHIP.INVOICE_EVENT ( INV_ID, EVENT_SEQ, FIELD_NAME, OLD_VALUE, NEW_VALUE, CREATED_SOURCE_TYPE, CREATED_SOURCE, CREATED_DTTM, INV_SHIPMENT_ID)
      		VALUES (o.INV_ID, vEventSeq, vField_Name, vOldValue, vNewValue, n.LAST_UPDATED_SOURCE_TYPE, n.LAST_UPDATED_SOURCE, current timestamp, o.INV_SHIPMENT_ID) ;
    		SET VCHGFLAG = 1;
  		 END IF;
  	  END IF;
	  
  	  IF (o.TC_SHIPMENT_ID != n.TC_SHIPMENT_ID) or ((o.TC_SHIPMENT_ID is NULL) and (n.TC_SHIPMENT_ID is not NULL)) or ((o.TC_SHIPMENT_ID is not NULL)
  	  	 and (n.TC_SHIPMENT_ID is NULL)) THEN
    	 
		 IF (o.TC_SHIPMENT_ID = '-2147483648') THEN
       	 	SET vField_Name = 'SHIPMENT ID';
      		SET vOldValue = ' ';
      		SET vNewValue = n.TC_SHIPMENT_ID;
			
			set (vEventSeq) = (SELECT tmsutils.ROUND(COALESCE(MAX(EVENT_SEQ), 0) + 1)
          					   FROM   TPESHIP.INVOICE_EVENT
          					   WHERE  INV_ID = o.INV_ID) ;

      		INSERT INTO TPESHIP.INVOICE_EVENT (INV_ID, EVENT_SEQ, FIELD_NAME, OLD_VALUE, NEW_VALUE, CREATED_SOURCE_TYPE, CREATED_SOURCE, CREATED_DTTM, INV_SHIPMENT_ID)
        	VALUES (o.INV_ID, vEventSeq, vField_Name,vOldValue,vNewValue, n.LAST_UPDATED_SOURCE_TYPE, n.LAST_UPDATED_SOURCE, current timestamp, o.INV_SHIPMENT_ID);
    	 ELSE
       	 	SET vField_Name = 'SHIPMENT ID';
      		SET vOldValue = o.TC_SHIPMENT_ID;
      		SET vNewValue = n.TC_SHIPMENT_ID;
      		set (vEventSeq) = (SELECT tmsutils.ROUND(COALESCE(MAX(EVENT_SEQ), 0) + 1)
          					   FROM   TPESHIP.INVOICE_EVENT
          					   WHERE  INV_ID = o.INV_ID) ;
      
	  		INSERT INTO TPESHIP.INVOICE_EVENT(INV_ID, EVENT_SEQ, FIELD_NAME, OLD_VALUE, NEW_VALUE, CREATED_SOURCE_TYPE, CREATED_SOURCE, CREATED_DTTM, INV_SHIPMENT_ID)
        	VALUES (o.INV_ID, vEventSeq, vField_Name, vOldValue, vNewValue, n.LAST_UPDATED_SOURCE_TYPE, n.LAST_UPDATED_SOURCE, current timestamp, o.INV_SHIPMENT_ID);
    	 END IF;
    	 
		 SET VCHGFLAG = 1;
  	 END IF;
  	 
	 IF (o.O_FACILITY_ID != n.O_FACILITY_ID) or ((o.O_FACILITY_ID is NULL)
  and (n.O_FACILITY_ID is not NULL))
  or ((o.O_FACILITY_ID is not NULL)
  and (n.O_FACILITY_ID is NULL)) THEN
    SET vField_Name = 'SHIPMENT ' || coalesce(cast(o.TC_SHIPMENT_ID as varchar(500)),' ') || ' ORIGIN FACILITY ID' ;  
      
    IF o.O_FACILITY_ID is null then
      SET vOldValue = '';
    else
      SET VOLDVALUE = (
        SELECT FACILITY_ALIAS_ID
          FROM TPESHIP.FACILITY_ALIAS
          WHERE FACILITY_ID = o.O_FACILITY_ID
            AND TC_COMPANY_ID = o.TC_COMPANY_ID
            and IS_PRIMARY = 1);
    end if;
    IF n.O_FACILITY_ID is null then
      SET vnewValue = '';
    else
      SET vnewValue = (
        SELECT FACILITY_ALIAS_ID
          FROM TPESHIP.FACILITY_ALIAS
          WHERE FACILITY_ID = n.O_FACILITY_ID
            AND TC_COMPANY_ID = n.TC_COMPANY_ID
            and IS_PRIMARY = 1);
    end if;
    set (vEventSeq) = (
      SELECT tmsutils.ROUND(COALESCE(MAX(EVENT_SEQ), 0) + 1)
        FROM TPESHIP.INVOICE_EVENT
        WHERE INV_ID = o.INV_ID) ;
    INSERT INTO TPESHIP.INVOICE_EVENT ( INV_ID, EVENT_SEQ, FIELD_NAME, OLD_VALUE, 
      NEW_VALUE, CREATED_SOURCE_TYPE, CREATED_SOURCE, CREATED_DTTM, 
      INV_SHIPMENT_ID )
      VALUES (o.INV_ID, vEventSeq, vField_Name,vOldValue,vNewValue, 
        n.LAST_UPDATED_SOURCE_TYPE, n.LAST_UPDATED_SOURCE, current timestamp, 
        o.INV_SHIPMENT_ID ) ;
    SET VCHGFLAG = 1;
  END IF;
  IF (o.O_NAME != n.O_NAME)
  or ((o.O_NAME is NULL)
  and (n.O_NAME is not NULL))
  or ((o.O_NAME is not NULL)
  and (n.O_NAME is NULL)) THEN
    SET vField_Name = 'SHIPMENT ' || coalesce(cast(o.TC_SHIPMENT_ID as varchar(500)),' ') || ' ORIGIN NAME';
    SET vOldValue = o.O_NAME;
    SET vNewValue = n.O_NAME;
    set (vEventSeq) = (
      SELECT tmsutils.ROUND(COALESCE(MAX(EVENT_SEQ), 0) + 1)
        FROM TPESHIP.INVOICE_EVENT
        WHERE INV_ID = o.INV_ID) ;
    INSERT INTO TPESHIP.INVOICE_EVENT ( INV_ID, EVENT_SEQ, FIELD_NAME, OLD_VALUE, 
      NEW_VALUE, CREATED_SOURCE_TYPE, CREATED_SOURCE, CREATED_DTTM, 
      INV_SHIPMENT_ID )
      VALUES (o.INV_ID, vEventSeq, vField_Name,vOldValue,vNewValue, 
        n.LAST_UPDATED_SOURCE_TYPE, n.LAST_UPDATED_SOURCE, current timestamp, 
        o.INV_SHIPMENT_ID ) ;
    SET VCHGFLAG = 1;
  END IF;
  IF (o.O_ADDRESS != n.O_ADDRESS)
  or ((o.O_ADDRESS is NULL)
  and (n.O_ADDRESS is not NULL))
  or ((o.O_ADDRESS is not NULL)
  and (n.O_ADDRESS is NULL)) THEN
    SET vField_Name = 'SHIPMENT ' || coalesce(cast(o.TC_SHIPMENT_ID as varchar(500)),' ') || ' ORIGIN ADDRESS';
    SET vOldValue = o.O_ADDRESS;
    SET vNewValue = n.O_ADDRESS;
    set (vEventSeq) = (
      SELECT tmsutils.ROUND(COALESCE(MAX(EVENT_SEQ), 0) + 1)
        FROM TPESHIP.INVOICE_EVENT
        WHERE INV_ID = o.INV_ID) ;
    INSERT INTO TPESHIP.INVOICE_EVENT ( INV_ID, EVENT_SEQ, FIELD_NAME, OLD_VALUE, 
      NEW_VALUE, CREATED_SOURCE_TYPE, CREATED_SOURCE, CREATED_DTTM, 
      INV_SHIPMENT_ID )
      VALUES (o.INV_ID, vEventSeq, vField_Name,vOldValue,vNewValue, 
        n.LAST_UPDATED_SOURCE_TYPE, n.LAST_UPDATED_SOURCE, current timestamp, 
        o.INV_SHIPMENT_ID ) ;
    SET VCHGFLAG = 1;
  END IF;
  IF (o.O_CITY != n.O_CITY)
  or ((o.O_CITY is NULL)
  and (n.O_CITY is not NULL))
  or ((o.O_CITY is not NULL)
  and (n.O_CITY is NULL)) THEN
    SET vField_Name = 'SHIPMENT ' || coalesce(cast(o.TC_SHIPMENT_ID as varchar
      (500)),' ') || ' ORIGIN CITY';
    SET vOldValue = o.O_CITY;
    SET vNewValue = n.O_CITY;
    set (vEventSeq) = (
      SELECT tmsutils.ROUND(COALESCE(MAX(EVENT_SEQ), 0) + 1)
        FROM TPESHIP.INVOICE_EVENT
        WHERE INV_ID = o.INV_ID) ;
    INSERT INTO TPESHIP.INVOICE_EVENT ( INV_ID, EVENT_SEQ, FIELD_NAME, OLD_VALUE, 
      NEW_VALUE, CREATED_SOURCE_TYPE, CREATED_SOURCE, CREATED_DTTM, 
      INV_SHIPMENT_ID )
      VALUES (o.INV_ID, vEventSeq, vField_Name,vOldValue,vNewValue, 
        n.LAST_UPDATED_SOURCE_TYPE, n.LAST_UPDATED_SOURCE, current timestamp, 
        o.INV_SHIPMENT_ID ) ;
    SET VCHGFLAG = 1;
  END IF;
  IF (o.O_COUNTY != n.O_COUNTY)
  or ((o.O_COUNTY is NULL)
  and (n.O_COUNTY is not NULL))
  or ((o.O_COUNTY is not NULL)
  and (n.O_COUNTY is NULL)) THEN
    SET vField_Name = 'SHIPMENT ' || coalesce(cast(o.TC_SHIPMENT_ID as varchar
      (500)),' ') || ' ORIGIN COUNTY';
    SET vOldValue = o.O_COUNTY;
    SET vNewValue = n.O_COUNTY;
    set (vEventSeq) = (
      SELECT tmsutils.ROUND(COALESCE(MAX(EVENT_SEQ), 0) + 1)
        FROM TPESHIP.INVOICE_EVENT
        WHERE INV_ID = o.INV_ID) ;
    INSERT INTO TPESHIP.INVOICE_EVENT ( INV_ID, EVENT_SEQ, FIELD_NAME, OLD_VALUE, 
      NEW_VALUE, CREATED_SOURCE_TYPE, CREATED_SOURCE, CREATED_DTTM, 
      INV_SHIPMENT_ID )
      VALUES (o.INV_ID, vEventSeq, vField_Name,vOldValue,vNewValue, 
        n.LAST_UPDATED_SOURCE_TYPE, n.LAST_UPDATED_SOURCE, current timestamp, 
        o.INV_SHIPMENT_ID ) ;
    SET VCHGFLAG = 1;
  END IF;
  IF (o.O_STATE_PROV != n.O_STATE_PROV)
  or ((o.O_STATE_PROV is NULL)
  and (n.O_STATE_PROV is not NULL))
  or ((o.O_STATE_PROV is not NULL)
  and (n.O_STATE_PROV is NULL)) THEN
    SET vField_Name = 'SHIPMENT ' || coalesce(cast(o.TC_SHIPMENT_ID as varchar
      (500)),' ') || ' ORIGIN PROVINCE';
    SET vOldValue = o.O_STATE_PROV;
    SET vNewValue = n.O_STATE_PROV;
    set (vEventSeq) = (
      SELECT tmsutils.ROUND(COALESCE(MAX(EVENT_SEQ), 0) + 1)
        FROM TPESHIP.INVOICE_EVENT
        WHERE INV_ID = o.INV_ID) ;
    INSERT INTO TPESHIP.INVOICE_EVENT ( INV_ID, EVENT_SEQ, FIELD_NAME, OLD_VALUE, 
      NEW_VALUE, CREATED_SOURCE_TYPE, CREATED_SOURCE, CREATED_DTTM, 
      INV_SHIPMENT_ID )
      VALUES (o.INV_ID, vEventSeq, vField_Name,vOldValue,vNewValue, 
        n.LAST_UPDATED_SOURCE_TYPE, n.LAST_UPDATED_SOURCE, current timestamp, 
        o.INV_SHIPMENT_ID ) ;
    SET VCHGFLAG = 1;
  END IF;
  IF (o.O_POSTAL_CODE != n.O_POSTAL_CODE)
  or ((o.O_POSTAL_CODE is NULL)
  and (n.O_POSTAL_CODE is not NULL))
  or ((o.O_POSTAL_CODE is not NULL)
  and (n.O_POSTAL_CODE is NULL)) THEN
    SET vField_Name = 'SHIPMENT ' || coalesce(cast(o.TC_SHIPMENT_ID as varchar
      (500)),' ') || ' ORIGIN POSTAL CODE' ;
    SET vOldValue = o.O_POSTAL_CODE;
    SET vNewValue = n.O_POSTAL_CODE;
    set (vEventSeq) = (
      SELECT tmsutils.ROUND(COALESCE(MAX(EVENT_SEQ), 0) + 1)
        FROM TPESHIP.INVOICE_EVENT
        WHERE INV_ID = o.INV_ID) ;
    INSERT INTO TPESHIP.INVOICE_EVENT ( INV_ID, EVENT_SEQ, FIELD_NAME, OLD_VALUE, 
      NEW_VALUE, CREATED_SOURCE_TYPE, CREATED_SOURCE, CREATED_DTTM, 
      INV_SHIPMENT_ID )
      VALUES (o.INV_ID, vEventSeq, vField_Name,vOldValue,vNewValue, 
        n.LAST_UPDATED_SOURCE_TYPE, n.LAST_UPDATED_SOURCE, current timestamp, 
        o.INV_SHIPMENT_ID ) ;
    SET VCHGFLAG = 1;
  END IF;
  IF (o.O_COUNTRY_CODE != n.O_COUNTRY_CODE)
  or ((o.O_COUNTRY_CODE is NULL)
  and (n.O_COUNTRY_CODE is not NULL))
  or ((o.O_COUNTRY_CODE is not NULL)
  and (n.O_COUNTRY_CODE is NULL)) THEN
    SET vField_Name = 'SHIPMENT ' || coalesce(cast(o.TC_SHIPMENT_ID as varchar
      (500)),' ') || ' ORIGIN COUNTRY';
    SET vOldValue = o.O_COUNTRY_CODE;
    SET vNewValue = n.O_COUNTRY_CODE;
    set (vEventSeq) = (
      SELECT tmsutils.ROUND(COALESCE(MAX(EVENT_SEQ), 0) + 1)
        FROM TPESHIP.INVOICE_EVENT
        WHERE INV_ID = o.INV_ID) ;
    INSERT INTO TPESHIP.INVOICE_EVENT ( INV_ID, EVENT_SEQ, FIELD_NAME, OLD_VALUE, 
      NEW_VALUE, CREATED_SOURCE_TYPE, CREATED_SOURCE, CREATED_DTTM, 
      INV_SHIPMENT_ID )
      VALUES (o.INV_ID, vEventSeq, vField_Name,vOldValue,vNewValue, 
        n.LAST_UPDATED_SOURCE_TYPE, n.LAST_UPDATED_SOURCE, current timestamp, 
        o.INV_SHIPMENT_ID ) ;
    SET VCHGFLAG = 1;
  END IF;
  IF (o.D_FACILITY_ID != n.D_FACILITY_ID)
  or ((o.D_FACILITY_ID is NULL)
  and (n.D_FACILITY_ID is not NULL))
  or ((o.D_FACILITY_ID is not NULL)
  and (n.D_FACILITY_ID is NULL)) THEN
    SET vField_Name = 'SHIPMENT ' || coalesce(cast(o.TC_SHIPMENT_ID as varchar
      (500)),' ') || ' DESTINATION FACILITY ID';  
      

    IF o.D_FACILITY_ID is null then
      SET vOldValue = '';
    else
      SET VOLDVALUE = (
        SELECT FACILITY_ALIAS_ID
          FROM TPESHIP.FACILITY_ALIAS
          WHERE FACILITY_ID = o.D_FACILITY_ID
            AND TC_COMPANY_ID = o.TC_COMPANY_ID
            and IS_PRIMARY = 1);
    end if;
    IF n.D_FACILITY_ID is null then
      SET vnewValue = '';
    else
      SET vnewValue = (
        SELECT FACILITY_ALIAS_ID
          FROM TPESHIP.FACILITY_ALIAS
          WHERE FACILITY_ID = n.D_FACILITY_ID
            AND TC_COMPANY_ID = n.TC_COMPANY_ID
            and IS_PRIMARY = 1);
    end if;
    set (vEventSeq) = (
      SELECT tmsutils.ROUND(COALESCE(MAX(EVENT_SEQ), 0) + 1)
        FROM TPESHIP.INVOICE_EVENT
        WHERE INV_ID = o.INV_ID) ;
    INSERT INTO TPESHIP.INVOICE_EVENT ( INV_ID, EVENT_SEQ, FIELD_NAME, OLD_VALUE, 
      NEW_VALUE, CREATED_SOURCE_TYPE, CREATED_SOURCE, CREATED_DTTM, 
      INV_SHIPMENT_ID )
      VALUES (o.INV_ID, vEventSeq, vField_Name,vOldValue,vNewValue, 
        n.LAST_UPDATED_SOURCE_TYPE, n.LAST_UPDATED_SOURCE, current timestamp, 
        o.INV_SHIPMENT_ID ) ;
    SET VCHGFLAG = 1;
  END IF;
  IF (o.D_NAME != n.D_NAME)
  or ((o.D_NAME is NULL)
  and (n.D_NAME is not NULL))
  or ((o.D_NAME is not NULL)
  and (n.D_NAME is NULL)) THEN
    SET vField_Name = 'SHIPMENT ' || coalesce(cast(o.TC_SHIPMENT_ID as varchar
      (500)),' ') || ' DESTINATION NAME';
    SET vOldValue = o.D_NAME;
    SET vNewValue = n.D_NAME;
    set (vEventSeq) = (
      SELECT tmsutils.ROUND(COALESCE(MAX(EVENT_SEQ), 0) + 1)
        FROM TPESHIP.INVOICE_EVENT
        WHERE INV_ID = o.INV_ID) ;
    INSERT INTO TPESHIP.INVOICE_EVENT ( INV_ID, EVENT_SEQ, FIELD_NAME, OLD_VALUE, 
      NEW_VALUE, CREATED_SOURCE_TYPE, CREATED_SOURCE, CREATED_DTTM, 
      INV_SHIPMENT_ID )
      VALUES (o.INV_ID, vEventSeq, vField_Name,vOldValue,vNewValue, 
        n.LAST_UPDATED_SOURCE_TYPE, n.LAST_UPDATED_SOURCE, current timestamp, 
        o.INV_SHIPMENT_ID ) ;
    SET VCHGFLAG = 1;
  END IF;
  IF (o.D_ADDRESS != n.D_ADDRESS)
  or ((o.D_ADDRESS is NULL)
  and (n.D_ADDRESS is not NULL))
  or ((o.D_ADDRESS is not NULL)
  and (n.D_ADDRESS is NULL)) THEN
    SET vField_Name = 'SHIPMENT ' || coalesce(cast(o.TC_SHIPMENT_ID as varchar
      (500)),' ') || ' DESTINATION ADDRESS' ;
    SET vOldValue = o.D_ADDRESS;
    SET vNewValue = n.D_ADDRESS;
    set (vEventSeq) = (
      SELECT tmsutils.ROUND(COALESCE(MAX(EVENT_SEQ), 0) + 1)
        FROM TPESHIP.INVOICE_EVENT
        WHERE INV_ID = o.INV_ID) ;
    INSERT INTO TPESHIP.INVOICE_EVENT ( INV_ID, EVENT_SEQ, FIELD_NAME, OLD_VALUE, 
      NEW_VALUE, CREATED_SOURCE_TYPE, CREATED_SOURCE, CREATED_DTTM, 
      INV_SHIPMENT_ID )
      VALUES (o.INV_ID, vEventSeq, vField_Name,vOldValue,vNewValue, 
        n.LAST_UPDATED_SOURCE_TYPE, n.LAST_UPDATED_SOURCE, current timestamp, 
        o.INV_SHIPMENT_ID ) ;
    SET VCHGFLAG = 1;
  END IF;
  IF (o.D_CITY != n.D_CITY)
  or ((o.D_CITY is NULL)
  and (n.D_CITY is not NULL))
  or ((o.D_CITY is not NULL)
  and (n.D_CITY is NULL)) THEN
    SET vField_Name = 'SHIPMENT ' || coalesce(cast(o.TC_SHIPMENT_ID as varchar
      (500)),' ') || ' DESTINATION CITY';
    SET vOldValue = o.D_CITY;
    SET vNewValue = n.D_CITY;
    set (vEventSeq) = (
      SELECT tmsutils.ROUND(COALESCE(MAX(EVENT_SEQ), 0) + 1)
        FROM TPESHIP.INVOICE_EVENT
        WHERE INV_ID = o.INV_ID) ;
    INSERT INTO TPESHIP.INVOICE_EVENT ( INV_ID, EVENT_SEQ, FIELD_NAME, OLD_VALUE, 
      NEW_VALUE, CREATED_SOURCE_TYPE, CREATED_SOURCE, CREATED_DTTM, 
      INV_SHIPMENT_ID )
      VALUES (o.INV_ID, vEventSeq, vField_Name,vOldValue,vNewValue, 
        n.LAST_UPDATED_SOURCE_TYPE, n.LAST_UPDATED_SOURCE, current timestamp, 
        o.INV_SHIPMENT_ID ) ;
    SET VCHGFLAG = 1;
  END IF;
  IF (o.D_COUNTY != n.D_COUNTY)
  or ((o.D_COUNTY is NULL)
  and (n.D_COUNTY is not NULL))
  or ((o.D_COUNTY is not NULL)
  and (n.D_COUNTY is NULL)) THEN
    SET vField_Name = 'SHIPMENT ' || coalesce(cast(o.TC_SHIPMENT_ID as varchar
      (500)),' ') || ' DESTINATION COUNTY' ;
    SET vOldValue = o.D_COUNTY;
    SET vNewValue = n.D_COUNTY;
    set (vEventSeq) = (
      SELECT tmsutils.ROUND(COALESCE(MAX(EVENT_SEQ), 0) + 1)
        FROM TPESHIP.INVOICE_EVENT
        WHERE INV_ID = o.INV_ID) ;
    INSERT INTO TPESHIP.INVOICE_EVENT ( INV_ID, EVENT_SEQ, FIELD_NAME, OLD_VALUE, 
      NEW_VALUE, CREATED_SOURCE_TYPE, CREATED_SOURCE, CREATED_DTTM, 
      INV_SHIPMENT_ID )
      VALUES (o.INV_ID, vEventSeq, vField_Name,vOldValue,vNewValue, 
        n.LAST_UPDATED_SOURCE_TYPE, n.LAST_UPDATED_SOURCE, current timestamp, 
        o.INV_SHIPMENT_ID ) ;
    SET VCHGFLAG = 1;
  END IF;
  IF (o.D_STATE_PROV != n.D_STATE_PROV)
  or ((o.D_STATE_PROV is NULL)
  and (n.D_STATE_PROV is not NULL))
  or ((o.D_STATE_PROV is not NULL)
  and (n.D_STATE_PROV is NULL)) THEN
    SET vField_Name = 'SHIPMENT ' || coalesce(cast(o.TC_SHIPMENT_ID as varchar
      (500)),' ') || ' DESTINATION PROVINCE';
    SET vOldValue = o.D_STATE_PROV;
    SET vNewValue = n.D_STATE_PROV;
    set (vEventSeq) = (
      SELECT tmsutils.ROUND(COALESCE(MAX(EVENT_SEQ), 0) + 1)
        FROM TPESHIP.INVOICE_EVENT
        WHERE INV_ID = o.INV_ID) ;
    INSERT INTO TPESHIP.INVOICE_EVENT ( INV_ID, EVENT_SEQ, FIELD_NAME, OLD_VALUE, 
      NEW_VALUE, CREATED_SOURCE_TYPE, CREATED_SOURCE, CREATED_DTTM, 
      INV_SHIPMENT_ID )
      VALUES (o.INV_ID, vEventSeq, vField_Name,vOldValue,vNewValue, 
        n.LAST_UPDATED_SOURCE_TYPE, n.LAST_UPDATED_SOURCE, current timestamp, 
        o.INV_SHIPMENT_ID ) ;
    SET VCHGFLAG = 1;
  END IF;
  IF (o.D_POSTAL_CODE != n.D_POSTAL_CODE)
  or ((o.D_POSTAL_CODE is NULL)
  and (n.D_POSTAL_CODE is not NULL))
  or ((o.D_POSTAL_CODE is not NULL)
  and (n.D_POSTAL_CODE is NULL)) THEN
    SET vField_Name = 'SHIPMENT ' || coalesce(cast(o.TC_SHIPMENT_ID as varchar
      (500)),' ') || ' DESTINATION POSTAL CODE';
    SET vOldValue = o.D_POSTAL_CODE;
    SET vNewValue = n.D_POSTAL_CODE;
    set (vEventSeq) = (
      SELECT tmsutils.ROUND(COALESCE(MAX(EVENT_SEQ), 0) + 1)
        FROM TPESHIP.INVOICE_EVENT
        WHERE INV_ID = o.INV_ID) ;
    INSERT INTO TPESHIP.INVOICE_EVENT ( INV_ID, EVENT_SEQ, FIELD_NAME, OLD_VALUE, 
      NEW_VALUE, CREATED_SOURCE_TYPE, CREATED_SOURCE, CREATED_DTTM, 
      INV_SHIPMENT_ID )
      VALUES (o.INV_ID, vEventSeq, vField_Name,vOldValue,vNewValue, 
        n.LAST_UPDATED_SOURCE_TYPE, n.LAST_UPDATED_SOURCE, current timestamp, 
        o.INV_SHIPMENT_ID ) ;
    SET VCHGFLAG = 1;
  END IF;
  
  IF (o.D_COUNTRY_CODE != n.D_COUNTRY_CODE)
  or ((o.D_COUNTRY_CODE is NULL)
  and (n.D_COUNTRY_CODE is not NULL))
  or ((o.D_COUNTRY_CODE is not NULL)
  and (n.D_COUNTRY_CODE is NULL)) THEN
    SET vField_Name = 'SHIPMENT ' || coalesce(cast(o.TC_SHIPMENT_ID as varchar
      (500)),' ') || ' DESTINATION COUNTRY' ;
    SET vOldValue = o.D_COUNTRY_CODE;
    SET vNewValue = n.D_COUNTRY_CODE;
    set (vEventSeq) = (
      SELECT tmsutils.ROUND(COALESCE(MAX(EVENT_SEQ), 0) + 1)
        FROM TPESHIP.INVOICE_EVENT
        WHERE INV_ID = o.INV_ID) ;
    INSERT INTO TPESHIP.INVOICE_EVENT ( INV_ID, EVENT_SEQ, FIELD_NAME, OLD_VALUE, 
      NEW_VALUE, CREATED_SOURCE_TYPE, CREATED_SOURCE, CREATED_DTTM, 
      INV_SHIPMENT_ID )
      VALUES (o.INV_ID, vEventSeq, vField_Name,vOldValue,vNewValue, 
        n.LAST_UPDATED_SOURCE_TYPE, n.LAST_UPDATED_SOURCE, current timestamp, 
        o.INV_SHIPMENT_ID ) ;
    SET VCHGFLAG = 1;
  END IF;
  
  IF (o.ASSIGNED_CARRIER_CODE != n.ASSIGNED_CARRIER_CODE)
  or ((o.ASSIGNED_CARRIER_CODE is NULL)
  and (n.ASSIGNED_CARRIER_CODE is not NULL))
  or ((o.ASSIGNED_CARRIER_CODE is not NULL)
  and (n.ASSIGNED_CARRIER_CODE is NULL)) THEN
    SET vField_Name = 'SHIPMENT ' || coalesce(cast(o.TC_SHIPMENT_ID as varchar
      (500)),' ') || ' CARRIER ASSIGNED';
    SET vOldValue = o.ASSIGNED_CARRIER_CODE;
    SET vNewValue = n.ASSIGNED_CARRIER_CODE;
    set (vEventSeq) = (
      SELECT tmsutils.ROUND(COALESCE(MAX(EVENT_SEQ), 0) + 1)
        FROM TPESHIP.INVOICE_EVENT
        WHERE INV_ID = o.INV_ID) ;
    INSERT INTO TPESHIP.INVOICE_EVENT ( INV_ID, EVENT_SEQ, FIELD_NAME, OLD_VALUE, 
      NEW_VALUE, CREATED_SOURCE_TYPE, CREATED_SOURCE, CREATED_DTTM, 
      INV_SHIPMENT_ID )
      VALUES (o.INV_ID, vEventSeq, vField_Name,vOldValue,vNewValue, 
        n.LAST_UPDATED_SOURCE_TYPE, n.LAST_UPDATED_SOURCE, current timestamp, 
        o.INV_SHIPMENT_ID ) ;
    SET VCHGFLAG = 1;
  END IF;
  
  IF (o.PICKUP_DTTM != n.PICKUP_DTTM)
  or ((o.PICKUP_DTTM is NULL)
  and (n.PICKUP_DTTM is not NULL))
  or ((o.PICKUP_DTTM is not NULL)
  and (n.PICKUP_DTTM is NULL)) THEN
    SET vField_Name = 'SHIPMENT ' || coalesce(cast(o.TC_SHIPMENT_ID as varchar
      (500)),' ') || ' SHIP DATE';
    SET vOldValue = tmsutils.date_char(o.PICKUP_DTTM,'MM/DD/YY');
    SET vNewValue = tmsutils.date_char(n.PICKUP_DTTM,'MM/DD/YY');
    set (vEventSeq) = (
      SELECT tmsutils.ROUND(COALESCE(MAX(EVENT_SEQ), 0) + 1)
        FROM TPESHIP.INVOICE_EVENT
        WHERE INV_ID = o.INV_ID) ;
    INSERT INTO TPESHIP.INVOICE_EVENT ( INV_ID, EVENT_SEQ, FIELD_NAME, OLD_VALUE, 
      NEW_VALUE, CREATED_SOURCE_TYPE, CREATED_SOURCE, CREATED_DTTM, 
      INV_SHIPMENT_ID )
      VALUES (o.INV_ID, vEventSeq, vField_Name,vOldValue,vNewValue, 
        n.LAST_UPDATED_SOURCE_TYPE, n.LAST_UPDATED_SOURCE, current timestamp, 
        o.INV_SHIPMENT_ID ) ;
    SET VCHGFLAG = 1;
  END IF;
  
  IF (o.DELIVERY_DTTM != n.DELIVERY_DTTM)
  or ((o.DELIVERY_DTTM is NULL)
  and (n.DELIVERY_DTTM is not NULL))
  or ((o.DELIVERY_DTTM is not NULL)
  and (n.DELIVERY_DTTM is NULL)) THEN
    SET vField_Name = 'SHIPMENT ' || coalesce(cast(o.TC_SHIPMENT_ID as varchar
      (500)),' ') || ' SHIPMENT RECEIPT DATE';
    SET vOldValue = tmsutils.date_char(o.DELIVERY_DTTM,'MM/DD/YY');
    SET vNewValue = tmsutils.date_char( n.DELIVERY_DTTM,'MM/DD/YY');
    set (vEventSeq) = (
      SELECT tmsutils.ROUND(COALESCE(MAX(EVENT_SEQ), 0) + 1)
        FROM TPESHIP.INVOICE_EVENT
        WHERE INV_ID = o.INV_ID) ;
    INSERT INTO TPESHIP.INVOICE_EVENT ( INV_ID, EVENT_SEQ, FIELD_NAME, OLD_VALUE, 
      NEW_VALUE, CREATED_SOURCE_TYPE, CREATED_SOURCE, CREATED_DTTM, 
      INV_SHIPMENT_ID )
      VALUES (o.INV_ID, vEventSeq, vField_Name,vOldValue,vNewValue, 
        n.LAST_UPDATED_SOURCE_TYPE, n.LAST_UPDATED_SOURCE, current timestamp, 
        o.INV_SHIPMENT_ID ) ;
    SET VCHGFLAG = 1;
  END IF;
  
  IF (o.DISTANCE != n.DISTANCE)
  or ((o.DISTANCE is NULL)
  and (n.DISTANCE is not NULL))
  or ((o.DISTANCE is not NULL)
  and (n.DISTANCE is NULL)) THEN
    SET vField_Name = 'SHIPMENT ' || coalesce(cast(o.TC_SHIPMENT_ID as varchar
      (500)),' ') || ' DISTANCE';
    SET vOldValue = tmsutils.decimal_to_char(o.DISTANCE);
    SET vNewValue = tmsutils.decimal_to_char(n.DISTANCE);
    set (vEventSeq) = (
      SELECT tmsutils.ROUND(COALESCE(MAX(EVENT_SEQ), 0) + 1)
        FROM TPESHIP.INVOICE_EVENT
        WHERE INV_ID = o.INV_ID) ;
    INSERT INTO TPESHIP.INVOICE_EVENT ( INV_ID, EVENT_SEQ, FIELD_NAME, OLD_VALUE, 
      NEW_VALUE, CREATED_SOURCE_TYPE, CREATED_SOURCE, CREATED_DTTM, 
      INV_SHIPMENT_ID )
      VALUES (o.INV_ID, vEventSeq, vField_Name,vOldValue,vNewValue, 
        n.LAST_UPDATED_SOURCE_TYPE, n.LAST_UPDATED_SOURCE, current timestamp, 
        o.INV_SHIPMENT_ID ) ;
    SET VCHGFLAG = 1;
  END IF;
  
  IF (o.RATE != n.RATE)
  or ((o.RATE is NULL)
  and (n.RATE is not NULL))
  or ((o.RATE is not NULL)
  and (n.RATE is NULL)) THEN
    SET vField_Name = 'SHIPMENT ' || coalesce(cast(o.TC_SHIPMENT_ID as varchar
      (500)),' ') || ' RATE';
    SET vOldValue = tmsutils.decimal_to_char(cast(o.RATE as decimal(13,2)));
    SET vNewValue = tmsutils.decimal_to_char(cast(n.RATE as decimal(13,2)));
    set (vEventSeq) = (
      SELECT tmsutils.ROUND(COALESCE(MAX(EVENT_SEQ), 0) + 1)
        FROM TPESHIP.INVOICE_EVENT
        WHERE INV_ID = o.INV_ID) ;
    INSERT INTO TPESHIP.INVOICE_EVENT ( INV_ID, EVENT_SEQ, FIELD_NAME, OLD_VALUE, 
      NEW_VALUE, CREATED_SOURCE_TYPE, CREATED_SOURCE, CREATED_DTTM, 
      INV_SHIPMENT_ID )
      VALUES (o.INV_ID, vEventSeq, vField_Name,vOldValue,vNewValue, 
        n.LAST_UPDATED_SOURCE_TYPE, n.LAST_UPDATED_SOURCE, current timestamp, 
        o.INV_SHIPMENT_ID ) ;
    SET VCHGFLAG = 1;
  END IF;
  
  IF (o.STOP_COST != n.STOP_COST)
  or ((o.STOP_COST is NULL)
  and (n.STOP_COST is not NULL))
  or ((o.STOP_COST is not NULL)
  and (n.STOP_COST is NULL)) THEN
    SET vField_Name = 'SHIPMENT ' || coalesce(cast(o.TC_SHIPMENT_ID as varchar
      (500)),' ') || ' STOP CHARGE';
    SET vOldValue = tmsutils.decimal_to_char(o.STOP_COST);
    SET vNewValue = tmsutils.decimal_to_char(n.STOP_COST );
    set (vEventSeq) = (
      SELECT tmsutils.ROUND(COALESCE(MAX(EVENT_SEQ), 0) + 1)
        FROM TPESHIP.INVOICE_EVENT
        WHERE INV_ID = o.INV_ID) ;
    INSERT INTO TPESHIP.INVOICE_EVENT ( INV_ID, EVENT_SEQ, FIELD_NAME, OLD_VALUE, 
      NEW_VALUE, CREATED_SOURCE_TYPE, CREATED_SOURCE, CREATED_DTTM, 
      INV_SHIPMENT_ID )
      VALUES (o.INV_ID, vEventSeq, vField_Name,vOldValue,vNewValue, 
        n.LAST_UPDATED_SOURCE_TYPE, n.LAST_UPDATED_SOURCE, current timestamp, 
        o.INV_SHIPMENT_ID ) ;
    SET VCHGFLAG = 1;
  END IF;
  
  IF (o.FINANCIAL_WEIGHT != n.FINANCIAL_WEIGHT)
  or ((o.FINANCIAL_WEIGHT is NULL)
  and (n.FINANCIAL_WEIGHT is not NULL))
  or ((o.FINANCIAL_WEIGHT is not NULL)
  and (n.FINANCIAL_WEIGHT is NULL)) THEN
    SET vField_Name = 'SHIPMENT ' || coalesce(cast(o.TC_SHIPMENT_ID as varchar
      (500)),' ') || ' FINANCIAL WEIGHT';
    SET vOldValue = tmsutils.decimal_to_char(cast(o.FINANCIAL_WEIGHT as 
      decimal(13,2)));
    SET vNewValue = tmsutils.decimal_to_char(cast(n.FINANCIAL_WEIGHT as 
      decimal(13,2)));
    set (vEventSeq) = (
      SELECT tmsutils.ROUND(COALESCE(MAX(EVENT_SEQ), 0) + 1)
        FROM TPESHIP.INVOICE_EVENT
        WHERE INV_ID = o.INV_ID) ;
    INSERT INTO TPESHIP.INVOICE_EVENT ( INV_ID, EVENT_SEQ, FIELD_NAME, OLD_VALUE, 
      NEW_VALUE, CREATED_SOURCE_TYPE, CREATED_SOURCE, CREATED_DTTM, 
      INV_SHIPMENT_ID )
      VALUES (o.INV_ID, vEventSeq, vField_Name,vOldValue,vNewValue, 
        n.LAST_UPDATED_SOURCE_TYPE, n.LAST_UPDATED_SOURCE, current timestamp, 
        o.INV_SHIPMENT_ID ) ;
    SET VCHGFLAG = 1;
  END IF;
  
  IF (o.ACTUAL_WEIGHT != n.ACTUAL_WEIGHT)
  or ((o.ACTUAL_WEIGHT is NULL)
  and (n.ACTUAL_WEIGHT is not NULL))
  or ((o.ACTUAL_WEIGHT is not NULL)
  and (n.ACTUAL_WEIGHT is NULL)) THEN
    SET vField_Name = 'SHIPMENT ' || coalesce(cast(o.TC_SHIPMENT_ID as varchar
      (500)),' ') || ' ACTUAL WEIGHT';
    SET vOldValue = tmsutils.decimal_to_char(cast(o.ACTUAL_WEIGHT as decimal( 
      13,2)));
    SET vNewValue = tmsutils.decimal_to_char(cast(n.ACTUAL_WEIGHT as decimal( 
      13,2)));
    set (vEventSeq) = (
      SELECT tmsutils.ROUND(COALESCE(MAX(EVENT_SEQ), 0) + 1)
        FROM TPESHIP.INVOICE_EVENT
        WHERE INV_ID = o.INV_ID) ;
    INSERT INTO TPESHIP.INVOICE_EVENT ( INV_ID, EVENT_SEQ, FIELD_NAME, OLD_VALUE, 
      NEW_VALUE, CREATED_SOURCE_TYPE, CREATED_SOURCE, CREATED_DTTM, 
      INV_SHIPMENT_ID )
      VALUES (o.INV_ID, vEventSeq, vField_Name, vOldValue, vNewValue, 
        n.LAST_UPDATED_SOURCE_TYPE, n.LAST_UPDATED_SOURCE, current timestamp, 
        o.INV_SHIPMENT_ID ) ;
    SET VCHGFLAG = 1;
  END IF;
  
  IF (VCHGFLAG = 0) THEN
    IF (o.last_updated_dttm <> n.last_updated_dttm) THEN
      SET VFIELD_NAME = 'SHIPMENT'||char(o.tc_company_id)|| 
        'LAST UPDATED DATETIME';
      SET vOldValue = tmsutils.DATE_CHAR(o.last_updated_dttm, 
        'DD-MON-YYYY HH:MI:SS AM');
      SET vNewValue = tmsutils.DATE_CHAR(n.last_updated_dttm, 
        'DD-MON-YYYY HH:MI:SS AM');
      set (vEventSeq) = (
        SELECT tmsutils.ROUND(COALESCE(MAX(EVENT_SEQ), 0) + 1)
          FROM TPESHIP.INVOICE_EVENT
          WHERE INV_ID = o.INV_ID) ;
      INSERT INTO TPESHIP.INVOICE_EVENT ( INV_ID, EVENT_SEQ, FIELD_NAME, OLD_VALUE, 
        NEW_VALUE, CREATED_SOURCE_TYPE, CREATED_SOURCE, CREATED_DTTM )
        VALUES (o.INV_ID, vEventSeq, vField_Name, vOldValue, vNewValue, 
          n.LAST_UPDATED_SOURCE_TYPE, n.LAST_UPDATED_SOURCE, current timestamp
          );
    END IF;
  END IF;
  
  IF (o.NUM_PICKUPS != n.NUM_PICKUPS)
  or ((o.NUM_PICKUPS is NULL)
  and (n.NUM_PICKUPS is not NULL))
  or ((o.NUM_PICKUPS is not NULL)
  and (n.NUM_PICKUPS is NULL)) THEN
    SET vField_Name = 'SHIPMENT ' || coalesce(cast(o.TC_SHIPMENT_ID as varchar
      (500)),' ') || ' PICKUPS';
    SET vOldValue = tmsutils.decimal_to_char(cast(o.NUM_PICKUPS as decimal( 13
      ,2)));
    SET vNewValue = tmsutils.decimal_to_char(cast(n.NUM_PICKUPS as decimal( 13
      ,2)));
    set (vEventSeq) = (
      SELECT tmsutils.ROUND(COALESCE(MAX(EVENT_SEQ), 0) + 1)
        FROM TPESHIP.INVOICE_EVENT
        WHERE INV_ID = o.INV_ID) ;
    INSERT INTO TPESHIP.INVOICE_EVENT ( INV_ID, EVENT_SEQ, FIELD_NAME, OLD_VALUE, 
      NEW_VALUE, CREATED_SOURCE_TYPE, CREATED_SOURCE, CREATED_DTTM, 
      INV_SHIPMENT_ID )
      VALUES (o.INV_ID, vEventSeq, vField_Name, vOldValue, vNewValue, 
        n.LAST_UPDATED_SOURCE_TYPE, n.LAST_UPDATED_SOURCE, current timestamp, 
        o.INV_SHIPMENT_ID ) ;
    SET VCHGFLAG = 1;
  END IF;
  
  IF (o.NUM_DELIVERIES != n.NUM_DELIVERIES)
  or ((o.NUM_DELIVERIES is NULL)
  and (n.NUM_DELIVERIES is not NULL))
  or ((o.NUM_DELIVERIES is not NULL)
  and (n.NUM_DELIVERIES is NULL)) THEN
    SET vField_Name = 'SHIPMENT ' || coalesce(cast(o.TC_SHIPMENT_ID as varchar
      (500)),' ') || ' DELIVERIES';
    SET vOldValue = tmsutils.decimal_to_char(cast(o.NUM_DELIVERIES as decimal(
      13,2)));
    SET vNewValue = tmsutils.decimal_to_char(cast(n.NUM_DELIVERIES as decimal(
      13,2)));
    set (vEventSeq) = (
      SELECT tmsutils.ROUND(COALESCE(MAX(EVENT_SEQ), 0) + 1)
        FROM TPESHIP.INVOICE_EVENT
        WHERE INV_ID = o.INV_ID) ;

    INSERT INTO TPESHIP.INVOICE_EVENT(INV_ID, EVENT_SEQ, FIELD_NAME, OLD_VALUE, NEW_VALUE, CREATED_SOURCE_TYPE, CREATED_SOURCE, CREATED_DTTM, INV_SHIPMENT_ID)
    VALUES (o.INV_ID, vEventSeq, vField_Name, vOldValue, vNewValue, n.LAST_UPDATED_SOURCE_TYPE, n.LAST_UPDATED_SOURCE, current timestamp, o.INV_SHIPMENT_ID);
    SET VCHGFLAG = 1;
  END IF;
END
GO

CREATE TRIGGER TPESHIP.INVOICE_A_U_TR_1
  AFTER UPDATE
  ON "TPESHIP"."INVOICE"
  REFERENCING 
              OLD AS "OLD"
              NEW AS "NEW"
  FOR EACH ROW
BEGIN ATOMIC 

  DECLARE vOldValue varchar(500); 
  DECLARE vNewValue varchar(500); 
  DECLARE VEVENTSEQ SMALLINT; 
  DECLARE vChgFlag smallint; 
  DECLARE time_now timestamp; 
  DECLARE paid_amt decimal(13,2); 
  DECLARE billed_amt decimal(13,2); 
  
  SET time_now = current timestamp; 
  SET vChgFlag = 0; 
  
  IF (old.INVOICE_STATUS != new.INVOICE_STATUS) or ((old.INVOICE_STATUS is NULL) 
  	 and (new.INVOICE_STATUS is not NULL)) or ((old.INVOICE_STATUS is not NULL) 
	 and (new.INVOICE_STATUS is NULL)) 
	 THEN 
	 	  IF (old.INVOICE_STATUS IS NULL) THEN 
		  	 SET vOldValue = NULL; 
		  ELSE 
		  	 SET vOldValue = (SELECT DESCRIPTION 
			 	 		   	  FROM TPESHIP.INVOICE_STATUS 
							  WHERE INVOICE_STATUS = old.INVOICE_STATUS); 
		  END IF; 
		  
		  IF (new.INVOICE_STATUS IS NULL) THEN 
		  	 SET vNewValue = NULL; 
    	  ELSE 
		  	 SET vNewValue = (SELECT DESCRIPTION 
			 	 		   	  FROM	 TPESHIP.INVOICE_STATUS 
							  WHERE  INVOICE_STATUS = new.INVOICE_STATUS); 
		  END IF;
		   
  		  SET VEVENTSEQ = (SELECT tmsutils.ROUND(COALESCE(MAX(EVENT_SEQ), 0) + 1) 
		  	  			   FROM	  TPESHIP.INVOICE_EVENT 
						   WHERE  INV_ID = old.INV_ID); 
						   
		  INSERT INTO TPESHIP.INVOICE_EVENT (INV_ID, EVENT_SEQ, FIELD_NAME, OLD_VALUE, 
		  		 	  						 NEW_VALUE, CREATED_SOURCE_TYPE, CREATED_SOURCE, 
											 CREATED_DTTM) 
		  VALUES (old.INV_ID, VEVENTSEQ, 'STATUS', VOLDVALUE, VNEWVALUE, new.LAST_UPDATED_SOURCE_TYPE, 
		  		  new.LAST_UPDATED_SOURCE, CURRENT TIMESTAMP ); 
		  
		  SET vChgFlag = 1; 
	 END IF; 
	 
	 IF (coalesce(old.PAYMENT_DUE_DT, time_now) != coalesce(new.PAYMENT_DUE_DT, time_now)) THEN 
	 	SET vOldValue = tmsutils.date_char(old.PAYMENT_DUE_DT, 'MM/DD/YY'); 
		SET vNewValue = tmsutils.date_char(new.PAYMENT_DUE_DT, 'MM/DD/YY'); 
		SET VEVENTSEQ = (SELECT tmsutils.ROUND(COALESCE(MAX(EVENT_SEQ), 0) + 1) 
					  	 FROM 	TPESHIP.INVOICE_EVENT 
						 WHERE 	INV_ID = old.INV_ID); 
		
		INSERT INTO TPESHIP.INVOICE_EVENT (INV_ID,EVENT_SEQ,FIELD_NAME,OLD_VALUE, NEW_VALUE, 
			   							   CREATED_SOURCE_TYPE, CREATED_SOURCE, CREATED_DTTM) 
		VALUES (old.INV_ID, VEVENTSEQ, 'PAYMENT DUE DATE', vOldValue, vNewValue, new.LAST_UPDATED_SOURCE_TYPE, 
			   	new.LAST_UPDATED_SOURCE, CURRENT TIMESTAMP); 
		
		SET vChgFlag = 1; 
	 END IF; 
	 
	 IF (old.NET_AMOUNT_DUE != new.NET_AMOUNT_DUE) or ((old.NET_AMOUNT_DUE is NULL) 
	 	and (new.NET_AMOUNT_DUE is not NULL)) or ((old.NET_AMOUNT_DUE is not NULL) 
		and (new.NET_AMOUNT_DUE is NULL)) THEN 
		
		SET vOldValue = tmsutils.decimal_to_char(cast(old.NET_AMOUNT_DUE as decimal(13,2))); 
		SET vNewValue = tmsutils.decimal_to_char(cast(new.NET_AMOUNT_DUE as decimal(13,2))); 
		SET VEVENTSEQ = (SELECT tmsutils.ROUND(COALESCE(MAX(EVENT_SEQ), 0) + 1) 
					  	 FROM 	TPESHIP.INVOICE_EVENT 
						 WHERE 	INV_ID = old.INV_ID); 
  
  		INSERT INTO TPESHIP.INVOICE_EVENT (INV_ID,EVENT_SEQ,FIELD_NAME,OLD_VALUE, NEW_VALUE ,CREATED_SOURCE_TYPE,
			   							   CREATED_SOURCE,CREATED_DTTM) 
		VALUES (old.INV_ID, VEVENTSEQ, 'NET AMOUNT DUE', vOldValue, vNewValue, new.LAST_UPDATED_SOURCE_TYPE, 
			    new.LAST_UPDATED_SOURCE, CURRENT TIMESTAMP); 
		SET vChgFlag = 1; 
	 END IF; 
	 
	 IF (old.ACTUAL_PAYMENT_AMOUNT != new.ACTUAL_PAYMENT_AMOUNT) or ((old.ACTUAL_PAYMENT_AMOUNT is NULL) 
	 	and (new.ACTUAL_PAYMENT_AMOUNT is not NULL)) or ((old.ACTUAL_PAYMENT_AMOUNT is not NULL) 
		and (new.ACTUAL_PAYMENT_AMOUNT is NULL)) THEN 
			
			SET vOldValue = tmsutils.decimal_to_char(cast(old.ACTUAL_PAYMENT_AMOUNT as decimal(13,2))); 
			SET vNewValue = tmsutils.decimal_to_char(cast(new.ACTUAL_PAYMENT_AMOUNT as decimal(13,2))); 
			SET VEVENTSEQ = (SELECT tmsutils.ROUND(COALESCE(MAX(EVENT_SEQ), 0) + 1) 
						  	 FROM 	TPESHIP.INVOICE_EVENT WHERE INV_ID = old.INV_ID); 
  			
			INSERT INTO TPESHIP.INVOICE_EVENT(INV_ID, EVENT_SEQ, FIELD_NAME, OLD_VALUE, NEW_VALUE, CREATED_SOURCE_TYPE, 
				   							  CREATED_SOURCE, CREATED_DTTM) 
			VALUES (old.INV_ID, VEVENTSEQ, 'ACTUAL PAYMENT AMOUNT', vOldValue, vNewValue, new.LAST_UPDATED_SOURCE_TYPE, 
				    new.LAST_UPDATED_SOURCE, CURRENT TIMESTAMP); 
					
			SET vChgFlag = 1; 
	END IF; 
	
	IF (old.PAYMENT_TERMS != new.PAYMENT_TERMS) THEN 
	   IF (old.PAYMENT_TERMS IS NULL) THEN 
	   	  SET vOldValue = NULL; 
	   ELSE 
	   	  SET vOldValue = (SELECT DESCRIPTION 
		  	  			   FROM   TPESHIP.PAYMENT_TERMS 
						   WHERE  PAYMENT_TERMS = old.PAYMENT_TERMS); 
	   END IF; 
	   
	   IF (new.PAYMENT_TERMS IS NULL) THEN 
	       SET vNewValue = NULL; 
	   ELSE 
	   	   SET vNewValue = (SELECT DESCRIPTION 
		   	   			    FROM   TPESHIP.PAYMENT_TERMS 
  							WHERE  PAYMENT_TERMS = new.PAYMENT_TERMS); 
	  END IF; SET VEVENTSEQ = (SELECT 
  tmsutils.ROUND(COALESCE(MAX(EVENT_SEQ), 0) + 1) FROM TPESHIP.INVOICE_EVENT 
  WHERE INV_ID = old.INV_ID); INSERT INTO TPESHIP.INVOICE_EVENT (INV_ID, 
  EVENT_SEQ, FIELD_NAME, OLD_VALUE, NEW_VALUE, CREATED_SOURCE_TYPE, 
  CREATED_SOURCE, CREATED_DTTM) VALUES (old.INV_ID, VEVENTSEQ, 'PAYMENT TERMS'
  , VOLDVALUE, VNEWVALUE, new.LAST_UPDATED_SOURCE_TYPE, new.
  LAST_UPDATED_SOURCE, CURRENT TIMESTAMP); SET vChgFlag = 1; END IF; IF (old.
  IS_CANCELLED != new.IS_CANCELLED) THEN SET vOldValue = (SELECT char(tpeship.
  DECODE(char(old.IS_CANCELLED),'0','No','Yes')) FROM sysibm.sysdummy1); SET 
  vNewValue = (SELECT char(tpeship.DECODE(char(new.IS_CANCELLED),'0','No',
  'Yes')) FROM sysibm.sysdummy1); SET VEVENTSEQ = (SELECT tmsutils.ROUND(
  COALESCE(MAX(EVENT_SEQ), 0) + 1) FROM TPESHIP.INVOICE_EVENT WHERE INV_ID = 
  old.INV_ID); INSERT INTO TPESHIP.INVOICE_EVENT (INV_ID, EVENT_SEQ, 
  FIELD_NAME, OLD_VALUE, NEW_VALUE, CREATED_SOURCE_TYPE, CREATED_SOURCE, 
  CREATED_DTTM) VALUES (old.INV_ID, VEVENTSEQ, 'CANCEL FLAG', VOLDVALUE, 
  VNEWVALUE, new.LAST_UPDATED_SOURCE_TYPE, new.LAST_UPDATED_SOURCE, CURRENT 
  TIMESTAMP); SET vChgFlag = 1; END IF; IF (old.CARRIER_CODE != new.
  CARRIER_CODE) or ((old.CARRIER_CODE is NULL) and (new.CARRIER_CODE is not 
  NULL)) or ((old.CARRIER_CODE is not NULL) and (new.CARRIER_CODE is NULL)) 
  THEN SET vOldValue = old.CARRIER_CODE; SET vnewvalue = new.CARRIER_CODE; SET
  VEVENTSEQ = (SELECT tmsutils.ROUND(COALESCE(MAX(EVENT_SEQ), 0) + 1) FROM 
  TPESHIP.INVOICE_EVENT WHERE INV_ID = old.INV_ID); INSERT INTO TPESHIP.
  INVOICE_EVENT(INV_ID, EVENT_SEQ, FIELD_NAME, OLD_VALUE, NEW_VALUE, 
  CREATED_SOURCE_TYPE, CREATED_SOURCE, CREATED_DTTM) VALUES (old.INV_ID, 
  VEVENTSEQ, 'CARRIER CODE', VOLDVALUE, VNEWVALUE, new.
  LAST_UPDATED_SOURCE_TYPE, new.LAST_UPDATED_SOURCE, CURRENT TIMESTAMP); SET 
  vChgFlag = 1; END IF; IF (old.INVOICE_DT != new.INVOICE_DT) or ((old.
  INVOICE_DT is NULL) and (new.INVOICE_DT is not NULL)) or ((old.INVOICE_DT is
  not NULL) and (new.INVOICE_DT is NULL)) THEN SET vOldValue = tmsutils.
  date_char(old.INVOICE_DT,'MM/DD/YY'); SET vNewValue = tmsutils.date_char(new
  .INVOICE_DT,'MM/DD/YY'); SET VEVENTSEQ = ( SELECT tmsutils.ROUND(COALESCE(
  MAX(EVENT_SEQ), 0) + 1) FROM TPESHIP.INVOICE_EVENT WHERE INV_ID = old.INV_ID
  ); INSERT INTO TPESHIP.INVOICE_EVENT(INV_ID, EVENT_SEQ, FIELD_NAME, 
  OLD_VALUE, NEW_VALUE, CREATED_SOURCE_TYPE, CREATED_SOURCE, CREATED_DTTM) 
  VALUES (old.INV_ID,VEVENTSEQ, 'INVOICE DATE', vOldValue, vNewValue, new.
  LAST_UPDATED_SOURCE_TYPE, new.LAST_UPDATED_SOURCE, CURRENT TIMESTAMP); SET 
  vChgFlag = 1; END IF; IF (old.RECEIPT_DATE != new.RECEIPT_DATE) or ((old.
  RECEIPT_DATE is NULL) and (new.RECEIPT_DATE is not NULL)) or ((old.
  RECEIPT_DATE is not NULL) and (new.RECEIPT_DATE is NULL)) THEN SET vOldValue
  = tmsutils.date_char(old.RECEIPT_DATE,'MM/DD/YY'); SET vNewValue = tmsutils.
  date_char(new.RECEIPT_DATE,'MM/DD/YY'); SET VEVENTSEQ = (SELECT tmsutils.
  ROUND(COALESCE(MAX(EVENT_SEQ), 0) + 1) FROM TPESHIP.INVOICE_EVENT WHERE 
  INV_ID = old.INV_ID); INSERT INTO TPESHIP.INVOICE_EVENT (INV_ID,EVENT_SEQ,
  FIELD_NAME,OLD_VALUE, NEW_VALUE ,CREATED_SOURCE_TYPE,CREATED_SOURCE,
  CREATED_DTTM) VALUES (old.INV_ID,VEVENTSEQ,'INVOICE RECEIPT DATE',vOldValue,
  vNewValue, new.LAST_UPDATED_SOURCE_TYPE,new.LAST_UPDATED_SOURCE, CURRENT 
  TIMESTAMP); SET vChgFlag = 1; END IF; IF (old.INVOICE_RESP_CODE_ID != new.
  INVOICE_RESP_CODE_ID) or ((old.INVOICE_RESP_CODE_ID is NULL) and (new.
  INVOICE_RESP_CODE_ID is not NULL)) or ((old.INVOICE_RESP_CODE_ID is not NULL
  ) and (new.INVOICE_RESP_CODE_ID is NULL)) THEN IF old.INVOICE_RESP_CODE_ID 
  IS NULL THEN SET vOldValue = NULL; ELSE SET vOldValue = ( SELECT 
  DESCRIPTION_LONG FROM TPESHIP.INVOICE_RESP_CODE WHERE INVOICE_RESP_CODE_ID =
  old.INVOICE_RESP_CODE_ID ); END IF; IF new.INVOICE_RESP_CODE_ID IS NULL THEN
  SET vnewValue = NULL; ELSE SET vnewValue = ( SELECT DESCRIPTION_LONG FROM 
  TPESHIP.INVOICE_RESP_CODE WHERE INVOICE_RESP_CODE_ID = new.
  INVOICE_RESP_CODE_ID ); END IF; SET VEVENTSEQ = ( SELECT tmsutils.ROUND(
  COALESCE(MAX(EVENT_SEQ), 0) + 1) FROM TPESHIP.INVOICE_EVENT WHERE INV_ID = 
  old.INV_ID); INSERT INTO TPESHIP.INVOICE_EVENT (INV_ID,EVENT_SEQ,FIELD_NAME,
  OLD_VALUE, NEW_VALUE ,CREATED_SOURCE_TYPE,CREATED_SOURCE,CREATED_DTTM) 
  VALUES (old.INV_ID,VEVENTSEQ,'FAP ROLE', VOLDVALUE, VNEWVALUE, new.
  LAST_UPDATED_SOURCE_TYPE,new.LAST_UPDATED_SOURCE, CURRENT TIMESTAMP); SET 
  vChgFlag = 1; END IF; 
  
  IF (old.last_updated_dttm != new.last_updated_dttm) 
  THEN SET VEVENTSEQ = ( SELECT tmsutils.ROUND(COALESCE(MAX(EVENT_SEQ), 0) + 1
  ) FROM TPESHIP.INVOICE_EVENT WHERE INV_ID = old.INV_ID); 
  
  INSERT INTO TPESHIP.INVOICE_EVENT (INV_ID,EVENT_SEQ,FIELD_NAME,OLD_VALUE, NEW_VALUE,
  CREATED_SOURCE_TYPE,CREATED_SOURCE,CREATED_DTTM) VALUES (old.INV_ID,
  VEVENTSEQ,'LAST UPDATED DATETIME',substr(char( old.last_updated_dttm),1,19),
  substr(char(new.last_updated_dttm),1, 19 ),new.LAST_UPDATED_SOURCE_TYPE,new.
  LAST_UPDATED_SOURCE,CURRENT TIMESTAMP ); 
  
  END IF; 
  
  IF (new.Invoice_Status = 30) THEN 
  	 Insert into TPESHIP.OM_SCHED_EVENT(EVENT_ID, SCHEDULED_DTTM, EVENT_OBJECTS, EVENT_TIMESTAMP, 
	 			 						EVENT_TYPE, EVENT_CNT, EVENT_FREQ_IN_DAYS, EVENT_FREQ_PER_DAY, 
										EXECUTED_DTTM, IS_EXECUTED) 
     Values (nextval for TPESHIP.SEQ_EVENT_ID, TPESHIP.getDate(), '{invoiceId=' || RTRIM(TPESHIP.to_char(new.inv_id)) || 
	 		 ', eventProcessorClass=com.logistics.optifreight.invoice.InvoiceClaimCreation}', null, 0, 0, 0, 0, null, 0); 
  END IF; 
END
GO


CREATE TRIGGER TPESHIP.INV_SHP_L_ITEM_AU1
  AFTER UPDATE
  ON "TPESHIP"."INV_SHP_LINE_ITEM"
  REFERENCING 
              OLD AS "O"
              NEW AS "N"
  FOR EACH ROW
BEGIN ATOMIC DECLARE
vShipmentId VARCHAR(50) DEFAULT NULL; DECLARE VEVENTSEQ INTEGER; DECLARE
vfield_name VARCHAR(500) DEFAULT NULL; DECLARE vOldValue VARCHAR(500) DEFAULT
NULL; DECLARE vNewValue VARCHAR(500) DEFAULT NULL; SET (vShipmentId) =
( SELECT TC_SHIPMENT_ID FROM INVOICE_SHIPMENT WHERE INV_ID = o.INV_ID AND
INV_SHIPMENT_ID = o.INV_SHIPMENT_ID); IF (o.COMMODITY_CLASS <> n.COMMODITY_CLASS)
THEN IF (o.COMMODITY_CLASS IS NULL) THEN SET vOldValue = NULL; ELSE SET
(vOldValue) = ( SELECT DESCRIPTION FROM COMMODITY_CLASS WHERE COMMODITY_CLASS
= o.COMMODITY_CLASS); END IF; IF (n.COMMODITY_CLASS IS NULL) THEN SET vNewValue
= NULL; ELSE SET (vNewValue) = ( SELECT DESCRIPTION FROM COMMODITY_CLASS
WHERE COMMODITY_CLASS = n.COMMODITY_CLASS); END IF; SET VFIELD_NAME = 'SHIPMENT



'||vShipmentId||' COMMODITY CLASS'; set (vEventSeq) = ( SELECT tmsutils.ROUND(COALESCE(MAX(EVENT_SEQ), 0) + 1) FROM INVOICE_EVENT WHERE INV_ID = o.INV_ID) ; INSERT INTO INVOICE_EVENT ( INV_ID, EVENT_SEQ, FIELD_NAME, OLD_VALUE, NEW_VALUE, CREATED_SOURCE_TYPE, CREATED_SOURCE, CREATED_DTTM ) VALUES ( o.INV_ID, vEventSeq, vField_Name, vOldValue, vNewValue, 1, 'unknown', current timestamp ); END IF; END
GO


CREATE TRIGGER TPESHIP.INV_SHP_ACC_A_U_1
  AFTER UPDATE
  ON "TPESHIP"."INV_SHP_ACCESSORIAL"
  REFERENCING 
              OLD AS "O"
              NEW AS "N"
  FOR EACH ROW
BEGIN ATOMIC DECLARE
vShipmentId VARCHAR(50); DECLARE VEVENTSEQ INTEGER; DECLARE vfield_name
VARCHAR(500) DEFAULT NULL; DECLARE vOldValue VARCHAR(500) DEFAULT NULL;
DECLARE vNewValue VARCHAR(500) DEFAULT NULL; SET (vShipmentId) = ( SELECT
TC_SHIPMENT_ID FROM INVOICE_SHIPMENT WHERE INV_ID = o.INV_ID AND INV_SHIPMENT_ID
= o.INV_SHIPMENT_ID); IF (o.DESCRIPTION <> n.DESCRIPTION) THEN SET VFIELD_NAME
= 'SHIPMENT '||vShipmentId||' 
ACCESSORIAL DESCRIPTION'; SET VOLDVALUE = o.DESCRIPTION; SET VNEWVALUE = n.DESCRIPTION; set (vEventSeq) = ( SELECT tmsutils.ROUND(COALESCE(MAX(EVENT_SEQ), 0) + 1) FROM INVOICE_EVENT WHERE INV_ID = o.INV_ID) ; INSERT INTO INVOICE_EVENT ( INV_ID, EVENT_SEQ, FIELD_NAME, OLD_VALUE, NEW_VALUE, CREATED_SOURCE_TYPE, CREATED_SOURCE, CREATED_DTTM ) VALUES ( o.INV_ID, vEventSeq, vField_Name, vOldValue, vNewValue, 1, 'unknown', current timestamp ); END IF; IF (o.TOTAL_COST != n.TOTAL_COST) or ((o.TOTAL_COST is NULL) and (n.TOTAL_COST is not NULL)) or ((o.TOTAL_COST is not NULL) and (n.TOTAL_COST is NULL)) THEN SET VFIELD_NAME = 'SHIPMENT '||coalesce(cast(vShipmentId as varchar (500 )),' ') ||' ACCESSORIAL '|| o.DESCRIPTION || ' TOTAL COST '; SET VOLDVALUE = tmsutils.decimal_to_char(cast(o.TOTAL_COST as decimal(13 ,2))); SET VNEWVALUE = tmsutils.decimal_to_char(cast(n.TOTAL_COST as decimal(13 ,2))); set (vEventSeq) = ( SELECT tmsutils.ROUND(COALESCE(MAX(EVENT_SEQ), 0) + 1) FROM INVOICE_EVENT WHERE INV_ID = o.INV_ID) ; INSERT INTO INVOICE_EVENT ( INV_ID, EVENT_SEQ, FIELD_NAME, OLD_VALUE, NEW_VALUE, CREATED_SOURCE_TYPE, CREATED_SOURCE, CREATED_DTTM ) VALUES ( o.INV_ID, vEventSeq, vField_Name, vOldValue, vNewValue, 1, 'unknown', current timestamp ); END IF; END
GO


