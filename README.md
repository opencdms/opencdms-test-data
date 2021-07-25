## OpenCDMS test data

This repository contains data and information for testing OpenCDMS and supported systems.

There are three ways to test OpenCDMS with a database:
1. Testing with original database technologies ([complex](#testing-with-original-database-technologies))

    This involves installing a database system like PostgreSQL or MySQL. Information is provided below for installing these systems using Docker.
    
2. Testing with a single database technology ([standard](#testing-with-a-single-database-technology))

    The pyopencdms library is capable of recreating each CDMS data model in any of the supported database systems (allowing developers to install and use a single database system like TimescaleDB).

3. Testing with SQLlite / SpatialLite ([easy](#testing-with-sqllite--spatiallite))

    The final option does not require you to install any database system and instead uses the lightweight SQLite option.

### Data sets

See individual directories for data license information.

### Testing with original database technologies

For local development and testing, original database systems can be ran using docker containers.

| CDMS               | Database    | Database image | Description |
|--------------------|-------------|----------------|-------------|
| OpenCDMS RI / WMDR | TimescaleDB | `docker pull timescale/timescaledb-postgis:latest-pg13` | [overview](https://github.com/timescale/timescaledb-docker) |
| CliDE              | PostgreSQL  | `docker pull postgres:13`                               | [overview](https://hub.docker.com/_/postgres) |
| Climsoft 4         | MySQL 8     | `docker pull mysql:8`                                   | [overview](https://hub.docker.com/_/mysql)) |
| MCH                | MySQL 5.1   | `docker pull opencdms/mysql:5.1.73`                     | [overview](https://github.com/opencdms/mysql-5.1.73) |
| MIDAS              | Oracle      | `docker pull opencdms/oracle:18.4.0-xe`                 | [overview](https://github.com/oracle/docker-images/tree/main/OracleDatabase/SingleInstance) |

Note: Docker hub has the official mysql repository (debian) and an additional mysql-server reposority "Created, maintained and supported by the MySQL team at Oracle" (on Oracle Linux/RedHat)[⬞](https://stackoverflow.com/questions/44854843/docker-is-there-any-difference-between-the-two-mysql-docker-images).

| Database    | Running a container |
|-------------|---------------------|
| TimescaleDB | `docker run --name timescaledb -p 5432:5430 -e POSTGRES_PASSWORD=admin -d timescale/timescaledb-postgis:latest-pg12` |
| PostgreSQL  | `docker run --name oracle-xe -p 1521:1521 -e ORACLE_PWD=admin opencdms/oracle:18.4.0-xe` |
| MySQL 8     | `docker run --name mysql51 -p 3307:3306 -e MYSQL_ROOT_PASSWORD=admin -d opencdms/mysql:5.1.73` |
| MySQL 5.1   | `docker run --name postgres -p 5432:5432 -e POSTGRES_PASSWORD=admin -d postgres:13` |
| Oracle      | `docker run --name mysql -p 3306:3306 -e MYSQL_ROOT_PASSWORD=admin -d mysql:8` |

Nuke option: `docker rm local-mysql`

Running commands within a container (example resets Oracle XE password):
```
docker exec -it oracle-xe bash
./setPassword.sh admin
su oracle
sqlplus  # system / admin
```

### Testing with a single database technology

The `pyopencdms` library allows developers to initialise data models for any of the supported systems in any of the supported database systems (allowing developers to install and use a single database system). Using a different underlying database technology will most likely prevent you from using SQL to perform operations like restore commands, but otherwise interaction can be achieved through the `pyopencmds` Python API.

### Testing with SQLlite / SpatialLite

When automated unit tests run, a temporary in-memory SQLite database is used. Developers do not need to install any database software.
