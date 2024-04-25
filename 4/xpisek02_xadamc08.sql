--Autoři Tobiáš Adamčík (xadamc08), Lukáš Píšek (xpisek02)

--=================================== DROP TABLE =========================================
DROP TABLE MEMBER_OPERATION CASCADE CONSTRAINTS;

DROP TABLE ALIANCE_OPERATION CASCADE CONSTRAINTS;

DROP TABLE ALIANCE_FAMILY CASCADE CONSTRAINTS;

DROP TABLE OPERATION_TERRITORY CASCADE CONSTRAINTS;

DROP TABLE MEETING_ATTENDEE CASCADE CONSTRAINTS;

DROP TABLE MEETING CASCADE CONSTRAINTS;

DROP TABLE DON CASCADE CONSTRAINTS;

DROP TABLE ORDER_TABLE CASCADE CONSTRAINTS;

DROP TABLE MURDER CASCADE CONSTRAINTS;

DROP TABLE MEMBER_TABLE CASCADE CONSTRAINTS;

DROP TABLE TERRITORY CASCADE CONSTRAINTS;

DROP TABLE FAMILY CASCADE CONSTRAINTS;

DROP TABLE OPERATION CASCADE CONSTRAINTS;

DROP TABLE PERSON CASCADE CONSTRAINTS;

DROP TABLE ALIANCE CASCADE CONSTRAINTS;

DROP MATERIALIZED VIEW "family_user_count";

--=================================== CREATE TABLE =========================================

CREATE TABLE PERSON
(
    PERSON_ID          INT GENERATED AS IDENTITY NOT NULL PRIMARY KEY,
    NAME               VARCHAR(100),
    AGE                NUMBER(3),
    --Toto je zde pouze pro předvedení triggeru
    HEARTATTACK_CHANCE NUMBER CHECK (HEARTATTACK_CHANCE BETWEEN 0 AND 1)
);

--Generalizace/specializace je zde udělána pomocí FK PERSON jakožto atributu MEMBER_TABLE, ktery odkazuje na PERSON odpovídající dané MEMBER_TABLE. Tímto je dodržen vztah "is a" mezi MEMBER_TABLE a PERSON. Obdobně je udělán vztah mezi MURDER a OPERATION.
CREATE TABLE MEMBER_TABLE
(
    MEMBER_ID     INT NOT NULL PRIMARY KEY,
    PERSON_ID     INT,
    AUTHORIZATION VARCHAR(20) CHECK ( AUTHORIZATION IN ('Velkej čavo', 'Střední čavo', 'Malej čavo')),
    SHOE_SIZE     NUMBER(3),
    FAMILY_ID     INT NOT NULL,
    FOREIGN KEY (PERSON_ID) REFERENCES PERSON (PERSON_ID) ON DELETE CASCADE
    --FK Kriminální operace je řešená tabulkou dole
);

CREATE TABLE FAMILY
(
    FAMILY_ID INT GENERATED AS IDENTITY NOT NULL PRIMARY KEY,
    DON_ID    INT                       NOT NULL
);

CREATE TABLE OPERATION
(
    OPERATION_NAME VARCHAR(50) NOT NULL PRIMARY KEY,
    OP_TYPE        VARCHAR(100),
    OP_DATE_START  DATE,
    OP_DATE_FINISH DATE,
    --FK Území je řešené tabulkou dole
    OWNING_FAMILY  INT         NOT NULL
);

--Generalizace/specializace je zde udělána pomocí FK OPERATION jakožto atributu MURDER, který odkazuje na OPERATION odpovídající dané MURDER. Tímto je dodržen vztah "is a" mezi MURDER a OPERATION.
CREATE TABLE MURDER
(
    MURDER_NAME   VARCHAR(50) NOT NULL PRIMARY KEY,
    --TIME_OF_MURDER DATE nepoužíváme nakonec
    MURDER_WEAPON VARCHAR(50),
    VICTIM        INT         NOT NULL,
    FOREIGN KEY (MURDER_NAME) REFERENCES OPERATION (OPERATION_NAME) ON DELETE CASCADE
);

