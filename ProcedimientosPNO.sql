-- Paquete donde se encuentran los 4 conceptos.

CREATE OR REPLACE PACKAGE conceptospnoresidencial IS 
	PROCEDURE primerconcepto;
	PROCEDURE segundoconcepto(customer1 CUSTOMER.customerid%type);
	PROCEDURE tercerconcepto(customer2 CUSTOMER.customerid%type);
	PROCEDURE cuartoconcepto(customer3 CUSTOMER.customerid%type); 
END conceptospnoresidencial;

CREATE OR REPLACE PACKAGE BODY conceptospnoresidencial IS 	
PROCEDURE primerconcepto IS 
CURSOR c_cus IS 
		SELECT customerid FROM customer c WHERE PRIORITY = 'Residencial';
	CURSOR c_invo (cust invoice.customerid%TYPE) IS
		SELECT * FROM INVOICE i WHERE CUSTOMERID = cust;
	currentmonth NUMBER;
	currentkwh NUMBER;
	nombre customer.name%TYPE;
	sumakwh NUMBER := 0;
	promedio NUMBER(8,2);
	diezporciento NUMBER :=0;
	pno NUMBER;
	currentinvoiceid number := 0;
	difference NUMBER := 0;
	topen NUMBER := 0;
	counttickets NUMBER := 0;
BEGIN
	SELECT EXTRACT (MONTH FROM sysdate) INTO currentmonth FROM dual;
	FOR v_cust IN c_cus LOOP
		SELECT name INTO nombre FROM CUSTOMER c 
		WHERE customerid = v_cust.customerid;
		DBMS_OUTPUT.PUT_LINE('NOMBRE: '|| nombre||' - ' ||v_cust.customerid);
		SELECT COUNT(t.TICKETID) INTO topen FROM TICKET t 
		JOIN INVOICE i ON (t.INVOICEID = i.INVOICEID)
		WHERE STATE = 'Abierto' AND i.CUSTOMERID =	v_cust.customerid;
		SELECT COUNT(i2.invoiceid) INTO counttickets FROM INVOICE i2 
		WHERE i2.CUSTOMERID = v_cust.customerid;
		IF topen = 0 AND counttickets >= 1 THEN 
			FOR v_invo IN c_invo(v_cust.customerid) LOOP
			  SELECT avg(kwh) INTO promedio FROM INVOICE i WHERE customerid = v_invo.customerid AND i.cutoffdate BETWEEN add_months(SYSDATE,-7) AND add_months(SYSDATE,-1);
				IF v_invo.cutoffdate BETWEEN add_months(SYSDATE,-1) AND add_months(SYSDATE,0) THEN 		
				currentkwh := v_invo.kwh;
				currentinvoiceid := v_invo.invoiceid;
				END IF;		
			END LOOP;
			diezporciento := promedio * 0.1;
			pno := promedio - diezporciento;
			difference := currentkwh-promedio;
			IF promedio = 0 THEN
				DBMS_OUTPUT.PUT_LINE('No se encontraron registros de los 6 meses anteriores');
			ELSE IF currentkwh < pno THEN			
				DBMS_OUTPUT.PUT_LINE('1.PNO');
				INSERT INTO TICKET (CREATEDATE,FRAUD,OBSERVATIONS,CONDITIONS,STATE,INVOICEID,EMPLOYEEID,DIFFERENCE)
				VALUES (sysdate,0,' ',' ','Abierto',currentinvoiceid,121,difference);
				DBMS_OUTPUT.PUT_LINE('suma '|| sumakwh || ' - '|| currentkwh || ' - '||promedio||' - '||diezporciento||' - '||pno||' - '||currentinvoiceid);
				ELSE
					DBMS_OUTPUT.PUT_LINE('suma '|| sumakwh || ' - '|| currentkwh || ' - '||promedio||' - '||diezporciento||' - '||pno||' - '||currentinvoiceid);
					DBMS_OUTPUT.PUT_LINE('1. NO PNO '||v_cust.customerid);
					BEGIN
						conceptospnoresidencial.segundoconcepto(v_cust.customerid);
					END;
				END IF;
			END IF;
		END IF;
	END LOOP;
	--Para pruebas
		--DBMS_OUTPUT.PUT_LINE('suma '|| sumakwh || ' - '|| currentkwh || ' - '||promedio||' - '||diezporciento||' - '||pno||' - '||difference);
