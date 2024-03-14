--Naplnit daty
--Použít alespoň jeden CHECK
--Vysvětlit generalizaci (dělení)

CREATE TABLE "don" --Možná by měl dědit ze člena
(
    "id" INT GENERATED AS IDENTITY NOT NULL PRIMARY KEY,
    "age" TINYINT,
    "shoe_size" TINYINT,
    "murder_order" INT DEFAULT NULL,
    CONSTRAINT "murder_order_fk" FOREIGN KEY ("murder_order") REFERENCES "order" ("id") --on delete něco
);

CREATE TABLE "meeting"
(
    "id" INT GENERATED AS IDENTITY NOT NULL PRIMARY KEY,
    "date" DATE,
    --FK Účastníci jsou možná vyřešeni tabulkou dole
    "territory_id" VARCHAR(100) NOT NULL,
    CONSTRAINT "territory_fk" FOREIGN KEY ("territory_id") REFERENCES "territory" ("gps")--on delete něco
);

--Toto si nejsem jistý jak přesně funguje, celkově ty vlastnosti jsou tu dost iffy :koteseni:
CREATE TABLE "meeting_attendee"
(
    "meeting_id" INT,
    "don_id" INT NOT NULL,
    PRIMARY KEY ("meeting_id", "don_id"),
    CONSTRAINT "meeting_fk" FOREIGN KEY ("meeting_id") REFERENCES "meeting" ("id"),--on delete něco
    CONSTRAINT "don_fk" FOREIGN KEY ("don_id") REFERENCES "don" ("id")--on delete něco
);

CREATE TABLE "person"
(
    "id" INT GENERATED AS IDENTITY NOT NULL PRIMARY KEY,
    "name" VARCHAR(100),
    "age" TINYINT,
    "member_id" INT,
    CONSTRAINT "member_fk" FOREIGN KEY ("member_id") REFERENCES "member" ("id")--on delete něco (set null ?)
);

CREATE TABLE "territory"
(
    "gps" VARCHAR(100) NOT NULL PRIMARY KEY,  
    "area" DECIMAL(10, 5),
    "adress" VARCHAR(50),
    "owning_family" INT,
    CONSTRAINT "owning_family_fk" FOREIGN KEY ("owning_family") REFERENCES "family" ("id")--on delete něco
);

CREATE TABLE "family"
(
    "id" INT GENERATED AS IDENTITY NOT NULL PRIMARY KEY,
    "don_id" INT NOT NULL,
    CONSTRAINT "don_fk" FOREIGN KEY ("don_id") REFERENCES "don" ("id")--on delete něco
);

CREATE TABLE "member"
(
    "id" INT GENERATED AS IDENTITY NOT NULL PRIMARY KEY,
    "authorization" VARCHAR(100),
    "shoe_size" TINYINT, --Toto smazat, pokud don bude dědit z osoby
    "family_id" INT NOT NULL,
    CONSTRAINT "family_fk" FOREIGN KEY ("family_id") REFERENCES "family" ("id")--on delete něco
    --FK Kriminální operace je možná řešená tabulkou dole
);

--stejný problém jako u meeting_attendee
CREATE TABLE "member_operation"
(
    "member_id" INT,
    "operation_id" INT,
    PRIMARY KEY ("member_id", "operation_id"),
    CONSTRAINT "member_fk" FOREIGN KEY ("member_id") REFERENCES "member" ("id"),--on delete něco
    CONSTRAINT "operation_fk" FOREIGN KEY ("operation_id") REFERENCES "operation" ("id")--on delete něco
);

CREATE TABLE "aliance"
(
    "id" INT GENERATED AS IDENTITY NOT NULL PRIMARY KEY
    --FK Rodiny jsou možná řešené tabulkou dole
    --FK Kriminální operace je možná řešená tabulkou dole
);

--propojovací tabulka
CREATE TABLE "aliance_operation"
(
    "aliance_id" INT,
    "operation_id" INT,
    PRIMARY KEY ("aliance_id", "operation_id"),
    CONSTRAINT "aliance_fk" FOREIGN KEY ("aliance_id") REFERENCES "aliance" ("id"),--on delete něco
    CONSTRAINT "operation_fk" FOREIGN KEY ("operation_id") REFERENCES "operation" ("id")--on delete něco
);

--propojovací tabulka
CREATE TABLE "aliance_family"
(
    "aliance_id" INT,
    "family_id" INT NOT NULL,
    PRIMARY KEY ("aliance_id", "family_id"),
    CONSTRAINT "aliance_fk" FOREIGN KEY ("aliance_id") REFERENCES "aliance" ("id"),--on delete něco
    CONSTRAINT "family_fk" FOREIGN KEY ("family_id") REFERENCES "family" ("id")--on delete něco
);

CREATE TABLE "operation"
(
    "id" INT GENERATED AS IDENTITY NOT NULL PRIMARY KEY,
    "type" VARCHAR(100),
    "duration" DATE,
    --FK Území je možná řešené tabulkou dole
    "owning_family" INT NOT NULL,
    CONSTRAINT "owning_family_fk" FOREIGN KEY ("owning_family") REFERENCES "family" ("id"),--on delete něco
    "murder_id" VARCHAR(50),
    CONSTRAINT "murder_fk" FOREIGN KEY ("murder_id") REFERENCES "murder" ("operation_name")
);

--propojovací tabulka
CREATE TABLE "operation_territory"
(
    "operation_id" INT,
    "territory_id" VARCHAR(100) NOT NULL,
    PRIMARY KEY ("operation_id", "territory_id"),
    CONSTRAINT "operation_fk" FOREIGN KEY ("operation_id") REFERENCES "operation" ("id"),--on delete něco
    CONSTRAINT "territory_fk" FOREIGN KEY ("territory_id") REFERENCES "territory" ("gps")--on delete něco
); 

CREATE TABLE "murder"
(
    "operation_name" VARCHAR(50) NOT NULL PRIMARY KEY,
    "time_of_murder" DATE,
    "murder_weapon" VARCHAR(50),
    "victim" INT NOT NULL,
    CONSTRAINT "victim_fk" FOREIGN KEY ("victim") REFERENCES "person" ("id")
);

CREATE TABLE "order"
(
    "id" INT GENERATED AS IDENTITY NOT NULL PRIMARY KEY,
    "murder_name" VARCHAR(50),
    CONSTRAINT "murder_fk" FOREIGN KEY ("murder_name") REFERENCES "murder" ("operation_name")
);

--=================================== NAPLNIT DATY =========================================

--Něco jsem tu uvařil
INSERT INTO "person" ("name", "age")
VALUES ("Mr. GonnaDie :koteseni:", 50);

INSERT INTO "murder" ("operation_name", "time_of_murder", "murder_weapon", "victim")
VALUES ("Phoenix", TO_DATE("2024-12-12", "yyyy/mm/dd"), "Handgun", 1);

INSERT INTO "order" ("murder_name")
VALUES ("Phoenix");

INSERT INTO "don" ("age", "shoe_size", "murder_order")
VALUES (40, 45, NULL);
INSERT INTO "don" ("age", "shoe_size", "murder_order")
VALUES (51, 42, 1);
