/* ---------------------------------------------------- */
/*  Generated by Enterprise Architect Version 15.2 		*/
/*  Created On : 04-May-2022 21:43:57 				*/
/*  DBMS       : PostgreSQL 						*/
/* ---------------------------------------------------- */

/* Drop Tables */

DROP TABLE IF EXISTS "Reportingstatustype" CASCADE
;

/* Create Tables */

CREATE TABLE "Reportingstatustype"
(
	"ReportingstatustypeID" varchar NOT NULL
)
;

/* Create Primary Keys, Indexes, Uniques, Checks */

ALTER TABLE "Reportingstatustype" ADD CONSTRAINT "PK_Reportingstatustype"
	PRIMARY KEY ("ReportingstatustypeID")
;

/* Create Table Comments, Sequences for Autonumber Columns */

COMMENT ON TABLE "Reportingstatustype"
	IS 'Station reporting status'
;