END primerconcepto;
--SEGUNDO CONCEPTO
PROCEDURE segundoconcepto(customer1 CUSTOMER.customerid%type) is
CURSOR c_cus IS 
		SELECT c.CUSTOMERID FROM customer c WHERE c.CUSTOMERID = customer1;
	CURSOR c_invo (cust invoice.customerid%TYPE) IS
		SELECT * FROM INVOICE i WHERE CUSTOMERID = cust;
	currentmonth NUMBER;
	currentkwh NUMBER;
	nombre customer.name%TYPE;
	sumakwh NUMBER := 0;
	diezporciento NUMBER;
	pno NUMBER;
	currentinvoiceid number := 0;
	difference NUMBER := 0;
BEGIN
	SELECT EXTRACT (MONTH FROM sysdate) INTO currentmonth FROM dual;
	FOR v_cust IN c_cus LOOP
		SELECT name INTO nombre FROM CUSTOMER c 
		WHERE customerid = v_cust.customerid;
		DBMS_OUTPUT.PUT_LINE('NOMBRE2: '|| nombre);
		DBMS_OUTPUT.PUT_LINE(v_cust.customerid);
		FOR v_invo IN c_invo(v_cust.customerid) LOOP
			IF v_invo.cutoffdate BETWEEN add_months(SYSDATE,-13) AND add_months(SYSDATE,-12) THEN 
				sumakwh := sumakwh + v_invo.kwh;
			END IF;
			IF v_invo.cutoffdate BETWEEN add_months(SYSDATE,-1) AND add_months(SYSDATE,0) THEN 		
			currentkwh := v_invo.kwh;
			currentinvoiceid := v_invo.invoiceid;
			END IF;		
		END LOOP;
		diezporciento := currentkwh * 0.1;
		pno := currentkwh - diezporciento;
		difference := sumakwh-currentkwh;
		IF sumakwh = 0 THEN
			DBMS_OUTPUT.PUT_LINE('no hay registros del año pasado.');
			DBMS_OUTPUT.PUT_LINE('2. NO PNO ');
				BEGIN
					conceptospnoresidencial.tercerconcepto(v_cust.customerid);
				END;
		ELSE IF sumakwh < pno THEN
			DBMS_OUTPUT.PUT_LINE('2.PNO ');
			INSERT INTO TICKET (CREATEDATE,FRAUD,OBSERVATIONS,CONDITIONS,STATE,INVOICEID,EMPLOYEEID,DIFFERENCE)
			VALUES (sysdate,0,' ',' ','Abierto',currentinvoiceid,1,difference);
			ELSE
				DBMS_OUTPUT.PUT_LINE('2. NO PNO ');
				BEGIN
					conceptospnoresidencial.tercerconcepto(v_cust.customerid);
				END;								
			END IF;
		END IF;
	END LOOP;
	-- Para pruebas
		--DBMS_OUTPUT.PUT_LINE('suma '|| sumakwh || ' - '|| currentkwh || ' - '||diezporciento||' - '||pno||' - '||difference);
END segundoconcepto;
--TERCER CONCEPTO V2 (UTILIZAR ESTE)
PROCEDURE tercerconcepto(customer2 CUSTOMER.customerid%type) IS 
CURSOR c_cus IS 
		SELECT customerid FROM customer c WHERE CUSTOMERID = customer2;
	CURSOR c_invo (cust invoice.customerid%TYPE) IS
		SELECT * FROM INVOICE i WHERE CUSTOMERID = cust;
	currentmonth NUMBER;
	currentkwh NUMBER;
	nombre customer.name%TYPE;
	sumkwhlastyear NUMBER := 0;
	sumkwhlastsixmonth NUMBER := 0;
	pno NUMBER;
	currentinvoiceid number := 0;
	difference NUMBER(10,2) := 0;
	montonelastyear number :=0;
	monthtwelvelastyear NUMBER :=0;
	mesunoanoanterior NUMBER :=0;
	mesdoceanoanterior NUMBER :=0;
	averagelastsixmonth NUMBER(10,2) :=0;
	averagelastyear NUMBER(10,2) :=0;
	tenpercent NUMBER(10,2) := 0;
	countyear NUMBER :=0;
	countmonth NUMBER :=0;	
