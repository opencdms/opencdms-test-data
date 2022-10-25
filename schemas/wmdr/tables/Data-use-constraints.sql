/* ---------------------------------------------------- */
/*  Generated by Enterprise Architect Version 15.2 		*/
/*  Created On : 04-May-2022 21:43:55 				*/
/*  DBMS       : PostgreSQL 						*/
/* ---------------------------------------------------- */

/* Drop Tables */

DROP TABLE IF EXISTS "Data-use-constraints" CASCADE
;

/* Create Tables */

CREATE TABLE "Data-use-constraints"
(
	"Data-use-constraintsID" varchar NOT NULL
)
;

/* Create Primary Keys, Indexes, Uniques, Checks */

ALTER TABLE "Data-use-constraints" ADD CONSTRAINT "PK_Data-use-constraints"
	PRIMARY KEY ("Data-use-constraintsID")
;

/* Create Table Comments, Sequences for Autonumber Columns */

COMMENT ON TABLE "Data-use-constraints"
	IS 'The value for dataUseConstraints, if supplied, shall be taken from the code table published online at http://codes.wmo.int/common/wmdr/DataPolicy.


This codelist is also described in the WIGOS Metadata Standard, Chapter VII.'
;