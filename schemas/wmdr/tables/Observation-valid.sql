/* ---------------------------------------------------- */
/*  Generated by Enterprise Architect Version 15.2 		*/
/*  Created On : 04-May-2022 21:43:56 				*/
/*  DBMS       : PostgreSQL 						*/
/* ---------------------------------------------------- */

/* Drop Tables */

DROP TABLE IF EXISTS "Observation-valid" CASCADE
;

/* Create Tables */

CREATE TABLE "Observation-valid"
(
	"Observation-validID" varchar NOT NULL
)
;

/* Create Primary Keys, Indexes, Uniques, Checks */

ALTER TABLE "Observation-valid" ADD CONSTRAINT "PK_Observation-valid"
	PRIMARY KEY ("Observation-validID")
;

/* Create Table Comments, Sequences for Autonumber Columns */

COMMENT ON TABLE "Observation-valid"
	IS 'XML encodings of OM_Observation shall conform to the XML form for OM_Observation specified in ISO 19156 O&M XML schema. '
;