from setuptools import setup, find_packages


setup(
    name='opencdms_test_data',
    version='0.1.0',
    description='OpenCDMS test data as package.',
    author='OpenCDMS',
    author_email='info@opencdms.org',
    url='https://github.com/opencdms/opencdms-test-data',
    packages=find_packages(include=["opencdms_test_data"]),
    include_package_data=True,
    data_files=[
        ("data", [
            "data/badc/ukmo-midas-open/data/uk-daily-rain-obs/dataset-version-201908/berkshire/00838_bracknell-beaufort-park/qc-version-1/midas-open_uk-daily-rain-obs_dv-201908_berkshire_00838_bracknell-beaufort-park_qcv-1_1991.csv",
            "data/badc/ukmo-midas-open/data/uk-daily-temperature-obs/dataset-version-201908/berkshire/00838_bracknell-beaufort-park/qc-version-1/midas-open_uk-daily-temperature-obs_dv-201908_berkshire_00838_bracknell-beaufort-park_qcv-1_1991.csv",
            "data/badc/ukmo-midas-open/data/uk-daily-weather-obs/dataset-version-201908/berkshire/00838_bracknell-beaufort-park/qc-version-1/midas-open_uk-daily-weather-obs_dv-201908_berkshire_00838_bracknell-beaufort-park_qcv-1_1991.csv",
            "data/badc/ukmo-midas-open/data/uk-hourly-rain-obs/dataset-version-201908/berkshire/00838_bracknell-beaufort-park/qc-version-1/midas-open_uk-hourly-rain-obs_dv-201908_berkshire_00838_bracknell-beaufort-park_qcv-1_1991.csv",
            "data/badc/ukmo-midas-open/data/uk-hourly-weather-obs/dataset-version-201908/berkshire/00838_bracknell-beaufort-park/qc-version-1/midas-open_uk-hourly-weather-obs_dv-201908_berkshire_00838_bracknell-beaufort-park_qcv-1_1991.csv",
            "data/badc/ukmo-midas-open/data/uk-mean-wind-obs/dataset-version-201908/berkshire/00838_bracknell-beaufort-park/qc-version-1/midas-open_uk-mean-wind-obs_dv-201908_berkshire_00838_bracknell-beaufort-park_qcv-1_1991.csv",
            "data/badc/ukmo-midas-open/data/uk-radiation-obs/dataset-version-201908/berkshire/00838_bracknell-beaufort-park/qc-version-1/midas-open_uk-radiation-obs_dv-201908_berkshire_00838_bracknell-beaufort-park_qcv-1_1991.csv",
            "data/badc/ukmo-midas-open/data/uk-soil-temperature-obs/dataset-version-201908/berkshire/00838_bracknell-beaufort-park/qc-version-1/midas-open_uk-soil-temperature-obs_dv-201908_berkshire_00838_bracknell-beaufort-park_qcv-1_1991.csv"
        ])
    ]
)
