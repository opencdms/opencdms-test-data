/* ---------------------------------------------------- */
/*  Generated by Enterprise Architect Version 15.2 		*/
/*  Created On : 04-May-2022 21:43:55 				*/
/*  DBMS       : PostgreSQL 						*/
/* ---------------------------------------------------- */

/* Drop Tables */

DROP TABLE IF EXISTS "Datapolicy" CASCADE
;

/* Create Tables */

CREATE TABLE "Datapolicy"
(
	"Attribution" varchar NULL,	-- Describes the attribution details pertinent to dataPolicy
	"Datapolicy" varchar NULL,	-- 9-02 Details relating to the use and limitations surrounding data imposed by the supervising organization.
	"DatapolicyID" varchar NOT NULL
)
;

/* Create Primary Keys, Indexes, Uniques, Checks */

ALTER TABLE "Datapolicy" ADD CONSTRAINT "PK_Datapolicy"
	PRIMARY KEY ("DatapolicyID")
;

/* Create Table Comments, Sequences for Autonumber Columns */

COMMENT ON COLUMN "Datapolicy"."Attribution"
	IS 'Describes the attribution details pertinent to dataPolicy'
;

COMMENT ON COLUMN "Datapolicy"."Datapolicy"
	IS '9-02 Details relating to the use and limitations surrounding data imposed by the supervising organization.'
;