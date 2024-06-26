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

--=================================== CREATE TABLE =========================================

CREATE TABLE PERSON (
    ID INT GENERATED AS IDENTITY NOT NULL PRIMARY KEY,
    NAME VARCHAR(100),
    AGE NUMBER(3)
);

--Generalizace/specializace je zde udělána pomocí FK PERSON jakožto atributu MEMBER_TABLE, ktery odkazuje na PERSON odpovídající dané MEMBER_TABLE. Tímto je dodržen vztah "is a" mezi MEMBER_TABLE a PERSON. Obdobně je udělán vztah mezi MURDER a OPERATION.
CREATE TABLE MEMBER_TABLE (
    ID INT NOT NULL PRIMARY KEY,
    AUTHORIZATION VARCHAR(20) CHECK( AUTHORIZATION IN('Velkej čavo', 'Střední čavo', 'Malej čavo')),
    SHOE_SIZE NUMBER(3),
    FAMILY_ID INT NOT NULL,
    FOREIGN KEY (ID) REFERENCES PERSON (ID) ON DELETE CASCADE
    --FK Kriminální operace je řešená tabulkou dole
);

CREATE TABLE FAMILY (
    ID INT GENERATED AS IDENTITY NOT NULL PRIMARY KEY,
    DON_ID INT NOT NULL
);

CREATE TABLE OPERATION (
    OPERATION_NAME VARCHAR(50) NOT NULL PRIMARY KEY,
    OP_TYPE VARCHAR(100),
    OP_DATE_START DATE,
    OP_DATE_FINISH DATE,
    --FK Území je řešené tabulkou dole
    OWNING_FAMILY INT NOT NULL
);

--Generalizace/specializace je zde udělána pomocí FK OPERATION jakožto atributu MURDER, který odkazuje na OPERATION odpovídající dané MURDER. Tímto je dodržen vztah "is a" mezi MURDER a OPERATION.
CREATE TABLE MURDER (
    MURDER_NAME VARCHAR(50) NOT NULL PRIMARY KEY,
    --TIME_OF_MURDER DATE nepoužíváme nakonec
    MURDER_WEAPON VARCHAR(50),
    VICTIM INT NOT NULL,
    FOREIGN KEY (MURDER_NAME) REFERENCES OPERATION (OPERATION_NAME) ON DELETE CASCADE
);

CREATE TABLE ORDER_TABLE (
    ID INT GENERATED AS IDENTITY NOT NULL PRIMARY KEY,
    ORDER_NAME VARCHAR(50),
    VICTIM INT,
    MURDER VARCHAR(50)
);

CREATE TABLE DON (
    ID INT GENERATED AS IDENTITY NOT NULL PRIMARY KEY,
    NAME VARCHAR(100),
    AGE NUMBER(3),
    SHOE_SIZE NUMBER(3),
    MURDER_ORDER INT DEFAULT NULL
);

CREATE TABLE MEETING (
    ID INT GENERATED AS IDENTITY NOT NULL PRIMARY KEY,
    MEET_DATE DATE,
    --FK Účastníci jsou vyřešeni tabulkou dole
    TERRITORY_ID VARCHAR(100) NOT NULL
);

CREATE TABLE TERRITORY (
    GPS VARCHAR(100) NOT NULL PRIMARY KEY CHECK (REGEXP_LIKE(GPS, '^([1-8]?[1-9]|[1-9]0)\.{1}\d{1,6}[NS],\s?((([1]?[0-7]?|[1-9]?)[0-9])|([1]?[1-8][0])|([1]?[1-7][1-9])|([1]?[0-8][0])|([1-9]0))\.{1}\d{1,6}[EW]$')),
    AREA DECIMAL(10, 5),
    --ADRESS VARCHAR(50) redundantní
    OWNING_FAMILY INT
);

CREATE TABLE ALIANCE (
    ID INT GENERATED AS IDENTITY NOT NULL PRIMARY KEY
    --FK Rodiny jsou řešené tabulkou dole
    --FK Kriminální operace je řešená tabulkou dole'
);

--=================================== Propojovací tabulky =========================================

