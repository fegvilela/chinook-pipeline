from setuptools import find_packages, setup

setup(
    name="dagster_chinook",
    version="0.0.1",
    packages=find_packages(),
    package_data={
        "dagster_chinook": [
            "dbt-project/**/*",
        ],
    },
    install_requires=[
        "dagster",
        "dagster-cloud",
        "dagster-dbt",
        "dbt-core<1.11",
        "dbt-postgres<1.11",
    ],
    extras_require={
        "dev": [
            "dagster-webserver",
        ]
    },
)