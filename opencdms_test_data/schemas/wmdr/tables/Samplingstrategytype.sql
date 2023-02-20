/* ---------------------------------------------------- */
/*  Generated by Enterprise Architect Version 15.2 		*/
/*  Created On : 04-May-2022 21:43:57 				*/
/*  DBMS       : PostgreSQL 						*/
/* ---------------------------------------------------- */

/* Drop Tables */

DROP TABLE IF EXISTS "Samplingstrategytype" CASCADE
;

/* Create Tables */

CREATE TABLE "Samplingstrategytype"
(
	"SamplingstrategytypeID" varchar NOT NULL
)
;

/* Create Primary Keys, Indexes, Uniques, Checks */

ALTER TABLE "Samplingstrategytype" ADD CONSTRAINT "PK_Samplingstrategytype"
	PRIMARY KEY ("SamplingstrategytypeID")
;

/* Create Table Comments, Sequences for Autonumber Columns */

COMMENT ON TABLE "Samplingstrategytype"
	IS 'Sampling Strategy codelist'
;