Data have been extracted and transformed from the Environment and Climate Change Canada GeoMet-OGC-API service.

Data source: Environment and Climate Change Canada

Data sets:
- https://api.weather.gc.ca/collections/climate-stations
- https://api.weather.gc.ca/collections/climate-hourly

License: https://eccc-msc.github.io/open-data/licence/readme_en/

Data can be imported using the following (using psql)

```bash
psql -U opencdms -d opencdms << !
\COPY cdm.observation_type FROM 'observation_type.csv' WITH CSV HEADER DELIMITER AS '|' NULL AS 'NA';
\COPY cdm.observed_property FROM 'observed_property.csv' WITH CSV HEADER DELIMITER AS '|' NULL AS 'NA';
\COPY cdm.observing_procedure FROM 'observing_procedure.csv' WITH CSV HEADER DELIMITER AS '|' NULL AS 'NA';
\COPY cdm.users FROM 'users.csv' WITH CSV HEADER DELIMITER AS '|' NULL AS 'NA';
\COPY cdm.record_status FROM 'status.csv' WITH CSV HEADER DELIMITER AS '|' NULL AS 'NA';
\COPY cdm.hosts FROM 'stations.csv' WITH CSV HEADER DELIMITER AS '|' NULL AS 'NA';
\COPY cdm.source FROM 'source.csv' WITH CSV HEADER DELIMITER AS '|' NULL AS 'NA';
\COPY cdm.observations FROM 'CA_6014353_1994.csv' WITH CSV HEADER DELIMITER AS '|' NULL AS 'NA';
!
```

etc.