CREATE TABLE ORDER_TABLE
(
    ORDER_ID   INT GENERATED AS IDENTITY NOT NULL PRIMARY KEY,
    ORDER_NAME VARCHAR(50),
    DON_ID     INT,
    VICTIM     INT,
    MURDER     VARCHAR(50)
);

CREATE TABLE DON
(
    DON_ID    INT GENERATED AS IDENTITY NOT NULL PRIMARY KEY,
    NAME      VARCHAR(100),
    AGE       NUMBER(3),
    SHOE_SIZE NUMBER(3)
);

CREATE TABLE MEETING
(
    MEETING_ID   INT GENERATED AS IDENTITY NOT NULL PRIMARY KEY,
    MEET_DATE    DATE,
    --FK Účastníci jsou vyřešeni tabulkou dole
    TERRITORY_ID VARCHAR(100)              NOT NULL
);

CREATE TABLE TERRITORY
(
    GPS       VARCHAR(100) NOT NULL PRIMARY KEY CHECK (REGEXP_LIKE(GPS,
                                                                   '^([1-8]?[1-9]|[1-9]0)\.{1}\d{1,6}[NS],\s?((([1]?[0-7]?|[1-9]?)[0-9])|([1]?[1-8][0])|([1]?[1-7][1-9])|([1]?[0-8][0])|([1-9]0))\.{1}\d{1,6}[EW]$')),
    AREA      DECIMAL(10, 5),
    --ADRESS VARCHAR(50) redundantní
    FAMILY_ID INT
);

CREATE TABLE ALIANCE
(
    ALIANCE_ID INT GENERATED AS IDENTITY NOT NULL PRIMARY KEY
    --FK Rodiny jsou řešené tabulkou dole
    --FK Kriminální operace je řešená tabulkou dole'
);

--=================================== Propojovací tabulky =========================================

CREATE TABLE MEETING_ATTENDEE
(
    MEETING_ID INT,
    DON_ID     INT NOT NULL,
    PRIMARY KEY (MEETING_ID, DON_ID),
    CONSTRAINT MEETING_FK FOREIGN KEY (MEETING_ID) REFERENCES MEETING (MEETING_ID) ON DELETE CASCADE,
    CONSTRAINT DON_FK FOREIGN KEY (DON_ID) REFERENCES DON (DON_ID) ON DELETE CASCADE
);

CREATE TABLE MEMBER_OPERATION
(
    MEMBER_ID      INT,
    OPERATION_NAME VARCHAR(50) NOT NULL,
    PRIMARY KEY (MEMBER_ID, OPERATION_NAME),
    CONSTRAINT MEMBER_FK FOREIGN KEY (MEMBER_ID) REFERENCES MEMBER_TABLE (MEMBER_ID) ON DELETE CASCADE,
    CONSTRAINT OPERATION_FK FOREIGN KEY (OPERATION_NAME) REFERENCES OPERATION (OPERATION_NAME) ON DELETE CASCADE
);

CREATE TABLE ALIANCE_OPERATION
(
    ALIANCE_ID     INT,
    OPERATION_NAME VARCHAR(50) NOT NULL,
    PRIMARY KEY (ALIANCE_ID, OPERATION_NAME),
    CONSTRAINT ALIANCE_FK FOREIGN KEY (ALIANCE_ID) REFERENCES ALIANCE (ALIANCE_ID) ON DELETE CASCADE,
    CONSTRAINT OPERATION_FK_ALI_OP FOREIGN KEY (OPERATION_NAME) REFERENCES OPERATION (OPERATION_NAME) ON DELETE CASCADE
);

CREATE TABLE ALIANCE_FAMILY
(
    ALIANCE_ID INT,
    FAMILY_ID  INT NOT NULL,
    PRIMARY KEY (ALIANCE_ID, FAMILY_ID),
    CONSTRAINT ALIANCE_FK_ALI_FAM FOREIGN KEY (ALIANCE_ID) REFERENCES ALIANCE (ALIANCE_ID) ON DELETE CASCADE,
    CONSTRAINT FAMILY_FK FOREIGN KEY (FAMILY_ID) REFERENCES FAMILY (FAMILY_ID) ON DELETE CASCADE
);