BEGIn
	SELECT EXTRACT (MONTH FROM sysdate) INTO currentmonth FROM dual;
	FOR v_cust IN c_cus LOOP
		SELECT name INTO nombre FROM CUSTOMER c 
		WHERE customerid = v_cust.customerid;
		DBMS_OUTPUT.PUT_LINE('NOMBRE3: '|| nombre);
		mesunoanoanterior := (currentmonth+12)*-1;
		mesdoceanoanterior := currentmonth*-1;
		FOR v_invo IN c_invo(v_cust.customerid) LOOP
			tenpercent := 0;
			SELECT AVG(kwh) INTO averagelastyear FROM INVOICE i WHERE customerid = v_invo.customerid and i.cutoffdate BETWEEN add_months(SYSDATE,mesunoanoanterior) AND add_months(SYSDATE,mesdoceanoanterior);
			SELECT AVG(kwh) INTO averagelastsixmonth FROM INVOICE i2 WHERE customerid = v_invo.customerid and i2.cutoffdate BETWEEN add_months(SYSDATE,-7) AND add_months(SYSDATE,-1);
			DBMS_OUTPUT.PUT_LINE(v_invo.invoiceid||' - '||v_invo.cutoffdate|| ' - '||v_invo.kwh||' - '||' - '||averagelastyear||' - '||averagelastsixmonth);
			IF v_invo.cutoffdate BETWEEN add_months(SYSDATE,-1) AND add_months(SYSDATE,0) THEN 		
			currentinvoiceid := v_invo.invoiceid;
			END IF;
			tenpercent := averagelastyear * 0.1;
			pno := averagelastyear - tenpercent;
			difference := averagelastsixmonth-averagelastyear;
		END LOOP;
		IF averagelastsixmonth < pno THEN
			DBMS_OUTPUT.PUT_LINE('3. PNO ');
			INSERT INTO TICKET (CREATEDATE,FRAUD,OBSERVATIONS,CONDITIONS,STATE,INVOICEID,EMPLOYEEID,DIFFERENCE)
			VALUES (sysdate,0,' ',' ','Abierto',currentinvoiceid,121,difference);
		ELSE
			DBMS_OUTPUT.PUT_LINE('3. NO PNO ');
			BEGIN 
				conceptospnoresidencial.cuartoconcepto(v_cust.customerid);
			END;
		END IF;
	DBMS_OUTPUT.PUT_LINE('year '|| averagelastyear || '- six: '|| averagelastsixmonth || '- ten%: '||tenpercent||'- pno: '||pno||'- differe- '||difference);
	END LOOP;	
END tercerconcepto;
--CUARTO CONCEPTO
PROCEDURE cuartoconcepto (customer3 CUSTOMER.customerid%type) IS 
CURSOR c_cus IS 
		SELECT * FROM customer c WHERE CUSTOMERID = customer3;
	CURSOR c_invo (cust invoice.customerid%TYPE) IS
		SELECT * FROM INVOICE i WHERE CUSTOMERID = cust;
	currentmonth NUMBER;
	currentkwh NUMBER;
	nombre customer.name%TYPE;
	sumkwhlastyear NUMBER := 0;
	sumkwhlastsixmonth NUMBER := 0;
	pno NUMBER;
	currentinvoiceid number := 0;
	difference NUMBER(10,2) := 0;
	tenpercent NUMBER(10,2) := 0;
	currentstratum NUMBER (10,3) := 0;
	avgcurrentstratum NUMBER (10,3) :=0;	
