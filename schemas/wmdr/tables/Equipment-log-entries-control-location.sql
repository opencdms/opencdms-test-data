/* ---------------------------------------------------- */
/*  Generated by Enterprise Architect Version 15.2 		*/
/*  Created On : 04-May-2022 21:43:56 				*/
/*  DBMS       : PostgreSQL 						*/
/* ---------------------------------------------------- */

/* Drop Tables */

DROP TABLE IF EXISTS "Equipment-log-entries-control-location" CASCADE
;

/* Create Tables */

CREATE TABLE "Equipment-log-entries-control-location"
(
	"Equipment-log-entries-control-locationID" varchar NOT NULL
)
;

/* Create Primary Keys, Indexes, Uniques, Checks */

ALTER TABLE "Equipment-log-entries-control-location" ADD CONSTRAINT "PK_Equipment-log-entries-control-location"
	PRIMARY KEY ("Equipment-log-entries-control-locationID")
;

/* Create Table Comments, Sequences for Autonumber Columns */

COMMENT ON TABLE "Equipment-log-entries-control-location"
	IS 'Where a log entry is a ControlCheckReport, the value of checkLocation shall be taken from the code table published online at http://codes.wmo.int/common/wmdr/ControlLocation. '
;