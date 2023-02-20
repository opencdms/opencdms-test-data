#!/usr/bin/env python
from setuptools import setup, find_packages

with open("requirements.txt") as requirements_file:
    requirements = requirements_file.readlines()

setup(
    name='opencdms_test_data',
    version='0.1.0',
    description='OpenCDMS test data as package.',
    entry_points={
        "console_scripts": [
            "opencdms-test-data=cli:main",
        ],
    },
    install_requires=requirements,
    author='OpenCDMS',
    author_email='info@opencdms.org',
    url='https://github.com/opencdms/opencdms-test-data',
    packages=find_packages(),
    include_package_data=True,
    zip_safe=False,
    package_data={'': ["*.csv"]}
)