CREATE TABLE OPERATION_TERRITORY
(
    OPERATION_NAME VARCHAR(50)  NOT NULL,
    TERRITORY_ID   VARCHAR(100) NOT NULL,
    PRIMARY KEY (OPERATION_NAME, TERRITORY_ID),
    CONSTRAINT OPERATION_FK_OP_TER FOREIGN KEY (OPERATION_NAME) REFERENCES OPERATION (OPERATION_NAME) ON DELETE CASCADE,
    CONSTRAINT TERRITORY_FK FOREIGN KEY (TERRITORY_ID) REFERENCES TERRITORY (GPS) ON DELETE CASCADE
);

--=================================== ALTER TABLE =========================================

ALTER TABLE MEMBER_TABLE
    ADD CONSTRAINT FAMILY_FK_MEM_TAB FOREIGN KEY (FAMILY_ID) REFERENCES FAMILY (FAMILY_ID) ON DELETE CASCADE;

ALTER TABLE FAMILY
    ADD CONSTRAINT DON_FK_FAM FOREIGN KEY (DON_ID) REFERENCES DON (DON_ID) ON DELETE CASCADE;

ALTER TABLE OPERATION
    ADD CONSTRAINT OWNING_FAMILY_FK_OP FOREIGN KEY (OWNING_FAMILY) REFERENCES FAMILY (FAMILY_ID) ON DELETE CASCADE;

ALTER TABLE MURDER
    ADD CONSTRAINT VICTIM_FK FOREIGN KEY (VICTIM) REFERENCES PERSON (PERSON_ID) ON DELETE CASCADE;

ALTER TABLE ORDER_TABLE
    ADD CONSTRAINT VICTIM_FK_ORD_TAB FOREIGN KEY (VICTIM) REFERENCES PERSON (PERSON_ID) ON DELETE CASCADE
    ADD CONSTRAINT MURDER_FK FOREIGN KEY (MURDER) REFERENCES MURDER (MURDER_NAME) ON DELETE SET NULL
    ADD CONSTRAINT DON_ID FOREIGN KEY (DON_ID) REFERENCES DON (DON_ID);

ALTER TABLE MEETING
    ADD CONSTRAINT TERRITORY_FK_MEET FOREIGN KEY (TERRITORY_ID) REFERENCES TERRITORY (GPS) ON DELETE CASCADE;

ALTER TABLE TERRITORY
    ADD CONSTRAINT OWNING_FAMILY_FK_TER FOREIGN KEY (FAMILY_ID) REFERENCES FAMILY (FAMILY_ID) ON DELETE SET NULL;

--=================================== TRIGGER =========================================

-- Automaticky vytvoří rodinu pro dona při vytvoření nového dona
CREATE OR REPLACE TRIGGER ADD_FAMILY_TO_DON
    AFTER
        INSERT
    ON DON
    FOR EACH ROW
BEGIN
    INSERT INTO FAMILY (DON_ID)
    VALUES (:NEW.DON_ID);
END;

-- Automaticky vypočítá šanci na dostání infakrtu a omezí její výsledek na maximálně 1
CREATE OR REPLACE TRIGGER CALCULATE_HEARTATTACK_CHANCE
    BEFORE INSERT OR UPDATE OF AGE
    ON PERSON
    FOR EACH ROW
BEGIN
    :NEW.HEARTATTACK_CHANCE := LEAST(:NEW.AGE / 100, 1);
END;


--=================================== NAPLNIT DATY =========================================
INSERT INTO PERSON (NAME,
                    AGE)
VALUES ('Mr. GonnaDie :koteseni:',
        50);

INSERT INTO PERSON (NAME,
                    AGE)
VALUES ('Mr. Member',
        40);

INSERT INTO PERSON (NAME,
                    AGE)
VALUES ('Mr. Second Member',
        37);

