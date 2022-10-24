import uuid
import random
import pytest
from sqlalchemy import create_engine
from sqlalchemy.sql import text as sa_text
from sqlalchemy.orm import sessionmaker
from opencdms.models import surface
from config import get_surface_connection_string

DB_URL = get_surface_connection_string()

db_engine = create_engine(DB_URL)

station_data = {
    "id": 999999,
    "created_at": "2015-01-21T17:01:29.000Z",
    "updated_at": "2022-07-08T15:38:16.894Z",
    "name": "PGIA",
    "alias_name": "PGIA CR1000",
    "begin_date": "2014-10-01T00:00:00.000Z",
    "end_date": None,
    "longitude": -88.3127,
    "latitude": 17.5348,
    "elevation": 5.0,
    "code": "9958303",
    "wmo": None,
    "wigos": None,
    "is_active": True,
    "is_automatic": True,
    "organization": None,
    "observer": None,
    "watershed": "Belize River",
    "z": None,
    "datum": None,
    "zone": None,
    "ground_water_province": None,
    "river_code": None,
    "river_course": None,
    "catchment_area_station": None,
    "river_origin": None,
    "easting": None,
    "northing": None,
    "river_outlet": None,
    "river_length": None,
    "local_land_use": None,
    "soil_type": None,
    "site_description": None,
    "land_surface_elevation": None,
    "screen_length": None,
    "top_casing_land_surface": None,
    "depth_midpoint": None,
    "screen_size": None,
    "casing_type": None,
    "casing_diameter": None,
    "existing_gauges": None,
    "flow_direction_at_station": None,
    "flow_direction_above_station": None,
    "flow_direction_below_station": None,
    "bank_full_stage": None,
    "bridge_level": None,
    "access_point": None,
    "temporary_benchmark": None,
    "mean_sea_level": None,
    "data_type": None,
    "frequency_observation": None,
    "historic_events": None,
    "other_information": None,
    "hydrology_station_type": None,
    "is_surface": False,
    "station_details": None,
    "remarks": "Belize",
    "region": "Belize",
    "utc_offset_minutes": -360,
    "alternative_names": None,
    "wmo_station_plataform": None,
    "operation_status": True,
    "communication_type_id": 4,
    "data_source_id": 1,
    "profile_id": 4,
    "wmo_program_id": None,
    "wmo_region_id": None,
    "wmo_station_type_id": None,
    "relocation_date": None,
    "network": None,
    "reference_station_id": None,
    "country_id": 18,
}

station_communication_data = {
    "id": 4,
    "created_at": "2019-11-27T18:29:46.352Z",
    "updated_at": "2019-11-29T20:54:28.776Z",
    "name": "RF",
    "description": "RF Link",
    "color": "#01A27F",
}

data_source_data = {
    "id": 1,
    "created_at": "2019-01-09T13:58:55.345Z",
    "updated_at": "2019-04-26T20:31:52.335Z",
    "symbol": "NMS",
    "name": "NMS",
    "base_url": "http:\/\/www.hydromet.gov.bz",
    "location": None,
}

station_profile_data = {
    "id": 4,
    "created_at": "2016-04-01T01:58:36.000Z",
    "updated_at": "2020-05-22T22:39:27.835Z",
    "name": "Aviation",
    "description": "Weather station measuring parameters supporting aviation",
    "color": "#f9f008",
    "is_automatic": True,
    "is_manual": True,
}

country_data = {
    "id": 18,
    "created_at": "2015-01-21T17:01:28.000Z",
    "updated_at": "2022-04-13T15:24:34.390Z",
    "notation": "BLZ",
    "name": "Belize",
    "description": "Belize",
}


@pytest.fixture
def db_session():
    Session = sessionmaker(bind=db_engine)
    session = Session()
    yield session
    session.close()


