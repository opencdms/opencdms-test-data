import os
import django
import pytest
import random
from django.conf import settings
from django.core.management import execute_from_command_line
import opencdms.models.djangodemo as djangodemo

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
DB_URL = os.path.join(BASE_DIR, "djangodemo.db")

station_data = dict(
    stationid=str(random.randint(1000, 2000)),
    stationname='Test Station',
    country='France'
)


def setup_module(module):
    try:
        settings.configure(
            DATABASES={
                "default": {
                    "ENGINE": "django.db.backends.sqlite3",
                    "NAME": DB_URL,
                }
            },
            DEFAULT_AUTO_FIELD="django.db.models.AutoField",
            BASE_DIR=BASE_DIR,
            INSTALLED_APPS=(
                "opencdms.models.djangodemo",
                "django.contrib.auth",
                "django.contrib.contenttypes"
            )
        )
    except RuntimeError:
        pass

    django.setup()

    execute_from_command_line([
        os.path.abspath(__file__),
        "makemigrations",
        "djangodemo"
    ])
    execute_from_command_line([
        os.path.abspath(__file__),
        "migrate"
    ])


def teardown_module(module):
    os.remove(DB_URL)


@pytest.mark.order(1)
def test_should_create_a_station():
    station = djangodemo.models.Station(**station_data)
    station.save()

    assert station.stationid == station_data['stationid']


@pytest.mark.order(2)
def test_should_read_all_stations():
    stations = djangodemo.models.Station.objects.all()

    for station in stations:
        assert isinstance(station, djangodemo.models.Station)


@pytest.mark.order(3)
def test_should_return_a_single_station():
    station = djangodemo.models.Station.objects.get(stationid=station_data['stationid'])

    assert station.stationid == station_data['stationid']


@pytest.mark.order(4)
def test_should_update_station():
    station = djangodemo.models.Station.objects.get(stationid=station_data['stationid'])
    station.country = 'Italy'
    station.save()

    assert station.country == 'Italy'


@pytest.mark.order(5)
def test_should_delete_station():
    station = djangodemo.models.Station.objects.get(stationid=station_data['stationid'])
    station.delete()

    with pytest.raises(djangodemo.metadata.Station.DoesNotExist):
        djangodemo.models.Station.objects.get(stationid=station_data['stationid'])



