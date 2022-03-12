CREATE PROCEDURE FP14.INS_SHPTOACCR_RECS(COMPANYID INTEGER)
SPECIFIC FP14.INS_SHPTOACCR_RECS
BEGIN

    DECLARE stmt VARCHAR(1000);

	DECLARE GLOBAL TEMPORARY TABLE SHIP (
		TC_COMPANY_ID       INTEGER,
		SHIPMENT_ID         BIGINT,
		TC_SHIPMENT_ID      VARCHAR(50),
		LAST_UPDATED_DTTM   TIMESTAMP,
		SHIPMENT_COST       DECIMAL(13, 2),
		ACCESSORIAL_COST    DECIMAL(13, 2),
		IS_INVOICED         SMALLINT DEFAULT 0
	) NOT LOGGED ON COMMIT PRESERVE ROWS;

	DECLARE GLOBAL TEMPORARY TABLE PO (
		SHIPMENT_ID         BIGINT,
		PO_ORDER_ID         BIGINT,
		EXT_SYS_ORDER_ID    VARCHAR(100),
		SHIPMENT_TYPE       VARCHAR(100)
	) NOT LOGGED ON COMMIT PRESERVE ROWS;


    SET stmt = 'ALTER TABLE fp14.shipment_to_accrue ACTIVATE NOT LOGGED INITIALLY WITH EMPTY TABLE';
	EXECUTE IMMEDIATE stmt;
    COMMIT;

	CALL SYSPROC.ADMIN_CMD('REORG TABLE fp14.shipment_to_accrue USE TMS04K001');
	COMMIT;

	-- Create the original shipment list
	SET stmt = 'INSERT INTO SESSION.SHIP(TC_COMPANY_ID, SHIPMENT_ID, TC_SHIPMENT_ID, LAST_UPDATED_DTTM, SHIPMENT_COST) ' ||
	'SELECT  s.tc_company_id, s.shipment_id, s.tc_shipment_id, s.last_updated_dttm, ' ||
	'		(COALESCE(s.linehaul_cost, 0) + COALESCE(s.stop_cost, 0)) ' ||
	'FROM    tpeship.shipment s ' ||
	'WHERE   s.is_cancelled = 0 ' ||
    'AND     s.trans_resp_code = ''SHP'' ' ||
    'AND     s.billing_method = 1 ' ||
	'AND     s.shipment_status IN (80, 90) ';

    EXECUTE IMMEDIATE stmt;


	-- Update the accessorial costs
	SET stmt = 'UPDATE SESSION.SHIP s SET ACCESSORIAL_COST = (SELECT  SUM(sa.accessorial_cost) ' ||
	'											  FROM    tpeship.shipment_accessorial sa ' ||
	'											  WHERE   sa.tc_company_id = s.tc_company_id ' ||
	'											  AND     sa.shipment_id = s.shipment_id ' ||
	'											  AND     sa.is_approved = 1 ' ||
	'											  AND     sa.resource_type = ''A'') ';

    EXECUTE IMMEDIATE stmt;

	-- Update shipments that have been invoiced
	-- Note: this is any form of invoice.  We will need to distinguish later
	SET stmt = 'UPDATE session.ship s SET IS_INVOICED = 1 ' ||
	'WHERE EXISTS   (SELECT 1  ' ||
	'						FROM  tpeship.invoice_shipment is ' ||
	'						WHERE  is.tc_company_id = s.tc_company_id ' ||
	'						AND   is.tc_shipment_id = s.tc_shipment_id) ';

    EXECUTE IMMEDIATE stmt;

	-----------------------------------------------------------------------------------------------------
	-- Now, handle all SHIPMENT related issues
	-----------------------------------------------------------------------------------------------------
	-- Invoice Status is not in 10 - Not Approved, 15 - Hold, 70 - Rejected, so we don't accrue
	SET stmt = 'DELETE FROM session.ship s ' ||
	'WHERE EXISTS   (SELECT 1 ' ||
	'						FROM        tpeship.invoice_shipment is ' ||
	'							INNER JOIN tpeship.invoice i  ' ||
	'						ON (is.tc_company_id = i.tc_company_id AND is.inv_id = i.inv_id) ' ||
	'						WHERE   i.tc_company_id = s.tc_company_id ' ||
	'						AND         is.tc_shipment_id = s.tc_shipment_id ' ||
	'				AND        i.invoice_status NOT IN (10, 15, 70)) ';

    EXECUTE IMMEDIATE stmt;

	-- I believe this checks if there is another shipment associated with the PO
	-- and it has already been invoiced
	SET stmt = 'DELETE FROM session.ship s ' ||
	'WHERE EXISTS   (SELECT 1 ' ||
	'				FROM   tpeship.shipment s2  ' ||
	'					INNER JOIN tpeship.orders o2  ' ||
	'						ON (s2.tc_company_id = o2.tc_company_id AND o2.shipment_id = s2.shipment_id)  ' ||
	'				WHERE   s2.is_cancelled = 0  ' ||
	'				AND     s2.shipment_status IN (80, 90) ' ||
					-- Has an invoice
	'				AND    NOT EXISTS (SELECT   1  ' ||
	'								   FROM     tpeship.invoice_shipment is ' ||
	'								   WHERE    is.tc_company_id = s.tc_company_id ' ||
	'								   AND          is.tc_shipment_id = s.tc_shipment_id)) ' ||
	'AND is_invoiced = 1 ';

    EXECUTE IMMEDIATE stmt;

	-- Delete accrual records with no cost
	SET stmt = 'DELETE FROM session.ship WHERE COALESCE(shipment_cost, 0) = 0 AND COALESCE(accessorial_cost, 0) = 0 ';

    EXECUTE IMMEDIATE stmt;

	-----------------------------------------------------------------------------------------------------
	-- Now, handle all PO related issues
	-----------------------------------------------------------------------------------------------------
	-- No TO or No PO
	SET stmt = 'DELETE FROM session.ship s  ' ||
	'WHERE NOT EXISTS (SELECT 1 ' ||
	'				  FROM (SELECT DISTINCT shipment_id, order_id ' ||
	'									FROM tpeship.stop_action_order) to ' ||
	'					  INNER JOIN tpeship.order_master_order omo  ' ||
	'						ON (s.tc_company_id = omo.tc_company_id AND to.order_id = omo.order_id)  ' ||
	'					INNER JOIN tpeship.orders po  ' ||
	'						ON (omo.tc_company_id = po.tc_company_id AND omo.master_order_id = po.order_id) ' ||
	'				  WHERE   s.shipment_id = to.shipment_id) ' ||
	'AND is_invoiced = 0 ';

    EXECUTE IMMEDIATE stmt;

	-- Making sure the dependencies between all of the tables exist
	SET stmt = 'DELETE FROM session.ship s ' ||
	'WHERE NOT EXISTS (SELECT 1 ' ||
	'				  FROM  tpeship.invoice_shipment is  ' ||
	'					  INNER JOIN tpeship.invoice i  ' ||
	'						ON (is.tc_company_id = i.tc_company_id AND is.inv_id = i.inv_id) ' ||
	'					  INNER JOIN (SELECT DISTINCT shipment_id, order_id ' ||
	'												 FROM       tpeship.stop_action_order) to ' ||
	'								  ON (s.shipment_id = to.shipment_id) ' ||
	'					  INNER JOIN tpeship.order_master_order omo  ' ||
	'						ON (s.tc_company_id = omo.tc_company_id AND to.order_id = omo.order_id) ' ||
	'					INNER JOIN tpeship.orders po  ' ||
	'						ON (omo.tc_company_id = po.tc_company_id AND omo.master_order_id = po.order_id) ' ||
	'				  WHERE is.mark_for_deletion = 0 ' ||
	'				  AND   is.tc_company_id = s.tc_company_id ' ||
	'				  AND   is.tc_shipment_id = s.tc_shipment_id) ' ||
	'AND is_invoiced = 1 ';

    EXECUTE IMMEDIATE stmt;

	-- Insert the POs for the shipments on the list
	SET stmt = 'INSERT INTO session.po (shipment_id, po_order_id, ext_sys_order_id, shipment_type) ' ||
	'SELECT  s.shipment_id, sp.po_order_id, po.ext_sys_order_id, COALESCE(TPESHIP.GET_SHIPMENT_TYPE(sp.po_order_id), '''') ' ||
	'FROM    session.ship s  ' ||
	'	INNER JOIN tpeship.SHIPMENT_TO_PORDER sp ' ||
	'		ON (s.shipment_id = sp.shipment_id) ' ||
	'	INNER JOIN tpeship.orders po ' ||
	'		ON (sp.po_order_id = po.order_id) ';

    EXECUTE IMMEDIATE stmt;

	-- This PO is missing an external system id or shipment_type
	SET stmt = 'DELETE FROM session.ship s ' ||
	'WHERE EXISTS   (SELECT 1 ' ||
	'				FROM    session.po po ' ||
	'				WHERE   po.shipment_id = s.shipment_id ' ||
	'				AND    (COALESCE(po.ext_sys_order_id, '''') = '''' ' ||
	'					OR  COALESCE(TPESHIP.GET_SHIPMENT_TYPE(po.po_order_id), '''') = '''')) ';

    EXECUTE IMMEDIATE stmt;

	-- Missing GL Code in the THD GL Code table
	SET stmt = 'DELETE FROM session.ship s ' ||
	'WHERE   EXISTS (SELECT  1 ' ||
	'				FROM    session.po po ' ||
	'					LEFT OUTER JOIN tpeship.shipment_accessorial sa ' ||
	'						ON (po.shipment_id = sa.shipment_id AND sa.is_approved = 1 AND sa.resource_type = ''A'') ' ||
	'				WHERE   po.shipment_id = s.shipment_id ' ||
	'				AND     ((COALESCE(TPESHIP.GET_GL_CODE (po.po_order_id, ''A'', po.shipment_type, ''FRT''), '''') = '''')  ' ||
	'					OR (COALESCE(sa.accessorial_code, '''') <> ''''  ' ||
	'						AND COALESCE(TPESHIP.GET_GL_CODE (po.po_order_id, ''A'', po.shipment_type, sa.accessorial_code), '''') = ''''))) ';

    EXECUTE IMMEDIATE stmt;

	-- Missing Allocation Location ID on PO
	SET stmt = 'DELETE FROM session.ship s  ' ||
	'WHERE EXISTS (SELECT  1 ' ||
	'			  FROM    session.po po ' ||
	'			  WHERE   po.shipment_id = s.shipment_id ' ||
	'			  AND     LENGTH(RTRIM(TPESHIP.GET_ALLOC_LOC(po.po_order_id))) = 0) ';


    EXECUTE IMMEDIATE stmt;

	SET stmt = 'INSERT INTO fp14.shipment_to_accrue (shipment_id, last_updt_dttm) ' ||
	'(SELECT shipment_id, MAX(last_updated_dttm) ' ||
	'FROM SESSION.SHIP ' ||
    'WHERE  tc_company_id = ' || char(COMPANYID) || ' ' ||
    'GROUP BY tc_company_id, shipment_id)';

    EXECUTE IMMEDIATE stmt;

	DROP TABLE SESSION.SHIP;
	DROP TABLE SESSION.PO;

	CALL SYSPROC.ADMIN_CMD('RUNSTATS ON TABLE FP14.shipment_to_accrue WITH DISTRIBUTION ON ALL COLUMNS AND INDEXES ALL');
	COMMIT;
END
GO