CREATE TABLE MEETING_ATTENDEE (
    MEETING_ID INT,
    DON_ID INT NOT NULL,
    PRIMARY KEY (MEETING_ID, DON_ID),
    CONSTRAINT MEETING_FK FOREIGN KEY (MEETING_ID) REFERENCES MEETING (ID) ON DELETE CASCADE,
    CONSTRAINT DON_FK FOREIGN KEY (DON_ID) REFERENCES DON (ID) ON DELETE CASCADE
);

CREATE TABLE MEMBER_OPERATION (
    MEMBER_ID INT,
    OPERATION_NAME VARCHAR(50) NOT NULL,
    PRIMARY KEY (MEMBER_ID, OPERATION_NAME),
    CONSTRAINT MEMBER_FK FOREIGN KEY (MEMBER_ID) REFERENCES MEMBER_TABLE (ID) ON DELETE CASCADE,
    CONSTRAINT OPERATION_FK FOREIGN KEY (OPERATION_NAME) REFERENCES OPERATION (OPERATION_NAME) ON DELETE CASCADE
);

CREATE TABLE ALIANCE_OPERATION (
    ALIANCE_ID INT,
    OPERATION_NAME VARCHAR(50) NOT NULL,
    PRIMARY KEY (ALIANCE_ID, OPERATION_NAME),
    CONSTRAINT ALIANCE_FK FOREIGN KEY (ALIANCE_ID) REFERENCES ALIANCE (ID) ON DELETE CASCADE,
    CONSTRAINT OPERATION_FK_ALI_OP FOREIGN KEY (OPERATION_NAME) REFERENCES OPERATION (OPERATION_NAME) ON DELETE CASCADE
);

CREATE TABLE ALIANCE_FAMILY (
    ALIANCE_ID INT,
    FAMILY_ID INT NOT NULL,
    PRIMARY KEY (ALIANCE_ID, FAMILY_ID),
    CONSTRAINT ALIANCE_FK_ALI_FAM FOREIGN KEY (ALIANCE_ID) REFERENCES ALIANCE (ID) ON DELETE CASCADE,
    CONSTRAINT FAMILY_FK FOREIGN KEY (FAMILY_ID) REFERENCES FAMILY (ID) ON DELETE CASCADE
);

CREATE TABLE OPERATION_TERRITORY (
    OPERATION_NAME VARCHAR(50) NOT NULL,
    TERRITORY_ID VARCHAR(100) NOT NULL,
    PRIMARY KEY (OPERATION_NAME, TERRITORY_ID),
    CONSTRAINT OPERATION_FK_OP_TER FOREIGN KEY (OPERATION_NAME) REFERENCES OPERATION (OPERATION_NAME) ON DELETE CASCADE,
    CONSTRAINT TERRITORY_FK FOREIGN KEY (TERRITORY_ID) REFERENCES TERRITORY (GPS) ON DELETE CASCADE
);

--=================================== ALTER TABLE =========================================

ALTER TABLE MEMBER_TABLE ADD CONSTRAINT FAMILY_FK_MEM_TAB FOREIGN KEY (FAMILY_ID) REFERENCES FAMILY (ID) ON DELETE CASCADE;

ALTER TABLE FAMILY ADD CONSTRAINT DON_FK_FAM FOREIGN KEY (DON_ID) REFERENCES DON (ID) ON DELETE CASCADE;

ALTER TABLE OPERATION ADD CONSTRAINT OWNING_FAMILY_FK_OP FOREIGN KEY (OWNING_FAMILY) REFERENCES FAMILY (ID) ON DELETE CASCADE;

ALTER TABLE MURDER ADD CONSTRAINT VICTIM_FK FOREIGN KEY (VICTIM) REFERENCES PERSON (ID) ON DELETE CASCADE;

ALTER TABLE ORDER_TABLE ADD CONSTRAINT VICTIM_FK_ORD_TAB FOREIGN KEY (VICTIM) REFERENCES PERSON (ID) ON DELETE CASCADE
ADD CONSTRAINT MURDER_FK FOREIGN KEY (MURDER) REFERENCES MURDER (MURDER_NAME) ON DELETE SET NULL;

