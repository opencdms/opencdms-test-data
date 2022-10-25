/* ---------------------------------------------------- */
/*  Generated by Enterprise Architect Version 15.2 		*/
/*  Created On : 04-May-2022 21:43:55 				*/
/*  DBMS       : PostgreSQL 						*/
/* ---------------------------------------------------- */

/* Drop Tables */

DROP TABLE IF EXISTS "Equipmentlog" CASCADE
;

/* Create Tables */

CREATE TABLE "Equipmentlog"
(
	"EquipmentlogID" varchar NOT NULL,
	equipment varchar NULL
)
;

/* Create Primary Keys, Indexes, Uniques, Checks */

ALTER TABLE "Equipmentlog" ADD CONSTRAINT "PK_Equipmentlog"
	PRIMARY KEY ("EquipmentlogID")
;

/* Create Foreign Key Constraints */

ALTER TABLE "Equipmentlog" ADD CONSTRAINT "FK_EquipmentLog_equipmentLog"
	FOREIGN KEY (equipment) REFERENCES "Equipment" ("EquipmentID") ON DELETE No Action ON UPDATE No Action
;

ALTER TABLE "Equipmentlog" ADD CONSTRAINT "FK_EquipmentLog_Log"
	FOREIGN KEY ("EquipmentlogID") REFERENCES "Log" ("LogID") ON DELETE No Action ON UPDATE No Action
;

/* Create Table Comments, Sequences for Autonumber Columns */

COMMENT ON TABLE "Equipmentlog"
	IS '5-13 The EquipmentLog is used to capture notable events and extra information about the equipment used to obtain the observations, such as actual maintenance performed on the instrument.'
;