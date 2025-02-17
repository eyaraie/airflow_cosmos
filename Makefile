.PHONY: cluster create build load-image deploy destroy logs status port-forward dbt-connection copy-files

K3D_CLUSTER_NAME=the-dbt-on-k8s
K8S_NAMESPACE=the-airflow
AIRFLOW_IMAGE=airflow-dbt:local

# Create Kubernetes Cluster
cluster:
	@echo "🚀 Creating Kubernetes cluster: $(K3D_CLUSTER_NAME)..."
	k3d cluster create $(K3D_CLUSTER_NAME) --servers 1 --agents 2 --port "8080:8080@loadbalancer"
	@echo "✅ Kubernetes cluster created!"

#  Create Namespace
create:
	@echo "📂 Creating Kubernetes namespace: $(K8S_NAMESPACE)..."
	kubectl create namespace $(K8S_NAMESPACE) || echo "Namespace already exists!"
	@echo "✅ Namespace $(K8S_NAMESPACE) is ready!"

#  Build Airflow Image
build:
	@echo "🐳 Building Airflow Docker image..."
	docker build -t $(AIRFLOW_IMAGE) .
	@echo "✅ Airflow Docker image built: $(AIRFLOW_IMAGE)"

#  Load Image into k3d
load-image: build
	@echo "📦 Loading image into k3d cluster: $(K3D_CLUSTER_NAME)..."
	k3d image import $(AIRFLOW_IMAGE) -c $(K3D_CLUSTER_NAME)
	@echo "✅ Image loaded into k3d!"

#  Deploy Airflow & DBT
deploy: cluster create load-image
	@echo "🚀 Deploying Airflow & DBT to $(K8S_NAMESPACE)..."
	kubectl apply -f postgres-dbt.yaml -n $(K8S_NAMESPACE)
	kubectl apply -f airflow.yaml -n $(K8S_NAMESPACE)
	@echo "✅ Deployment complete!"


#  Destroy Everything
destroy:
	@echo "🔥 Deleting Kubernetes resources in $(K8S_NAMESPACE)..."
	kubectl delete -f airflow.yaml -n $(K8S_NAMESPACE)
	kubectl delete -f postgres-dbt.yaml -n $(K8S_NAMESPACE)
	k3d cluster delete $(K3D_CLUSTER_NAME)
	@echo "✅ Cluster and all resources deleted!"

#  View Logs
logs:
	@echo "📜 Fetching logs from Airflow..."
	kubectl logs -l app=airflow -n $(K8S_NAMESPACE) --tail=100 -f || echo "❌ Airflow logs not available. Check pod status!"

# 9️ Get Kubernetes Status
status:
	@echo "📌 Checking pod status..."
	kubectl get pods -n $(K8S_NAMESPACE)

#  Port Forward for UI
port-forward:
	@echo "🌍 Forwarding Airflow UI to http://localhost:4444..."
	kubectl port-forward svc/airflow 4444:8080 -n $(K8S_NAMESPACE) || echo "❌ Port-forward failed. Ensure Airflow pod is running!"

#  Set Airflow Connection for DBT
dbt-connection:
	@echo "🔄 Migrating Airflow database..."
	kubectl exec -it deployment/airflow -n $(K8S_NAMESPACE) -- airflow db migrate
	@echo "✅ Airflow database migrated!"

	@echo "🔗 Adding Airflow connection for DBT Postgres..."
	kubectl exec -it deployment/airflow -n $(K8S_NAMESPACE) -- airflow connections add 'dbt_postgres' \
		--conn-type 'postgres' \
		--conn-host 'postgres-dbt' \
		--conn-schema 'jaffle_shop' \
		--conn-login 'dbt' \
		--conn-password 'dbt' \
		--conn-port '5432' \
		--conn-extra '{"dbname": "jaffle_shop", "schema": "public"}'
	@echo "✅ Airflow connection for DBT Postgres added!"
# Start Airflow DAG
start-airflow:
	kubectl exec -it deployment/airflow -n the-airflow -- airflow dags unpause dbt_workflow_dag
	kubectl exec -it deployment/airflow -n the-airflow -- airflow dags reserialize
	kubectl exec -it deployment/airflow -n the-airflow -- airflow scheduler

# Run the DAG manually for testing
trigger-dag:
	kubectl exec -it deployment/airflow -n the-airflow -- airflow dags trigger basic_cosmos_dag

# Check logs for debugging
logs:
	kubectl logs deployment/airflow -n the-airflow --tail=100 -f


# Validate Airflow DAGs before deploying
validate-dags:
	kubectl exec -it deployment/airflow -n the-airflow -- airflow dags list-import-errors
# Run DBT Tests
test-dbt:

	kubectl exec -it deployment/airflow -n the-airflow -- dbt test --project-dir /opt/airflow/dbt/jaffle-shop --profiles-dir /opt/airflow/dbt/jaffle-shop --target dev

test: validate-dags test-dbt
