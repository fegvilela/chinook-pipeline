from dagster import AssetExecutionContext
from dagster_dbt import DbtCliResource, dbt_assets

from .project import chinook_analytics_project


@dbt_assets(manifest=chinook_analytics_project.manifest_path)
def chinook_analytics_dbt_assets(context: AssetExecutionContext, dbt: DbtCliResource):
    yield from dbt.cli(["build"], context=context).stream()
    