ALTER TABLE DON ADD CONSTRAINT MURDER_ORDER_FK FOREIGN KEY (MURDER_ORDER) REFERENCES ORDER_TABLE (ID) ON DELETE SET NULL;

ALTER TABLE MEETING ADD CONSTRAINT TERRITORY_FK_MEET FOREIGN KEY (TERRITORY_ID) REFERENCES TERRITORY (GPS) ON DELETE CASCADE;

ALTER TABLE TERRITORY ADD CONSTRAINT OWNING_FAMILY_FK_TER FOREIGN KEY (OWNING_FAMILY) REFERENCES FAMILY (ID) ON DELETE SET NULL;

--=================================== NAPLNIT DATY =========================================

INSERT INTO PERSON (
    NAME,
    AGE
) VALUES (
    'Mr. GonnaDie :koteseni:',
    50
);

INSERT INTO PERSON (
    NAME,
    AGE
) VALUES (
    'Mr. Member',
    40
);

INSERT INTO DON (
    NAME,
    AGE,
    SHOE_SIZE
) VALUES (
    'Velkej Boss',
    45,
    48
);

INSERT INTO DON (
    NAME,
    AGE,
    SHOE_SIZE
) VALUES (
    'Velkej Meeting Boss',
    50,
    45
);

INSERT INTO ORDER_TABLE (
    ORDER_NAME,
    VICTIM
) VALUES (
    'Phoenix',
    1
);

INSERT INTO FAMILY(
    DON_ID
) VALUES (
    1
);

INSERT INTO MEMBER_TABLE(
    ID,
    AUTHORIZATION,
    SHOE_SIZE,
    FAMILY_ID
) VALUES(
    2,
    'Velkej čavo',
    42,
    1
);

INSERT INTO OPERATION(
    OPERATION_NAME,
    OP_TYPE,
    OP_DATE_START,
    OP_DATE_FINISH,
    OWNING_FAMILY
) VALUES(
    'Vaření pervitinu',
    'Narkotika',
    TO_DATE('2024-02-08', 'YYYY-MM-DD'),
    TO_DATE('2024-05-08', 'YYYY-MM-DD'),
    1
);

INSERT INTO OPERATION(
    OPERATION_NAME,
    OP_TYPE,
    OP_DATE_START,
    OP_DATE_FINISH,
    OWNING_FAMILY
) VALUES(
    'Vražda 123',
    'Vražda',
    TO_DATE('2024-05-08', 'YYYY-MM-DD'),
    TO_DATE('2024-06-08', 'YYYY-MM-DD'),
    1
);

INSERT INTO MURDER(
    MURDER_NAME,
    --Tady by měla být time_of_murder ale nepotřebujem ji, protože je v operation
    MURDER_WEAPON,
    VICTIM
) VALUES(
    'Vražda 123',
    'Nůž',
    1
);

INSERT INTO TERRITORY(
    GPS,
    AREA,
    OWNING_FAMILY
) VALUES(
    '50.149N, 40.5E',
    50.44,
    1
);

INSERT INTO MEETING(
    MEET_DATE,
    TERRITORY_ID
) VALUES (
    TO_DATE('2024-07-15', 'YYYY/MM/DD'),
    '50.149N, 40.5E'
);

INSERT INTO MEETING_ATTENDEE(
    MEETING_ID,
    DON_ID
) VALUES (
    1,
    1
);

INSERT INTO MEETING_ATTENDEE(
    MEETING_ID,
    DON_ID
) VALUES (
    1,
    2
);

INSERT INTO MEMBER_OPERATION(
    MEMBER_ID,
    OPERATION_NAME
) VALUES (
    2,
    'Vaření pervitinu'
);

INSERT INTO ALIANCE VALUES (
    DEFAULT
);

INSERT INTO ALIANCE_OPERATION(
    ALIANCE_ID,
    OPERATION_NAME
) VALUES (
    1,
    'Vaření pervitinu'
);

INSERT INTO ALIANCE_FAMILY(
    ALIANCE_ID,
    FAMILY_ID
) VALUES (
    1,
    1
);

INSERT INTO OPERATION_TERRITORY(
    OPERATION_NAME,
    TERRITORY_ID
) VALUES (
    'Vražda 123',
    '50.149N, 40.5E'
);