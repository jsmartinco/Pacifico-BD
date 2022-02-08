
-- PRIMER REPORTE 
CREATE OR REPLACE PROCEDURE FIRSTREPORT IS 
v_town varchar2(20);
v_avglastyear NUMBER(10,2);
v_currentinvoice NUMBER(10,2);
v_currentmonth NUMBER;
v_montonelastyear number :=0;
v_monthtwelvelastyear NUMBER :=0;
v_count NUMBER := 0;
v_tnames varchar2(20);
v_currentkhw NUMBER(10,2);
v_newdifference NUMBER(10,2);
CURSOR c_town IS
	SELECT * FROM TOWN t
	JOIN CUSTOMER c ON (c.TOWNID = t.TOWNID)
	JOIN INVOICE i ON (i.CUSTOMERID = c.CUSTOMERID)
	JOIN TICKET t2 ON (t2.INVOICEID = i.INVOICEID)
	WHERE t2.FRAUD = 1;
BEGIN
	truncatereport;
	FOR v_townc IN c_town LOOP
		SELECT EXTRACT (MONTH FROM sysdate) INTO v_currentmonth FROM dual;
		v_montonelastyear := (v_currentmonth+12)*-1;
		v_monthtwelvelastyear := v_currentmonth*-1;
		SELECT count(i2.INVOICEID) INTO v_count  FROM INVOICE i2 
		JOIN CUSTOMER c2 ON (c2.CUSTOMERID = i2.customerid)
		JOIN town t3 ON (t3.TOWNID = c2.TOWNID)
		WHERE t3.TNAME = v_townc.tname AND i2.cutoffdate BETWEEN add_months(SYSDATE,v_montonelastyear) AND add_months(SYSDATE,v_monthtwelvelastyear);
		IF (v_count>0) THEN 
			DBMS_OUTPUT.PUT_LINE(v_townc.tname);
			SELECT t2.TNAME, AVG(i.KWH) INTO v_town, v_avglastyear FROM TICKET t 
			right JOIN INVOICE i ON (t.INVOICEID = i.INVOICEID)
			JOIN CUSTOMER c ON (i.CUSTOMERID = c.CUSTOMERID)
			JOIN TOWN t2 ON (c.TOWNID = t2.TOWNID)
			WHERE t2.TNAME = v_townc.tname AND i.cutoffdate BETWEEN add_months(SYSDATE,v_montonelastyear) AND add_months(SYSDATE,v_monthtwelvelastyear)
			GROUP BY t2.TNAME;
			DBMS_OUTPUT.PUT_LINE(v_town || ' - ' ||v_avglastyear);
			SELECT AVG(i5.KWH), tw.tname INTO v_currentkhw, v_tnames FROM TICKET t5 
			right JOIN INVOICE i5 ON (t5.INVOICEID = i5.INVOICEID)
			JOIN CUSTOMER c5 ON (i5.CUSTOMERID = c5.CUSTOMERID)
			JOIN TOWN tW ON (c5.TOWNID = tW.TOWNID)
			WHERE tw.tname = v_townc.tname AND i5.CUTOFFDATE BETWEEN add_months(SYSDATE,-1) AND add_months(SYSDATE,0)
			GROUP BY tw.tname;
			v_newdifference := v_avglastyear - v_currentkhw;
			INSERT INTO REPORT (TOWN,AVGLASTYEAR,LASTINVOICE,DIFFERENCE) VALUES (v_townc.tname,v_avglastyear,v_currentkhw,v_newdifference);
		END IF;
	END loop;
END;

BEGIN
	FIRSTREPORT;
END;


CREATE OR REPLACE PROCEDURE truncatereport IS 
BEGIN 
	EXECUTE IMMEDIATE 'TRUNCATE TABLE REPORT';
EXCEPTION
	WHEN OTHERS THEN NULL;
END;


--SEGUNDO REPORTES¿ 	
CREATE OR REPLACE PROCEDURE SECONDREPORT IS 
v_town varchar2(20);
v_avglastyear NUMBER(10,2);
v_currentinvoice NUMBER(10,2);
v_currentmonth NUMBER;
v_montonelastyear number :=0;
v_monthtwelvelastyear NUMBER :=0;
v_count NUMBER := 0;
v_count2 NUMBER := 0;
v_count3 NUMBER := 0;
v_avgstolen NUMBER (10,2) := 0;
v_ilegalcon number(10,2) := 0;
v_altered NUMBER(10,2) :=0;
v_total number(10,2);
CURSOR c_town IS
	SELECT * FROM TOWN tw
	JOIN CUSTOMER c ON (c.TOWNID = tw.TOWNID)
	JOIN INVOICE i ON (i.CUSTOMERID = c.CUSTOMERID)
	JOIN TICKET t ON (t.INVOICEID = i.INVOICEID)
	WHERE t.FRAUD = 1;
