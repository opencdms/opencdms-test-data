import os
import pandas
import pytest
import datetime
from opencdms import MidasOpen


BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DB_URL = os.path.join(BASE_DIR, "data")


@pytest.fixture
def session():
    return MidasOpen(connection_string=DB_URL)


def test_should_return_hourly_wind_obs(session):
    filters = {
        'src_id': 838,
        'period': 'hourly',
        'year': 1991,
        'elements': ['wind_speed', 'wind_direction'],
    }

    obs = session.obs(**filters)

    assert isinstance(obs, pandas.DataFrame)

    assert (
        datetime.datetime.strptime(
            obs.iloc[1]["ob_time"], '%Y-%m-%d %H:%M:%S'
        )
        -
        datetime.datetime.strptime(
            obs.iloc[0]["ob_time"], '%Y-%m-%d %H:%M:%S'
        )
    ).seconds == 3600

