from pathlib import Path

from dagster_dbt import DbtProject

chinook_analytics_project = DbtProject(
    project_dir=Path(__file__).joinpath("..","..","..", "dbt", "chinook_analytics").resolve(),
    packaged_project_dir=Path(__file__).joinpath("..","..","dbt-project").resolve(),
)
chinook_analytics_project.prepare_if_dev()
