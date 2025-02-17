FROM --platform=linux/amd64 apache/airflow:2.10.4

USER root

# Install OpenJDK 17
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
  openjdk-17-jre-headless \
  && apt-get autoremove -yqq --purge \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Set Java Home
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64

# Copy DAGs with proper ownership
COPY --chown=airflow:root dags/ /opt/airflow/dags
# Copy the DAGs into Airflow DAGs folder
COPY dags/ /opt/airflow/dags/

# Copy the DBT project inside Airflow
COPY dbt/jaffle-shop/ /opt/airflow/dbt/jaffle-shop/
# Switch to airflow user
USER airflow

# Install dependencies (Remove --user flag)
COPY requirements.txt /
RUN pip install --no-cache-dir "apache-airflow==2.10.4" -r /requirements.txt
