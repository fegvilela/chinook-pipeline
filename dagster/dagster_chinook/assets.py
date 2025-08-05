# from dagster import AssetExecutionContext, op
# from dagster_dbt import DbtCliResource, dbt_assets

# from .project import chinook_analytics_project


# @dbt_assets(manifest=chinook_analytics_project.manifest_path)
# def chinook_analytics_dbt_assets(context: AssetExecutionContext, dbt: DbtCliResource):
#     yield from dbt.cli(["build"], context=context).stream()


# @op
# def run_dbt_seed(context: AssetExecutionContext, dbt: DbtCliResource):
#     dbt.cli(["seed", "--select", "invoices_csv"], context=context).wait()

# @op
# def run_dbt_test(context: AssetExecutionContext, dbt: DbtCliResource):
#     dbt.cli(["test", "--select", "invoices_csv"], context=context).wait()


from dagster import op, OpExecutionContext
from dagster_dbt import DbtCliResource

# 1. Definindo as operações (ops) para cada comando dbt
@op
def run_dbt_seed(context: OpExecutionContext, dbt: DbtCliResource):
    """Carrega dados iniciais via dbt seed"""
    context.log.info("Iniciando carga de dados via dbt seed...")
    dbt.cli(["seed", "--select", "invoices_csv"], context=context).wait()
    context.log.info("Carga de dados concluída com sucesso!")
    return {"status": "seed_completed"}

@op
def run_dbt_run(context: OpExecutionContext, dbt: DbtCliResource, upstream_result: dict):
    """Executa os modelos dbt"""
    context.log.info(f"Status anterior: {upstream_result['status']}")
    context.log.info("Iniciando execução dos modelos dbt...")
    dbt.cli(["run", "--select", "stg_+"], context=context).wait()
    context.log.info("Modelos executados com sucesso!")
    return {"status": "run_completed"}

@op
def run_dbt_test(context: OpExecutionContext, dbt: DbtCliResource, upstream_result: dict):
    """Executa testes nos modelos"""
    context.log.info(f"Status anterior: {upstream_result['status']}")
    context.log.info("Iniciando testes dos modelos...")
    dbt.cli(["test", "--select", "stg_+"], context=context).wait()
    context.log.info("Testes concluídos com sucesso!")
    return {"status": "test_completed"}

@op
def run_dbt_docs(context: OpExecutionContext, dbt: DbtCliResource, upstream_result: dict):
    """Gera documentação"""
    context.log.info(f"Status anterior: {upstream_result['status']}")
    context.log.info("Gerando documentação...")
    dbt.cli(["docs", "generate"], context=context).wait()
    context.log.info("Documentação gerada com sucesso!")
    return {"status": "docs_generated"}

# 2. Criando o job que orquestra a sequência
