FROM opencdms/mysql:5.1.73

COPY ./schemas/mch/Create_MCH_English_basic_tables.sql /docker-entrypoint-initdb.d/1.sql