--Ukázka že trigger funguje pro věk > 100
INSERT INTO PERSON (NAME,
                    AGE)
VALUES ('Mr. Old',
        101);

INSERT INTO DON (NAME,
                 AGE,
                 SHOE_SIZE)
VALUES ('Velkej Boss',
        45,
        48);

INSERT INTO DON (NAME,
                 AGE,
                 SHOE_SIZE)
VALUES ('Velkej Meeting Boss',
        50,
        45);

INSERT INTO ORDER_TABLE (ORDER_NAME,
                         DON_ID,
                         VICTIM)
VALUES ('Mr. Member',
        1,
        1);

INSERT INTO MEMBER_TABLE(MEMBER_ID,
                         AUTHORIZATION,
                         SHOE_SIZE,
                         FAMILY_ID,
                         PERSON_ID)
VALUES (2,
        'Velkej čavo',
        42,
        1,
        2);

INSERT INTO MEMBER_TABLE(MEMBER_ID,
                         AUTHORIZATION,
                         SHOE_SIZE,
                         FAMILY_ID,
                         PERSON_ID)
VALUES (3,
        'Střední čavo',
        41,
        1,
        3);

INSERT INTO OPERATION(OPERATION_NAME,
                      OP_TYPE,
                      OP_DATE_START,
                      OP_DATE_FINISH,
                      OWNING_FAMILY)
VALUES ('Vaření pervitinu',
        'Narkotika',
        TO_DATE('2024-02-08', 'YYYY-MM-DD'),
        TO_DATE('2024-05-08', 'YYYY-MM-DD'),
        1);

INSERT INTO OPERATION(OPERATION_NAME,
                      OP_TYPE,
                      OP_DATE_START,
                      OP_DATE_FINISH,
                      OWNING_FAMILY)
VALUES ('Vaření heroinu',
        'Narkotika',
        TO_DATE('2024-03-10', 'YYYY-MM-DD'),
        TO_DATE('2024-11-08', 'YYYY-MM-DD'),
        1);

INSERT INTO OPERATION(OPERATION_NAME,
                      OP_TYPE,
                      OP_DATE_START,
                      OP_DATE_FINISH,
                      OWNING_FAMILY)
VALUES ('Vražda 123',
        'Vražda',
        TO_DATE('2024-05-08', 'YYYY-MM-DD'),
        TO_DATE('2024-06-08', 'YYYY-MM-DD'),
        1);

INSERT INTO MURDER(MURDER_NAME,
                   MURDER_WEAPON,
                   VICTIM)
VALUES ('Vražda 123',
        'Nůž',
        1);

INSERT INTO TERRITORY(GPS,
                      AREA,
                      FAMILY_ID)
VALUES ('50.149N, 40.5E',
        50.44,
        1);

INSERT INTO TERRITORY(GPS,
                      AREA,
                      FAMILY_ID)
VALUES ('50.234N, 43.2E',
        50.44,
        1);

INSERT INTO MEETING(MEET_DATE,
                    TERRITORY_ID)
VALUES (TO_DATE('2024-07-15', 'YYYY/MM/DD'),
        '50.149N, 40.5E');

INSERT INTO MEETING_ATTENDEE(MEETING_ID,
                             DON_ID)
VALUES (1,
        1);

INSERT INTO MEETING_ATTENDEE(MEETING_ID,
                             DON_ID)
VALUES (1,
        2);

INSERT INTO MEMBER_OPERATION(MEMBER_ID,
                             OPERATION_NAME)
VALUES (2,
        'Vražda 123');

INSERT INTO MEMBER_OPERATION(MEMBER_ID,
                             OPERATION_NAME)
VALUES (2,
        'Vaření pervitinu');

INSERT INTO MEMBER_OPERATION(MEMBER_ID,
                             OPERATION_NAME)
VALUES (3,
        'Vaření heroinu');

INSERT INTO ALIANCE
VALUES (DEFAULT);

INSERT INTO ALIANCE_OPERATION(ALIANCE_ID,
                              OPERATION_NAME)
