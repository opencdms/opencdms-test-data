/* ---------------------------------------------------- */
/*  Generated by Enterprise Architect Version 15.2 		*/
/*  Created On : 04-May-2022 21:43:56 				*/
/*  DBMS       : PostgreSQL 						*/
/* ---------------------------------------------------- */

/* Drop Tables */

DROP TABLE IF EXISTS "Levelofdatatype" CASCADE
;

/* Create Tables */

CREATE TABLE "Levelofdatatype"
(
	"LevelofdatatypeID" varchar NOT NULL
)
;

/* Create Primary Keys, Indexes, Uniques, Checks */

ALTER TABLE "Levelofdatatype" ADD CONSTRAINT "PK_Levelofdatatype"
	PRIMARY KEY ("LevelofdatatypeID")
;

/* Create Table Comments, Sequences for Autonumber Columns */

COMMENT ON TABLE "Levelofdatatype"
	IS 'Level of data codelist'
;