BEGIN
	SELECT EXTRACT (MONTH FROM sysdate) INTO currentmonth FROM dual;
	FOR v_cust IN c_cus LOOP
		SELECT name INTO nombre FROM CUSTOMER c 
		WHERE customerid = v_cust.customerid;
		DBMS_OUTPUT.PUT_LINE('NOMBRE4: '|| nombre);
		SELECT AVG(kwh) INTO avgcurrentstratum FROM INVOICE i 
		JOIN CUSTOMER c ON (i.CUSTOMERID = c.CUSTOMERID) WHERE (i.CUSTOMERID != v_cust.customerid AND c.STRATUM = v_cust.stratum) AND i.CUTOFFDATE BETWEEN ADD_MONTHS(SYSDATE,-1) AND add_months(SYSDATE,0);
		FOR v_invo IN c_invo(v_cust.customerid) LOOP
			IF v_invo.cutoffdate BETWEEN add_months(SYSDATE,-1) AND add_months(SYSDATE,0) THEN 
				currentkwh :=  v_invo.kwh;
				currentinvoiceid := v_invo.invoiceid;
			END IF;			
		END LOOP;
		tenpercent := avgcurrentstratum * 0.1;
		pno := avgcurrentstratum - tenpercent;
		difference := currentkwh-avgcurrentstratum;
		IF currentkwh < pno THEN
			DBMS_OUTPUT.PUT_LINE('4. PNO ');
			INSERT INTO TICKET (CREATEDATE,FRAUD,OBSERVATIONS,CONDITIONS,STATE,INVOICEID,EMPLOYEEID,DIFFERENCE)
			VALUES (sysdate,0,' ',' ','Abierto',currentinvoiceid,121,difference);
		ELSE
			DBMS_OUTPUT.PUT_LINE('4. NO PNO ');
		END IF;
		DBMS_OUTPUT.PUT_LINE('suma '||nombre||' - '|| avgcurrentstratum  || ' - '|| currentkwh || ' - '||tenpercent||' - '||pno||' - '||difference);
	END LOOP;
	-- Para pruebas
END cuartoconcepto;
END conceptospnoresidencial;

BEGIN
	 conceptospnoresidencial.primerconcepto;
END;
	


--------------------------------------->> PROCEDIMIENTOS PARA CLIENTES VIP <<-------------------------------------------------

CREATE OR REPLACE PACKAGE conceptospnovip IS 
	PROCEDURE primerconcepto;
	PROCEDURE segundoconcepto(customer1 CUSTOMER.customerid%type);
	PROCEDURE tercerconcepto(customer2 CUSTOMER.customerid%type);
	PROCEDURE cuartoconcepto(customer3 CUSTOMER.customerid%type); 
END conceptospnovip;

CREATE OR REPLACE PACKAGE BODY conceptospnovip IS 	
PROCEDURE primerconcepto IS 
CURSOR c_cus IS 
		SELECT customerid FROM customer c WHERE PRIORITY = 'VIP';
	CURSOR c_invo (cust invoice.customerid%TYPE) IS
		SELECT * FROM INVOICE i WHERE CUSTOMERID = cust;
	currentmonth NUMBER;
	currentkwh NUMBER;
	nombre customer.name%TYPE;
	sumakwh NUMBER := 0;
	promedio NUMBER(8,2);
	diezporciento NUMBER :=0;
	pno NUMBER;
	currentinvoiceid number := 0;
	difference NUMBER := 0;
	topen NUMBER := 0;
	counttickets NUMBER := 0;
