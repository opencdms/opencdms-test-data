## OpenCDMS test data

This repository contains data and information for testing OpenCDMS and supported systems.

There are three ways to test OpenCDMS with a database:
1. Testing with original database technologies ([complex](#testing-with-original-database-technologies))

    This involves installing a database system like MariaDB, MySQL, Oracle or PostgreSQL and installing the CDMSs original database schema (see SQL DDL files in the `schemas` directory).
    
2. Testing with a single database technology ([standard](#testing-with-a-single-database-technology))

    The `pyopencdms` library allows developers to initialise data models for any of the supported systems in any of the supported database systems (allowing developers to install and use a single database system). Using a different underlying database technology will most likely prevent you from using SQL to perform operations like restore commands, but otherwise interaction can be achieved through the `pyopencmds` Python API.

3. Testing with SQLlite / SpatialLite ([easy](#testing-with-sqllite--spatiallite))

    The final option does not require you to install any database system and instead uses the lightweight SQLite option. By default, when automated unit tests run a temporary in-memory SQLite database is used. Developers do not need to install any database software.


### Data sets

See individual directories with the `data` directory for data license information.
