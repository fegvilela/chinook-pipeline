from dagster import Definitions
from dagster_dbt import DbtCliResource
from dagster_chinook import jobs
from dagster_chinook import project

# from .schedules import schedules

defs = Definitions(
    jobs=[jobs.dbt_pipeline_job],
    resources={
        "dbt": DbtCliResource(project_dir=project.chinook_analytics_project),
    },
)

