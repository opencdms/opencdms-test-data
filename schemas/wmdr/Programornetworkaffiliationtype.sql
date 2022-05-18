/* ---------------------------------------------------- */
/*  Generated by Enterprise Architect Version 15.2 		*/
/*  Created On : 04-May-2022 21:43:57 				*/
/*  DBMS       : PostgreSQL 						*/
/* ---------------------------------------------------- */

/* Drop Tables */

DROP TABLE IF EXISTS "Programornetworkaffiliationtype" CASCADE
;

/* Create Tables */

CREATE TABLE "Programornetworkaffiliationtype"
(
	"ProgramornetworkaffiliationtypeID" varchar NOT NULL
)
;

/* Create Primary Keys, Indexes, Uniques, Checks */

ALTER TABLE "Programornetworkaffiliationtype" ADD CONSTRAINT "PK_Programornetworkaffiliationtype"
	PRIMARY KEY ("ProgramornetworkaffiliationtypeID")
;

/* Create Table Comments, Sequences for Autonumber Columns */

COMMENT ON TABLE "Programornetworkaffiliationtype"
	IS 'Codelist of Programme or Network Affiliations'
;