BEGIN
	SELECT EXTRACT (MONTH FROM sysdate) INTO currentmonth FROM dual;
	FOR v_cust IN c_cus LOOP
		SELECT name INTO nombre FROM CUSTOMER c 
		WHERE customerid = v_cust.customerid;
		DBMS_OUTPUT.PUT_LINE('NOMBRE: '|| nombre||' - ' ||v_cust.customerid);
		SELECT COUNT(t.TICKETID) INTO topen FROM TICKET t 
		JOIN INVOICE i ON (t.INVOICEID = i.INVOICEID)
		WHERE STATE = 'Abierto' AND i.CUSTOMERID =	v_cust.customerid;
		SELECT COUNT(i2.invoiceid) INTO counttickets FROM INVOICE i2 
		WHERE i2.CUSTOMERID = v_cust.customerid;
		IF topen = 0 AND counttickets >= 1 THEN 
			FOR v_invo IN c_invo(v_cust.customerid) LOOP
			  SELECT avg(kwh) INTO promedio FROM INVOICE i WHERE customerid = v_invo.customerid AND i.cutoffdate BETWEEN add_months(SYSDATE,-7) AND add_months(SYSDATE,-1);
				IF v_invo.cutoffdate BETWEEN add_months(SYSDATE,-1) AND add_months(SYSDATE,0) THEN 		
				currentkwh := v_invo.kwh;
				currentinvoiceid := v_invo.invoiceid;
				END IF;		
			END LOOP;
			diezporciento := promedio * 0.1;
			pno := promedio - diezporciento;
			difference := currentkwh-promedio;
			IF promedio = 0 THEN
				DBMS_OUTPUT.PUT_LINE('No se encontraron registros de los 6 meses anteriores');
			ELSE IF currentkwh < pno THEN			
				DBMS_OUTPUT.PUT_LINE('1.PNO');
				INSERT INTO TICKET (CREATEDATE,FRAUD,OBSERVATIONS,CONDITIONS,STATE,INVOICEID,EMPLOYEEID,DIFFERENCE)
				VALUES (sysdate,0,' ',' ','Abierto',currentinvoiceid,121,difference);
				DBMS_OUTPUT.PUT_LINE('suma '|| sumakwh || ' - '|| currentkwh || ' - '||promedio||' - '||diezporciento||' - '||pno||' - '||currentinvoiceid);
				ELSE
					DBMS_OUTPUT.PUT_LINE('suma '|| sumakwh || ' - '|| currentkwh || ' - '||promedio||' - '||diezporciento||' - '||pno||' - '||currentinvoiceid);
					DBMS_OUTPUT.PUT_LINE('1. NO PNO '||v_cust.customerid);
					BEGIN
						conceptospnoresidencial.segundoconcepto(v_cust.customerid);
					END;
				END IF;
			END IF;
		END IF;
	END LOOP;
	--Para pruebas
		--DBMS_OUTPUT.PUT_LINE('suma '|| sumakwh || ' - '|| currentkwh || ' - '||promedio||' - '||diezporciento||' - '||pno||' - '||difference);
END primerconcepto;
--SEGUNDO CONCEPTO
PROCEDURE segundoconcepto(customer1 CUSTOMER.customerid%type) is
CURSOR c_cus IS 
		SELECT c.CUSTOMERID FROM customer c WHERE c.CUSTOMERID = customer1;
	CURSOR c_invo (cust invoice.customerid%TYPE) IS
		SELECT * FROM INVOICE i WHERE CUSTOMERID = cust;
	currentmonth NUMBER;
	currentkwh NUMBER;
	nombre customer.name%TYPE;
	sumakwh NUMBER := 0;
	diezporciento NUMBER;
	pno NUMBER;
	currentinvoiceid number := 0;
	difference NUMBER := 0;
