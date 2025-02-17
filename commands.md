k3d cluster delete the-dbt-on-k8s
k3d cluster list
kubectl get namespaces


kubectl exec -it deployment/airflow -n the-airflow -- python /opt/airflow/dags/task.py

kubectl exec -it deployment/airflow -n the-airflow -- ls -lah /opt/airflow/dbt/jaffle-shop/
kubectl exec -it deployment/airflow -n the-airflow -- airflow dags list 
kubectl exec -it deployment/airflow -n the-airflow -- airflow dags unpause basic_cosmos_dag

kubectl exec -it deployment/airflow -n the-airflow -- airflow dags reserialize
kubectl exec -it deployment/airflow -n the-airflow -- airflow scheduler