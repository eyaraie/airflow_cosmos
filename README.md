# Airflow + DBT on Kubernetes

## 📌 Overview
This project sets up **Apache Airflow** and **DBT** (Data Build Tool) on a **Kubernetes** cluster using **k3d** and manages DAGs for data ingestion and transformation with **PostgreSQL** as the local database.

## 📁 Architecture

### 1️⃣ **Infrastructure**
- **Kubernetes (k3d)**: Lightweight Kubernetes setup for local development.
- **PostgreSQL**: Local database for storing raw and transformed data.
- **Airflow**: Orchestrates ingestion and transformation DAGs.
- **DBT**: Handles SQL-based data transformation within DAGs.

### 2️⃣ **Data Pipeline**
- **All-in-One DAG** (`basic_cosmos_dag`): Combines ingestion + transformation in a single workflow.
![2025-02-17 14 56 03](https://github.com/user-attachments/assets/ccc5a146-5438-4b1c-be18-37e20f9dd610)

## 🚀 Installation & Setup

### **1. Prerequisites**
Ensure you have installed:
- [Docker](https://www.docker.com/get-started)
- [k3d (Kubernetes in Docker)](https://k3d.io/)
- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- [Helm](https://helm.sh/docs/intro/install/)

### **2. Clone the Repository**
```sh
git clone https://github.com/your-repo/airflow-dbt-k8s.git
cd airflow-dbt-k8s
```

### **3. Deploy the Environment**
Run the following commands using `make`:

#### **Create Kubernetes Cluster & Deploy Components**
```sh
make deploy
```
- Creates a **k3d cluster**
- Deploys **Airflow + DBT** to Kubernetes
- Sets up **PostgreSQL**

#### **Port Forward Airflow UI**
```sh
make port-forward
```
- Access Airflow UI at: [http://localhost:4444](http://localhost:4444)

#### **Check Kubernetes Pod Status**
```sh
make status
```
- Ensures all services are running.

#### **Check Airflow Logs**
```sh
make logs
```
- Debugs DAG execution.

## 🎯 Running Data Pipelines

### **1️⃣ Start Airflow & Run DAGs**
```sh
make start-airflow
```
- Unpauses DAGs
- Reserializes DAGs
- Starts the **Airflow Scheduler**

#### **Manually Trigger DAG Execution**
```sh
make trigger-dag
```
- Runs `basic_cosmos_dag` (Ingestion + Transformation).



## 📊 Data & Transformation

### **1️⃣ Data Ingestion**
- Uses **DBT seed files** (`.csv`) to populate PostgreSQL.
- `dbt_seed_dag` loads raw data into tables like `raw_orders`, `raw_customers`, etc.

### **2️⃣ Data Transformation**
- `dbt_transform_dag` runs **DBT models** to:
  - Normalize customer/order data.
  - Aggregate revenue insights.
  - Create a clean analytical layer.

## 🔥 Destroy the Environment
```sh
make destroy
```
- Deletes Kubernetes cluster & all resources.

---
### 🚀 **Happy Data Engineering!** 🎯

