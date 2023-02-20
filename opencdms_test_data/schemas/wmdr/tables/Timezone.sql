/* ---------------------------------------------------- */
/*  Generated by Enterprise Architect Version 15.2 		*/
/*  Created On : 04-May-2022 21:43:58 				*/
/*  DBMS       : PostgreSQL 						*/
/* ---------------------------------------------------- */

/* Drop Tables */

DROP TABLE IF EXISTS "Timezone" CASCADE
;

/* Create Tables */

CREATE TABLE "Timezone"
(
	"Timezone" varchar NULL,	-- Time zone of the observing facility
	"Validperiod" varchar NULL,	-- The time period for which the specified climateZone is known to be valid. Normally, this will be specified as a "from" date, implying that the validity extends but does not include the next climateZone on record. If only one climateZone is specified for an observing facility, the time stamp is optional.
	"TimezoneID" varchar NOT NULL
)
;

/* Create Primary Keys, Indexes, Uniques, Checks */

ALTER TABLE "Timezone" ADD CONSTRAINT "PK_Timezone"
	PRIMARY KEY ("TimezoneID")
;

/* Create Table Comments, Sequences for Autonumber Columns */

COMMENT ON TABLE "Timezone"
	IS 'A TmeZone is a timeZone specification accompanied by a timestamp indicating the time from which that timeZone is considered to be valid. If known, an end time may also be provided. In WIGOS, an ObservingFacility may carry multiple timeZone specifications which are valid over different consecutive periods of time. If only a single timeZone is specified, the timestamp is optional.'
;

COMMENT ON COLUMN "Timezone"."Timezone"
	IS 'Time zone of the observing facility'
;

COMMENT ON COLUMN "Timezone"."Validperiod"
	IS 'The time period for which the specified climateZone is known to be valid. Normally, this will be specified as a "from" date, implying that the validity extends but does not include the next climateZone on record. If only one climateZone is specified for an observing facility, the time stamp is optional.'
;