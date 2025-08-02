from dagster import Definitions
from dagster_dbt import DbtCliResource
from .assets import chinook_analytics_dbt_assets
from .project import chinook_analytics_project
from .schedules import schedules

defs = Definitions(
    assets=[chinook_analytics_dbt_assets],
    schedules=schedules,
    resources={
        "dbt": DbtCliResource(project_dir=chinook_analytics_project),
    },
)