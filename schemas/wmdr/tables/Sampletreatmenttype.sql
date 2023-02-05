/* ---------------------------------------------------- */
/*  Generated by Enterprise Architect Version 15.2 		*/
/*  Created On : 04-May-2022 21:43:57 				*/
/*  DBMS       : PostgreSQL 						*/
/* ---------------------------------------------------- */

/* Drop Tables */

DROP TABLE IF EXISTS "Sampletreatmenttype" CASCADE
;

/* Create Tables */

CREATE TABLE "Sampletreatmenttype"
(
	"SampletreatmenttypeID" varchar NOT NULL
)
;

/* Create Primary Keys, Indexes, Uniques, Checks */

ALTER TABLE "Sampletreatmenttype" ADD CONSTRAINT "PK_Sampletreatmenttype"
	PRIMARY KEY ("SampletreatmenttypeID")
;

/* Create Table Comments, Sequences for Autonumber Columns */

COMMENT ON TABLE "Sampletreatmenttype"
	IS 'Sample Treatment codelist'
;