def setup_module(module):
    # Postgresql does not automatically reset ID if a table is truncated like mysql does
    with db_engine.connect() as connection:
        with connection.begin():
            db_engine.execute(
                sa_text(
                    f"""TRUNCATE TABLE {surface.WxCountry.__tablename__} RESTART IDENTITY CASCADE"""
                ).execution_options(autocommit=True)
            )
            db_engine.execute(
                sa_text(
                    f"""TRUNCATE TABLE {surface.WxStationprofile.__tablename__} RESTART IDENTITY CASCADE"""
                ).execution_options(autocommit=True)
            )
            db_engine.execute(
                sa_text(
                    f"""TRUNCATE TABLE {surface.WxDatasource.__tablename__} RESTART IDENTITY CASCADE"""
                ).execution_options(autocommit=True)
            )
            db_engine.execute(
                sa_text(
                    f"""TRUNCATE TABLE {surface.WxStationcommunication.__tablename__} RESTART IDENTITY CASCADE"""
                ).execution_options(autocommit=True)
            )
            db_engine.execute(
                sa_text(
                    f"""TRUNCATE TABLE {surface.WxStation.__tablename__} RESTART IDENTITY CASCADE"""
                ).execution_options(autocommit=True)
            )

    Session = sessionmaker(bind=db_engine)
    session = Session()

    session.add(surface.WxCountry(**country_data))
    session.add(surface.WxDatasource(**data_source_data))
    session.add(surface.WxStationcommunication(**station_communication_data))
    session.add(surface.WxStationprofile(**station_profile_data))

    session.commit()
    session.close()


def teardown_module(module):
    # Postgresql does not automatically reset ID if a table is truncated like mysql does
    with db_engine.connect() as connection:
        with connection.begin():
            db_engine.execute(
                sa_text(
                    f"""TRUNCATE TABLE {surface.WxCountry.__tablename__} RESTART IDENTITY CASCADE"""
                ).execution_options(autocommit=True)
            )
            db_engine.execute(
                sa_text(
                    f"""TRUNCATE TABLE {surface.WxStationprofile.__tablename__} RESTART IDENTITY CASCADE"""
                ).execution_options(autocommit=True)
            )
            db_engine.execute(
                sa_text(
                    f"""TRUNCATE TABLE {surface.WxDatasource.__tablename__} RESTART IDENTITY CASCADE"""
                ).execution_options(autocommit=True)
            )
            db_engine.execute(
                sa_text(
                    f"""TRUNCATE TABLE {surface.WxStationcommunication.__tablename__} RESTART IDENTITY CASCADE"""
                ).execution_options(autocommit=True)
            )
            db_engine.execute(
                sa_text(
                    f"""TRUNCATE TABLE {surface.WxStation.__tablename__} RESTART IDENTITY CASCADE"""
                ).execution_options(autocommit=True)
            )


@pytest.mark.order(500)
def test_should_create_a_station(db_session):
    station = surface.WxStation(**station_data)
    db_session.add(station)
    db_session.commit()

    assert station.id == station_data["id"]


@pytest.mark.order(501)
def test_should_read_all_stations(db_session):
    stations = db_session.query(surface.WxStation).all()

    for station in stations:
        assert isinstance(station, surface.WxStation)


@pytest.mark.order(502)
def test_should_return_a_single_station(db_session):
    station = db_session.query(surface.WxStation).get(station_data["id"])

    assert station.id == station_data["id"]


@pytest.mark.order(503)
def test_should_update_station(db_session):
    db_session.query(surface.WxStation).filter_by(id=station_data["id"]).update(
        {"region": "US"}
    )
    db_session.commit()

    updated_station = db_session.query(surface.WxStation).get(station_data["id"])

    assert updated_station.region == "US"


@pytest.mark.order(504)
def test_should_delete_station(db_session):
    db_session.query(surface.WxStation).filter_by(id=station_data["id"]).delete()
    db_session.commit()

    deleted_station = db_session.query(surface.WxStation).get(station_data["id"])

    assert deleted_station is None
