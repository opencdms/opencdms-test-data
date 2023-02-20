/* ---------------------------------------------------- */
/*  Generated by Enterprise Architect Version 15.2 		*/
/*  Created On : 04-May-2022 21:43:57 				*/
/*  DBMS       : PostgreSQL 						*/
/* ---------------------------------------------------- */

/* Drop Tables */

DROP TABLE IF EXISTS "Samplingproceduretype" CASCADE
;

/* Create Tables */

CREATE TABLE "Samplingproceduretype"
(
	"SamplingproceduretypeID" varchar NOT NULL
)
;

/* Create Primary Keys, Indexes, Uniques, Checks */

ALTER TABLE "Samplingproceduretype" ADD CONSTRAINT "PK_Samplingproceduretype"
	PRIMARY KEY ("SamplingproceduretypeID")
;

/* Create Table Comments, Sequences for Autonumber Columns */

COMMENT ON TABLE "Samplingproceduretype"
	IS 'Sampling Procedure codelist'
;