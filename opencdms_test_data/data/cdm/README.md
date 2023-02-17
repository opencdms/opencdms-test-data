Data have been extracted and transformed from the Environment and Climate Change Canada GeoMet-OGC-API service.

Data source: Environment and Climate Change Canada

Data sets:
- https://api.weather.gc.ca/collections/climate-stations
- https://api.weather.gc.ca/collections/climate-hourly

License: https://eccc-msc.github.io/open-data/licence/readme_en/

Data can be imported using the following (using psql)

```bash
cd ./code_tables
psql -U opencdms -d opencdms << !
\COPY cdm.observation_type FROM 'observation_type.csv' WITH CSV HEADER DELIMITER AS '|' NULL AS 'NA' QUOTE E'\b';
\COPY cdm.observed_property FROM 'observed_property.csv' WITH CSV HEADER DELIMITER AS '|' NULL AS 'NA' QUOTE E'\b';
\COPY cdm.observing_procedure FROM 'observing_procedure.csv' WITH CSV HEADER DELIMITER AS '|' NULL AS 'NA' QUOTE E'\b';
\COPY cdm.users FROM 'users.csv' WITH CSV HEADER DELIMITER AS '|' NULL AS 'NA' QUOTE E'\b';
\COPY cdm.record_status FROM 'status.csv' WITH CSV HEADER DELIMITER AS '|' NULL AS 'NA' QUOTE E'\b';
\COPY cdm.source_type FROM 'source_type.csv' WITH CSV HEADER DELIMITER AS '|' NULL AS 'NA' QUOTE E'\b';
\COPY cdm.source FROM 'source.csv' WITH CSV HEADER DELIMITER AS '|' NULL AS 'NA' QUOTE E'\b';
!
cd ../ECCC_hourly_climate
psql -U opencdms -d opencdms << !
\COPY cdm.hosts FROM 'hosts.csv' WITH CSV HEADER DELIMITER AS '|' NULL AS 'NA' QUOTE E'\b';
\COPY cdm.observations FROM 'CA_6016527_1990.csv' WITH CSV HEADER DELIMITER AS '|' NULL AS 'NA' QUOTE E'\b';
\COPY cdm.observations FROM 'CA_6016527_1991.csv' WITH CSV HEADER DELIMITER AS '|' NULL AS 'NA' QUOTE E'\b';
\COPY cdm.observations FROM 'CA_6016527_1992.csv' WITH CSV HEADER DELIMITER AS '|' NULL AS 'NA' QUOTE E'\b';
\COPY cdm.observations FROM 'CA_6016527_1993.csv' WITH CSV HEADER DELIMITER AS '|' NULL AS 'NA' QUOTE E'\b';
\COPY cdm.observations FROM 'CA_6016527_1994.csv' WITH CSV HEADER DELIMITER AS '|' NULL AS 'NA' QUOTE E'\b';
\COPY cdm.observations FROM 'CA_6016527_1995.csv' WITH CSV HEADER DELIMITER AS '|' NULL AS 'NA' QUOTE E'\b';
\COPY cdm.observations FROM 'CA_6016527_1996.csv' WITH CSV HEADER DELIMITER AS '|' NULL AS 'NA' QUOTE E'\b';
\COPY cdm.observations FROM 'CA_6016527_1997.csv' WITH CSV HEADER DELIMITER AS '|' NULL AS 'NA' QUOTE E'\b';
\COPY cdm.observations FROM 'CA_6016527_1998.csv' WITH CSV HEADER DELIMITER AS '|' NULL AS 'NA' QUOTE E'\b';
\COPY cdm.observations FROM 'CA_6016527_1999.csv' WITH CSV HEADER DELIMITER AS '|' NULL AS 'NA' QUOTE E'\b';
\COPY cdm.observations FROM 'CA_6016527_2000.csv' WITH CSV HEADER DELIMITER AS '|' NULL AS 'NA' QUOTE E'\b';
\COPY cdm.observations FROM 'CA_6016527_2001.csv' WITH CSV HEADER DELIMITER AS '|' NULL AS 'NA' QUOTE E'\b';
\COPY cdm.observations FROM 'CA_6016527_2002.csv' WITH CSV HEADER DELIMITER AS '|' NULL AS 'NA' QUOTE E'\b';
\COPY cdm.observations FROM 'CA_6016527_2003.csv' WITH CSV HEADER DELIMITER AS '|' NULL AS 'NA' QUOTE E'\b';
\COPY cdm.observations FROM 'CA_6016527_2004.csv' WITH CSV HEADER DELIMITER AS '|' NULL AS 'NA' QUOTE E'\b';
\COPY cdm.observations FROM 'CA_6016527_2005.csv' WITH CSV HEADER DELIMITER AS '|' NULL AS 'NA' QUOTE E'\b';
\COPY cdm.observations FROM 'CA_6016527_2006.csv' WITH CSV HEADER DELIMITER AS '|' NULL AS 'NA' QUOTE E'\b';
\COPY cdm.observations FROM 'CA_6016527_2007.csv' WITH CSV HEADER DELIMITER AS '|' NULL AS 'NA' QUOTE E'\b';
\COPY cdm.observations FROM 'CA_6016527_2008.csv' WITH CSV HEADER DELIMITER AS '|' NULL AS 'NA' QUOTE E'\b';
\COPY cdm.observations FROM 'CA_6016527_2009.csv' WITH CSV HEADER DELIMITER AS '|' NULL AS 'NA' QUOTE E'\b';
\COPY cdm.observations FROM 'CA_6016527_2010.csv' WITH CSV HEADER DELIMITER AS '|' NULL AS 'NA' QUOTE E'\b';
\COPY cdm.observations FROM 'CA_6016527_2011.csv' WITH CSV HEADER DELIMITER AS '|' NULL AS 'NA' QUOTE E'\b';
\COPY cdm.observations FROM 'CA_6016527_2012.csv' WITH CSV HEADER DELIMITER AS '|' NULL AS 'NA' QUOTE E'\b';
!
```

etc.