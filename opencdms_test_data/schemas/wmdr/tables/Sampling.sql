/* ---------------------------------------------------- */
/*  Generated by Enterprise Architect Version 15.2 		*/
/*  Created On : 04-May-2022 21:43:57 				*/
/*  DBMS       : PostgreSQL 						*/
/* ---------------------------------------------------- */

/* Drop Tables */

DROP TABLE IF EXISTS "Sampling" CASCADE
;

/* Create Tables */

CREATE TABLE "Sampling"
(
	"Sampling" varchar NULL,
	"SamplingID" varchar NOT NULL
)
;

/* Create Primary Keys, Indexes, Uniques, Checks */

ALTER TABLE "Sampling" ADD CONSTRAINT "PK_Sampling"
	PRIMARY KEY ("SamplingID")
;