VALUES (1,
        'Vaření pervitinu');

INSERT INTO ALIANCE_FAMILY(ALIANCE_ID,
                           FAMILY_ID)
VALUES (1,
        1);

INSERT INTO OPERATION_TERRITORY(OPERATION_NAME,
                                TERRITORY_ID)
VALUES ('Vražda 123',
        '50.149N, 40.5E');

SELECT *
FROM OPERATION;

INSERT INTO OPERATION_TERRITORY(OPERATION_NAME,
                                TERRITORY_ID)
VALUES ('Vaření heroinu',
        '50.234N, 43.2E');

--=================================== PROCEDURY ======================================

-- Procedura vypíše procento členů s danou autorizací v dané rodině
CREATE OR REPLACE PROCEDURE percentage_of_members_by_authorization(
    v_authorization IN VARCHAR2,
    v_family_id IN NUMBER
)
AS
    "pocet"          NUMBER;
    "vysledek"       NUMBER;
    "pocet_v_rodine" NUMBER;
BEGIN

    SELECT COUNT(*)
    INTO "pocet_v_rodine"
    FROM FAMILY
             NATURAL JOIN MEMBER_TABLE
    WHERE FAMILY_ID = v_family_id;

    IF v_authorization = 'Velkej čavo' THEN
        SELECT COUNT(*)
        INTO
            "pocet"
        FROM MEMBER_TABLE
        WHERE AUTHORIZATION = 'Velkej čavo';
    END IF;
    IF v_authorization = 'Střední čavo' THEN
        SELECT COUNT(*)
        INTO
            "pocet"
        FROM MEMBER_TABLE
        WHERE AUTHORIZATION = 'Velkej čavo';
    END IF;
    IF v_authorization = 'Malej čavo' THEN
        SELECT COUNT(*)
        INTO
            "pocet"
        FROM MEMBER_TABLE
        WHERE AUTHORIZATION = 'Malej čavo';
    END IF;

    "vysledek" := "pocet" / "pocet_v_rodine";

    DBMS_OUTPUT.put_line('Podíl členů s autorizací ' || v_authorization || ' v rodině ' || v_family_id || ' je ' ||
                         "vysledek" * 100 || '%');

EXCEPTION
    WHEN ZERO_DIVIDE THEN
        BEGIN
            DBMS_OUTPUT.put_line('Nulový počet členů v rodině');
        END;

END;

-- Spuštění procedury
BEGIN
    percentage_of_members_by_authorization('Velkej čavo', 1);
END;


-- Vytvoření objednávky na vraždu všech členů rodiny
CREATE OR REPLACE PROCEDURE murder_tool(v_family_id IN FAMILY.FAMILY_ID%TYPE, v_don_id IN DON.DON_ID%TYPE)
AS
    CURSOR member_cursor IS
        SELECT PERSON_ID
        FROM MEMBER_TABLE
                 NATURAL JOIN PERSON
        WHERE FAMILY_ID = v_family_id;
    member_rec member_cursor%ROWTYPE;
    v_name     PERSON.NAME%TYPE;
BEGIN
    OPEN member_cursor;
    LOOP
        FETCH member_cursor INTO member_rec;
        EXIT WHEN member_cursor%NOTFOUND;
        SELECT NAME INTO v_name FROM PERSON WHERE PERSON_ID = member_rec.PERSON_ID;
        INSERT INTO ORDER_TABLE (VICTIM, ORDER_NAME, DON_ID) VALUES (member_rec.PERSON_ID, v_name, v_don_id);
    END LOOP;
    CLOSE member_cursor;
END;

-- Spuštění procedury
BEGIN
    murder_tool(1, 1);
END;

--=================================== EXPLAIN PLAN ======================================

-- Vypíše členy podle aurorizace v rodině 1 účastnících se operace typu "Narkotika"
CREATE INDEX idx_auth_family ON MEMBER_TABLE (AUTHORIZATION, FAMILY_ID);

