/* ---------------------------------------------------- */
/*  Generated by Enterprise Architect Version 15.2 		*/
/*  Created On : 04-May-2022 21:43:56 				*/
/*  DBMS       : PostgreSQL 						*/
/* ---------------------------------------------------- */

/* Drop Tables */

DROP TABLE IF EXISTS "Log" CASCADE
;

/* Create Tables */

CREATE TABLE "Log"
(
	"Logentry" varchar NULL,	-- An entry in a Log. 
	"LogID" varchar NOT NULL
)
;

/* Create Primary Keys, Indexes, Uniques, Checks */

ALTER TABLE "Log" ADD CONSTRAINT "PK_Log"
	PRIMARY KEY ("LogID")
;

/* Create Table Comments, Sequences for Autonumber Columns */

COMMENT ON TABLE "Log"
	IS 'At the abstract level a log is simply a record of log entries. The requirements for a log may depend on the type of log it is therefore specialized logs exist for specific types of log (such as ControlCheckReports, MaintenanceReports and EventReports).'
;

COMMENT ON COLUMN "Log"."Logentry"
	IS 'An entry in a Log. '
;