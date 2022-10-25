/* ---------------------------------------------------- */
/*  Generated by Enterprise Architect Version 15.2 		*/
/*  Created On : 04-May-2022 21:43:56 				*/
/*  DBMS       : PostgreSQL 						*/
/* ---------------------------------------------------- */

/* Drop Tables */

DROP TABLE IF EXISTS "Facility-log-entries" CASCADE
;

/* Create Tables */

CREATE TABLE "Facility-log-entries"
(
	"Facility-log-entriesID" varchar NOT NULL
)
;

/* Create Primary Keys, Indexes, Uniques, Checks */

ALTER TABLE "Facility-log-entries" ADD CONSTRAINT "PK_Facility-log-entries"
	PRIMARY KEY ("Facility-log-entriesID")
;

/* Create Table Comments, Sequences for Autonumber Columns */

COMMENT ON TABLE "Facility-log-entries"
	IS 'Log entries in a FacilityLog shall describe events at the facility and shall conform to the XML form for EventReport in the WMDR XML Schema. '
;