EXPLAIN PLAN FOR
SELECT DISTINCT AUTHORIZATION, COUNT(*) as "Pocet"
FROM
(
    SELECT DISTINCT MEMBER_ID, AUTHORIZATION 
    FROM MEMBER_TABLE JOIN OPERATION ON MEMBER_TABLE.FAMILY_ID = OPERATION.OWNING_FAMILY
    WHERE FAMILY_ID = 1
    AND OP_TYPE = 'Narkotika'
)
GROUP BY AUTHORIZATION;

SELECT *
FROM TABLE (DBMS_XPLAN.DISPLAY);

-- Zde je index dropnut aby bylo ukázáno, že jeho přítomnost má pozitivní vliv na výkon
DROP INDEX idx_auth_family;

EXPLAIN PLAN FOR
SELECT DISTINCT AUTHORIZATION, COUNT(*) as Pocet
FROM
    (
        SELECT DISTINCT MEMBER_ID, AUTHORIZATION
        FROM MEMBER_TABLE JOIN OPERATION ON MEMBER_TABLE.FAMILY_ID = OPERATION.OWNING_FAMILY
        WHERE FAMILY_ID = 1
          AND OP_TYPE = 'Narkotika'
    )
GROUP BY AUTHORIZATION;

SELECT *
FROM TABLE (DBMS_XPLAN.DISPLAY);


--=================================== MATERIALIZED VIEW ======================================
--Materializovaný pohled na věechny rodiny a počet jejich členů
CREATE MATERIALIZED VIEW "family_user_count" AS
SELECT FAMILY_ID, COUNT(*) as Pocet_clenu
FROM FAMILY NATURAL JOIN MEMBER_TABLE
GROUP BY FAMILY_ID;

-- Výpis materializovaného pohledu
SELECT * FROM "family_user_count";

-- Vložení nového člena do rodiny
INSERT INTO MEMBER_TABLE(MEMBER_ID,
                         AUTHORIZATION,
                         SHOE_SIZE,
                         FAMILY_ID,
                         PERSON_ID)
VALUES (4,
        'Malej čavo',
        50,
        1,
        4);
    
-- Data v materializované tabulce se nezmění
SELECT * FROM "family_user_count";

--=================================== KOMPLEXNÍ SELECT ======================================
WITH member_info AS (
    SELECT PERSON_ID, 
        CASE
            WHEN AGE < 30 THEN 'Mladý'
            WHEN AGE BETWEEN 30 AND 50 THEN 'Střední'
            ELSE 'Starý'
        END AS AGE_GROUP
    FROM PERSON
)
SELECT * FROM member_info NATURAL JOIN Person NATURAL JOIN MEMBER_TABLE;

--=================================== DALŠÍ ČLEN ======================================
GRANT ALL ON "MEMBER_OPERATION" TO "XADAMC08";
GRANT ALL ON "ALIANCE_OPERATION" TO "XADAMC08";
GRANT ALL ON "ALIANCE_FAMILY" TO "XADAMC08";
GRANT ALL ON "OPERATION_TERRITORY" TO "XADAMC08";
GRANT ALL ON "MEETING_ATTENDEE" TO "XADAMC08";
GRANT ALL ON "MEETING" TO "XADAMC08";
GRANT ALL ON "DON" TO "XADAMC08";
GRANT ALL ON "ORDER_TABLE" TO "XADAMC08";
GRANT ALL ON "MURDER" TO "XADAMC08";
GRANT ALL ON "MEMBER_TABLE" TO "XADAMC08";
GRANT ALL ON "TERRITORY" TO "XADAMC08";
GRANT ALL ON "FAMILY" TO "XADAMC08";
GRANT ALL ON "OPERATION" TO "XADAMC08";
GRANT ALL ON "PERSON" TO "XADAMC08";
GRANT ALL ON "ALIANCE" TO "XADAMC08";

GRANT EXECUTE ON percentage_of_members_by_authorization TO "XADAMC08";
GRANT EXECUTE ON murder_tool TO "XADAMC08";

GRANT ALL ON "family_user_count" TO "XADAMC08";


