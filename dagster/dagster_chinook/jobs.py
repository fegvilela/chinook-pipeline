from dagster import job

from dagster_chinook import assets

@job
def dbt_pipeline_job():
    """Pipeline completo de transformação de dados com dbt"""
    seed_result = assets.run_dbt_seed()
    run_result = assets.run_dbt_run(seed_result)
    test_result = assets.run_dbt_test(run_result)
    assets.run_dbt_docs(test_result)