BEGIN
	SELECT EXTRACT (MONTH FROM sysdate) INTO currentmonth FROM dual;
	FOR v_cust IN c_cus LOOP
		SELECT name INTO nombre FROM CUSTOMER c 
		WHERE customerid = v_cust.customerid;
		DBMS_OUTPUT.PUT_LINE('NOMBRE2: '|| nombre);
		DBMS_OUTPUT.PUT_LINE(v_cust.customerid);
		FOR v_invo IN c_invo(v_cust.customerid) LOOP
			IF v_invo.cutoffdate BETWEEN add_months(SYSDATE,-13) AND add_months(SYSDATE,-12) THEN 
				sumakwh := sumakwh + v_invo.kwh;
			END IF;
			IF v_invo.cutoffdate BETWEEN add_months(SYSDATE,-1) AND add_months(SYSDATE,0) THEN 		
			currentkwh := v_invo.kwh;
			currentinvoiceid := v_invo.invoiceid;
			END IF;		
		END LOOP;
		diezporciento := currentkwh * 0.1;
		pno := currentkwh - diezporciento;
		difference := sumakwh-currentkwh;
		IF sumakwh = 0 THEN
			DBMS_OUTPUT.PUT_LINE('no hay registros del año pasado.');
			DBMS_OUTPUT.PUT_LINE('2. NO PNO ');
				BEGIN
					conceptospnoresidencial.tercerconcepto(v_cust.customerid);
				END;
		ELSE IF sumakwh < pno THEN
			DBMS_OUTPUT.PUT_LINE('2.PNO ');
			INSERT INTO TICKET (CREATEDATE,FRAUD,OBSERVATIONS,CONDITIONS,STATE,INVOICEID,EMPLOYEEID,DIFFERENCE)
			VALUES (sysdate,0,' ',' ','Abierto',currentinvoiceid,1,difference);
			ELSE
				DBMS_OUTPUT.PUT_LINE('2. NO PNO ');
				BEGIN
					conceptospnoresidencial.tercerconcepto(v_cust.customerid);
				END;								
			END IF;
		END IF;
	END LOOP;
	-- Para pruebas
		--DBMS_OUTPUT.PUT_LINE('suma '|| sumakwh || ' - '|| currentkwh || ' - '||diezporciento||' - '||pno||' - '||difference);
END segundoconcepto;
--TERCER CONCEPTO V2 (UTILIZAR ESTE)
PROCEDURE tercerconcepto(customer2 CUSTOMER.customerid%type) IS 
CURSOR c_cus IS 
		SELECT customerid FROM customer c WHERE CUSTOMERID = customer2;
	CURSOR c_invo (cust invoice.customerid%TYPE) IS
		SELECT * FROM INVOICE i WHERE CUSTOMERID = cust;
	currentmonth NUMBER;
	currentkwh NUMBER;
	nombre customer.name%TYPE;
	sumkwhlastyear NUMBER := 0;
	sumkwhlastsixmonth NUMBER := 0;
	pno NUMBER;
	currentinvoiceid number := 0;
	difference NUMBER(10,2) := 0;
	montonelastyear number :=0;
	monthtwelvelastyear NUMBER :=0;
	mesunoanoanterior NUMBER :=0;
	mesdoceanoanterior NUMBER :=0;
	averagelastsixmonth NUMBER(10,2) :=0;
	averagelastyear NUMBER(10,2) :=0;
	tenpercent NUMBER(10,2) := 0;
	countyear NUMBER :=0;
	countmonth NUMBER :=0;	
BEGIn
	SELECT EXTRACT (MONTH FROM sysdate) INTO currentmonth FROM dual;
	FOR v_cust IN c_cus LOOP
		SELECT name INTO nombre FROM CUSTOMER c 
		WHERE customerid = v_cust.customerid;
		DBMS_OUTPUT.PUT_LINE('NOMBRE3: '|| nombre);
		mesunoanoanterior := (currentmonth+12)*-1;
		mesdoceanoanterior := currentmonth*-1;
		FOR v_invo IN c_invo(v_cust.customerid) LOOP
			tenpercent := 0;
			SELECT AVG(kwh) INTO averagelastyear FROM INVOICE i WHERE customerid = v_invo.customerid and i.cutoffdate BETWEEN add_months(SYSDATE,mesunoanoanterior) AND add_months(SYSDATE,mesdoceanoanterior);
			SELECT AVG(kwh) INTO averagelastsixmonth FROM INVOICE i2 WHERE customerid = v_invo.customerid and i2.cutoffdate BETWEEN add_months(SYSDATE,-7) AND add_months(SYSDATE,-1);
			DBMS_OUTPUT.PUT_LINE(v_invo.invoiceid||' - '||v_invo.cutoffdate|| ' - '||v_invo.kwh||' - '||' - '||averagelastyear||' - '||averagelastsixmonth);
			IF v_invo.cutoffdate BETWEEN add_months(SYSDATE,-1) AND add_months(SYSDATE,0) THEN 		
			currentinvoiceid := v_invo.invoiceid;
			END IF;
			tenpercent := averagelastyear * 0.1;
			pno := averagelastyear - tenpercent;
			difference := averagelastsixmonth-averagelastyear;
		END LOOP;
		IF averagelastsixmonth < pno THEN
			DBMS_OUTPUT.PUT_LINE('3. PNO ');
			INSERT INTO TICKET (CREATEDATE,FRAUD,OBSERVATIONS,CONDITIONS,STATE,INVOICEID,EMPLOYEEID,DIFFERENCE)
			VALUES (sysdate,0,' ',' ','Abierto',currentinvoiceid,121,difference);
		ELSE
			DBMS_OUTPUT.PUT_LINE('3. NO PNO ');
			BEGIN 
				conceptospnoresidencial.cuartoconcepto(v_cust.customerid);
			END;
		END IF;
	DBMS_OUTPUT.PUT_LINE('year '|| averagelastyear || '- six: '|| averagelastsixmonth || '- ten%: '||tenpercent||'- pno: '||pno||'- differe- '||difference);
	END LOOP;	
