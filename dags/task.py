"""
An example DAG that uses Cosmos to render a dbt project into an Airflow DAG.
"""


import os
from datetime import datetime
from pathlib import Path

from cosmos import DbtDag, ProfileConfig, ProjectConfig
from cosmos.profiles import PostgresUserPasswordProfileMapping
from airflow.hooks.base import BaseHook

# Get DB connection from Airflow
dbt_conn = BaseHook.get_connection("dbt_postgres")
DBT_ROOT_PATH = Path("/opt/airflow/dbt/jaffle-shop")  # ✅ Corrected path

profile_config = ProfileConfig(
    profile_name="default",
    target_name="dev",
    profile_mapping=PostgresUserPasswordProfileMapping(
        conn_id="dbt_postgres",
        profile_args={
            "schema": dbt_conn.schema if dbt_conn.schema else "public",
            "host": dbt_conn.host,
            "user": dbt_conn.login,
            "password": dbt_conn.password,
            "port": dbt_conn.port if dbt_conn.port else 5432,
            "dbname": dbt_conn.extra_dejson.get("dbname", "jaffle_shop"),
        },
    ),
)


basic_cosmos_dag = DbtDag(
    project_config=ProjectConfig(
        DBT_ROOT_PATH,
        seeds_relative_path="seeds",
    ),
    profile_config=profile_config,
    operator_args={
        "install_deps": True,
        "full_refresh": True,
    },
    schedule_interval="@daily",
    start_date=datetime(2025, 1, 2),
    catchup=False,
    dag_id="basic_cosmos_dag",
    default_args={"retries": 2},
)
