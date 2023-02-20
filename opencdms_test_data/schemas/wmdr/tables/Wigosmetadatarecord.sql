/* ---------------------------------------------------- */
/*  Generated by Enterprise Architect Version 15.2 		*/
/*  Created On : 04-May-2022 21:43:58 				*/
/*  DBMS       : PostgreSQL 						*/
/* ---------------------------------------------------- */

/* Drop Tables */

DROP TABLE IF EXISTS "Wigosmetadatarecord" CASCADE
;

/* Create Tables */

CREATE TABLE "Wigosmetadatarecord"
(
	"Deployment" varchar NULL,	-- A Deployment instance in this record. Note that Deployments may also be encoded inline with the OM_Observation (as part of the Process).
	"Equipment" varchar NULL,	-- An Equipment instance in this metadata record.
	"Equipmentlog" varchar NULL,	-- An EquipmentLog instance in this metadata record. Note that an EquipmentLog may also be encoded inline with the Equipment instance.
	"Extension" varchar NULL,	-- This extension point is to facilitate the encoding of any other information for complimentary or local purposes such as complying with legislative frameworks. However it should not be expected that any extension information will be appropriately processed, stored or made retrievable from any WIGOS systems or services. 
	"Facility" varchar NULL,	-- An ObservingFacility instance in this metadata record.
	"Facilitylog" varchar NULL,	-- A FacilityLog instance in this metadata record. Note that an FacilityLog may also be encoded inline with the ObservingFacility instance.
	"Facilityset" varchar NULL,	-- A FacilitySet instance in this metadata record. The FacilitySet will simply consist of links to ObservingFacilities belonging to the set.
	"Headerinformation" varchar NULL,	-- A header section must be included with every WIGOS MetadataRecord.
	"Observation" varchar NULL,
	"WigosmetadatarecordID" varchar NOT NULL
)
;

/* Create Primary Keys, Indexes, Uniques, Checks */

ALTER TABLE "Wigosmetadatarecord" ADD CONSTRAINT "PK_Wigosmetadatarecord"
	PRIMARY KEY ("WigosmetadatarecordID")
;

/* Create Table Comments, Sequences for Autonumber Columns */

COMMENT ON TABLE "Wigosmetadatarecord"
	IS 'The WIGOSMetadataRecord is a container for WIGOS information for the purposes of packaging the information for delivery to, or transfer between, systems.'
;

COMMENT ON COLUMN "Wigosmetadatarecord"."Deployment"
	IS 'A Deployment instance in this record. Note that Deployments may also be encoded inline with the OM_Observation (as part of the Process).'
;

COMMENT ON COLUMN "Wigosmetadatarecord"."Equipment"
	IS 'An Equipment instance in this metadata record.'
;

COMMENT ON COLUMN "Wigosmetadatarecord"."Equipmentlog"
	IS 'An EquipmentLog instance in this metadata record. Note that an EquipmentLog may also be encoded inline with the Equipment instance.'
;

COMMENT ON COLUMN "Wigosmetadatarecord"."Extension"
	IS 'This extension point is to facilitate the encoding of any other information for complimentary or local purposes such as complying with legislative frameworks.
However it should not be expected that any extension information will be appropriately processed, stored or made retrievable from any WIGOS systems or services. '
;

COMMENT ON COLUMN "Wigosmetadatarecord"."Facility"
	IS 'An ObservingFacility instance in this metadata record.'
;

COMMENT ON COLUMN "Wigosmetadatarecord"."Facilitylog"
	IS 'A FacilityLog instance in this metadata record. Note that an FacilityLog may also be encoded inline with the ObservingFacility instance.'
;

COMMENT ON COLUMN "Wigosmetadatarecord"."Facilityset"
	IS 'A FacilitySet instance in this metadata record. The FacilitySet will simply consist of links to ObservingFacilities belonging to the set.'
;

COMMENT ON COLUMN "Wigosmetadatarecord"."Headerinformation"
	IS 'A header section must be included with every WIGOS MetadataRecord.'
;