BEGIN
	truncatereport2;
	FOR v_townc IN c_town LOOP
		SELECT EXTRACT (MONTH FROM sysdate) INTO v_currentmonth FROM dual;
		SELECT count(i2.INVOICEID) INTO v_count  FROM INVOICE i2
		JOIN TICKET t2 ON (t2.INVOICEID = i2.invoiceid)
		JOIN CUSTOMER c2 ON (c2.CUSTOMERID = i2.customerid)
		JOIN town tw2 ON (tw2.TOWNID = c2.TOWNID)
		WHERE tw2.TNAME = v_townc.tname AND t2.conditions = 'Robo a tercero';
		SELECT count(i3.INVOICEID) INTO v_count2  FROM INVOICE i3 
		JOIN TICKET t3 ON (t3.INVOICEID = i3.invoiceid)
		JOIN CUSTOMER c3 ON (c3.CUSTOMERID = i3.customerid)
		JOIN town tw3 ON (tw3.TOWNID = c3.TOWNID)
		WHERE tw3.TNAME = v_townc.tname AND t3.conditions = 'Conexión ilegal';
		SELECT count(i4.INVOICEID) INTO v_count3  FROM INVOICE i4 
		JOIN TICKET t4 ON (t4.INVOICEID = i4.invoiceid)
		JOIN CUSTOMER c4 ON (c4.CUSTOMERID = i4.customerid)
		JOIN town tw4 ON (tw4.TOWNID = c4.TOWNID)
		WHERE tw4.TNAME = v_townc.tname AND t4.conditions = 'Contador alterado';
		v_avgstolen := 0;
		v_ilegalcon := 0;
		v_altered :=0;
		IF (v_count>0) THEN
			SELECT t2.TNAME, AVG(t.DIFFERENCE) INTO v_town, v_avgstolen FROM TICKET t 
			JOIN INVOICE i on (t.INVOICEID = i.INVOICEID)
			JOIN CUSTOMER c ON (i.CUSTOMERID = c.CUSTOMERID)
			JOIN TOWN t2 ON (c.TOWNID = t2.TOWNID)
			WHERE t2.TNAME = v_townc.tname AND t.CONDITIONS = 'Robo a tercero'
			GROUP BY t2.TNAME;
		ELSIF (v_count2>0) THEN
			SELECT t2.TNAME, AVG(t.DIFFERENCE) INTO v_town, v_ilegalcon FROM TICKET t 
			JOIN INVOICE i on (t.INVOICEID = i.INVOICEID)
			JOIN CUSTOMER c ON (i.CUSTOMERID = c.CUSTOMERID)
			JOIN TOWN t2 ON (c.TOWNID = t2.TOWNID)
			WHERE t2.TNAME = v_townc.tname AND t.CONDITIONS = 'Conexión ilegal'
			GROUP BY t2.TNAME;
		ELSIF (v_count3>0) THEN
			SELECT t2.TNAME, AVG(t.DIFFERENCE) INTO v_town, v_altered FROM TICKET t 
			JOIN INVOICE i on (t.INVOICEID = i.INVOICEID)
			JOIN CUSTOMER c ON (i.CUSTOMERID = c.CUSTOMERID)
			JOIN TOWN t2 ON (c.TOWNID = t2.TOWNID)
			WHERE t2.TNAME = v_townc.tname AND t.CONDITIONS = 'Contador alterado'
			GROUP BY t2.TNAME;
		END IF;
	v_total := (v_avgstolen + v_ilegalcon + v_altered);
	DBMS_OUTPUT.PUT_LINE(v_avgstolen ||' - '|| v_ilegalcon || ' - '|| v_altered);
	INSERT INTO PACIFICO.REPORT2 (TOWN,STOLEN,ILEGALCON,ALTERATION,TOTAL) VALUES (v_townc.tname,v_avgstolen,v_ilegalcon,v_altered,v_total);
	END loop;
END;

BEGIN
	secondreport;
END;
		
		
CREATE OR REPLACE PROCEDURE truncatereport2 IS 
BEGIN 
	EXECUTE IMMEDIATE 'TRUNCATE TABLE REPORT2';
EXCEPTION
	WHEN OTHERS THEN NULL;
END;	

