import random

import pytest
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from opencdms.models.climsoft import v4_1_1_core as climsoft

DB_URL = "sqlite:///climsoft.db"

db_engine = create_engine(DB_URL)

station_data = dict(
    stationId=str(random.randint(1000, 2000)),
    stationName='Test Station',
    country='France'
)


@pytest.fixture
def db_session():
    Session = sessionmaker(bind=db_engine)
    session = Session()
    yield session
    session.close()


def setup_module(module):
    climsoft.Base.metadata.drop_all(db_engine)
    climsoft.Base.metadata.create_all(db_engine)


def teardown_module(module):
    climsoft.Base.metadata.drop_all(db_engine)


@pytest.mark.order(200)
def test_should_create_a_station(db_session):
    station = climsoft.Station(**station_data)
    db_session.add(station)
    db_session.commit()

    assert station.stationId == station_data['stationId']


@pytest.mark.order(201)
def test_should_read_all_stations(db_session):
    stations = db_session.query(climsoft.Station).all()

    for station in stations:
        assert isinstance(station, climsoft.Station)


@pytest.mark.order(202)
def test_should_return_a_single_station(db_session):
    station = db_session.query(climsoft.Station).get(station_data['stationId'])

    assert station.stationId == station_data['stationId']


@pytest.mark.order(203)
def test_should_update_station(db_session):
    db_session.query(climsoft.Station).get(station_data['stationId']).update(country='Italy')
    db_session.commit()

    updated_station = db_session.query(climsoft.Station).get(station_data['stationId'])

    assert updated_station.country == 'Italy'


@pytest.mark.order(204)
def test_should_delete_station(db_session):
    db_session.query(climsoft.Station).get(station_data['stationId']).delete()
    db_session.commit()

    deleted_station = db_session.query(climsoft.Station).get(station_data['stationId'])

    assert deleted_station is None


