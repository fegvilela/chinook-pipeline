# from dagster import Definitions, load_assets_from_modules,DbtCliResource

# from .jobs import dbt_pipeline_job
# from .project import chinook_analytics_project

# from . import assets

# all_assets = load_assets_from_modules([assets])



# defs = Definitions(
#     assets=all_assets,
#     jobs=[dbt_pipeline_job],
#     resources={
#         "dbt": DbtCliResource(project_dir=chinook_analytics_project),
#     },
# )
