CREATE TABLE customer (
cutomerid NUMBER(10) PRIMARY KEY,
cname VARCHAR2(100) NOT NULL,
address VARCHAR2(100) NOT NULL,
additionalinfo VARCHAR2(100),
typedocument VARCHAR2(10),
document VARCHAR2(100) NOT NULL,
priority VARCHAR2(100) NOT NULL,
state NUMBER NOT NULL,
townid NUMBER NOT NULL
);

CREATE TABLE town (
townid NUMBER(4) PRIMARY KEY,
tname varchar2(50) NOT NULL
)

CREATE TABLE invoice (
invoiceid NUMBER PRIMARY KEY,
cutoffdate DATE NOT NULL,
kwh NUMBER (10,2) NOT NULL,
price NUMBER (20,2) NOT NULL,
customerid number(10)
)

CREATE TABLE ticket(
ticketid NUMBER PRIMARY KEY,
cratedate DATE NOT NULL,
fraud NUMBER(1),
observations varchar2(500),
conditions varchar2(20),
state varchar2(10) NOT NULL,
invoiceid NUMBER,
employeeid NUMBER,
DIFFERENCE NUMBER
)

CREATE TABLE employee ( 
employeeid NUMBER PRIMARY KEY,
name varchar2(200) NOT NULL,
ROLE varchar2(10) NOT NULL,
vip number(1) NOT NULL,
state NUMBER(1) NOT NULL,
email varchar2(50) NOT NULL
townid NUMBER NOT NULL,
password NUMBER NOT NULL,
identification NUMBER NOT NULL
)

CREATE TABLE kilowatts (
kilowattid NUMBER PRIMARY KEY,
price NUMBER NOT null
)

CREATE TABLE roles (
roleid NUMBER PRIMARY KEY,
rolename varchar2(50) NOT null
)

CREATE TABLE EMPLOYEE_ROL (
employeeid NUMBER,
roleid NUMBER
)

CREATE TABLE EMPLOYEE_ROL (
employeeid NUMBER,
roleid NUMBER
)

CREATE TABLE report1 (
	town VARCHAR2(38),
	avglastyear NUMBER(10,2),
	lastinvoice NUMBER(10,2),
	difference  NUMBER(10,2)
)

CREATE TABLE report2 (
	town VARCHAR2(38),
	stolen NUMBER(10,2),
	ilegalcon NUMBER(10,2),
	alteration  NUMBER(10,2),
	total number(10,2)
)


--Llaves foraneas
ALTER TABLE customer 
ADD CONSTRAINT townid_fk FOREIGN KEY (townid)
REFERENCES town(townid)

ALTER TABLE INVOICE 
ADD CONSTRAINT customer_fk FOREIGN KEY (customerid)
REFERENCES customer(cutomerid)

ALTER TABLE ticket 
ADD CONSTRAINT invoice_fk FOREIGN KEY (invoiceid)
REFERENCES invoice(invoiceid)

ALTER TABLE ticket 
ADD CONSTRAINT employee_fk FOREIGN KEY (employeeid)
REFERENCES employee(employeeid)

ALTER TABLE EMPLOYEE 
ADD CONSTRAINT townemployee_fk FOREIGN KEY (townid)
REFERENCES town(townid)
 
ALTER TABLE employee_rol 
ADD CONSTRAINT employeeid_fk FOREIGN KEY (employeeid)
REFERENCES employee(id)

ALTER TABLE employee_rol 
ADD CONSTRAINT roleeid_fk FOREIGN KEY (roleid)
REFERENCES ROLES(roleid)


-- Secuencias y triggers
CREATE SEQUENCE sequencecust
START WITH 1
INCREMENT BY 1;

CREATE TRIGGER customertrigger
BEFORE INSERT on customer
FOR EACH ROW 
BEGIN 
	SELECT sequencecust.NEXTVAL INTO :NEW.townid FROM DUAL;
END;

CREATE SEQUENCE sequencetown
START WITH 1
INCREMENT BY 1;

CREATE OR REPLACE TRIGGER towntrigger
BEFORE INSERT on town
FOR EACH ROW 
BEGIN 
	SELECT sequencetown.NEXTVAL INTO :NEW.townid FROM DUAL;
END;

CREATE SEQUENCE sequenceinvoice
START WITH 1
INCREMENT BY 1;

CREATE OR REPLACE TRIGGER invocetriggerseq
BEFORE INSERT on invoice
FOR EACH ROW 
BEGIN 
	SELECT sequenceinvoice.NEXTVAL INTO :NEW.invoiceid FROM DUAL;
END;

CREATE SEQUENCE sequenceemployee
START WITH 1
INCREMENT BY 1;

CREATE OR REPLACE TRIGGER employeetriggerseq
BEFORE INSERT on employee
FOR EACH ROW 
BEGIN 
	SELECT sequenceemployee.NEXTVAL INTO :NEW.id FROM DUAL;
END;

CREATE SEQUENCE sequenceticket
START WITH 1
INCREMENT BY 1;

CREATE OR REPLACE TRIGGER tickettriggerseq
BEFORE INSERT on ticket
FOR EACH ROW 
BEGIN 
	SELECT sequenceticket.NEXTVAL INTO :NEW.ticketid FROM DUAL;
END;

CREATE SEQUENCE sequencekilowatts
START WITH 1
INCREMENT BY 1;

CREATE OR REPLACE TRIGGER kilowattstriggerseq
BEFORE INSERT on kilowatts
FOR EACH ROW 
BEGIN 
	SELECT sequencekilowatts.NEXTVAL INTO :NEW.kilowattsid FROM DUAL;
END;

CREATE SEQUENCE sequenceroles
START WITH 1
INCREMENT BY 1;

CREATE OR REPLACE TRIGGER rolesstriggerseq
BEFORE INSERT on roles
FOR EACH ROW 
BEGIN 
	SELECT sequenceroles.NEXTVAL INTO :NEW.roleid FROM DUAL;
END;