END tercerconcepto;
--CUARTO CONCEPTO
PROCEDURE cuartoconcepto (customer3 CUSTOMER.customerid%type) IS 
CURSOR c_cus IS 
		SELECT * FROM customer c WHERE CUSTOMERID = customer3;
	CURSOR c_invo (cust invoice.customerid%TYPE) IS
		SELECT * FROM INVOICE i WHERE CUSTOMERID = cust;
	currentmonth NUMBER;
	currentkwh NUMBER;
	nombre customer.name%TYPE;
	sumkwhlastyear NUMBER := 0;
	sumkwhlastsixmonth NUMBER := 0;
	pno NUMBER;
	currentinvoiceid number := 0;
	difference NUMBER(10,2) := 0;
	tenpercent NUMBER(10,2) := 0;
	currentstratum NUMBER (10,3) := 0;
	avgcurrentstratum NUMBER (10,3) :=0;	
BEGIN
	SELECT EXTRACT (MONTH FROM sysdate) INTO currentmonth FROM dual;
	FOR v_cust IN c_cus LOOP
		SELECT name INTO nombre FROM CUSTOMER c 
		WHERE customerid = v_cust.customerid;
		DBMS_OUTPUT.PUT_LINE('NOMBRE4: '|| nombre);
		SELECT AVG(kwh) INTO avgcurrentstratum FROM INVOICE i 
		JOIN CUSTOMER c ON (i.CUSTOMERID = c.CUSTOMERID) WHERE (i.CUSTOMERID != v_cust.customerid AND c.STRATUM = v_cust.stratum) AND i.CUTOFFDATE BETWEEN ADD_MONTHS(SYSDATE,-1) AND add_months(SYSDATE,0);
		FOR v_invo IN c_invo(v_cust.customerid) LOOP
			IF v_invo.cutoffdate BETWEEN add_months(SYSDATE,-1) AND add_months(SYSDATE,0) THEN 
				currentkwh :=  v_invo.kwh;
				currentinvoiceid := v_invo.invoiceid;
			END IF;			
		END LOOP;
		tenpercent := avgcurrentstratum * 0.1;
		pno := avgcurrentstratum - tenpercent;
		difference := currentkwh-avgcurrentstratum;
		IF currentkwh < pno THEN
			DBMS_OUTPUT.PUT_LINE('4. PNO ');
			INSERT INTO TICKET (CREATEDATE,FRAUD,OBSERVATIONS,CONDITIONS,STATE,INVOICEID,EMPLOYEEID,DIFFERENCE)
			VALUES (sysdate,0,' ',' ','Abierto',currentinvoiceid,121,difference);
		ELSE
			DBMS_OUTPUT.PUT_LINE('4. NO PNO ');
		END IF;
		DBMS_OUTPUT.PUT_LINE('suma '||nombre||' - '|| avgcurrentstratum  || ' - '|| currentkwh || ' - '||tenpercent||' - '||pno||' - '||difference);
	END LOOP;
	-- Para pruebas
END cuartoconcepto;
END conceptospnovip;




BEGIN
	conceptospno.primerconcepto;
END;


