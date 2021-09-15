import os
import uuid
import random
import pytest
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from opencdms.models import clide

DB_URL = "sqlite:///clide.db"

db_engine = create_engine(DB_URL)

station_data = dict(
    id=random.randint(1000, 2000),
    station_no=uuid.uuid4().hex[:15],
    status_id=random.randint(1, 5),
    time_zone=random.randint(1, 180),
    region='France'
)


@pytest.fixture
def db_session():
    Session = sessionmaker(bind=db_engine)
    session = Session()
    yield session
    session.close()


def setup_module(module):
    clide.Base.metadata.drop_all(db_engine)
    clide.Base.metadata.create_all(db_engine)


def teardown_module(module):
    clide.Base.metadata.drop_all(db_engine)


@pytest.mark.order(100)
def test_should_create_a_station(db_session):
    station = clide.Station(**station_data)
    db_session.add(station)
    db_session.commit()

    assert station.id == station_data['id']


@pytest.mark.order(101)
def test_should_read_all_stations(db_session):
    stations = db_session.query(clide.Station).all()

    for station in stations:
        assert isinstance(station, clide.Station)


@pytest.mark.order(102)
def test_should_return_a_single_station(db_session):
    station = db_session.query(clide.Station).get(station_data['id'])

    assert station.id == station_data['id']


@pytest.mark.order(103)
def test_should_update_station(db_session):
    db_session.query(clide.Station).get(station_data['id']).update(region='Italy')
    db_session.commit()

    updated_station = db_session.query(clide.Station).get(station_data['id'])

    assert updated_station.region == 'Italy'


@pytest.mark.order(104)
def test_should_delete_station(db_session):
    db_session.query(clide.Station).get(station_data['id']).delete()
    db_session.commit()

    deleted_station = db_session.query(clide.Station).get(station_data['id'])

    assert deleted_station is None


