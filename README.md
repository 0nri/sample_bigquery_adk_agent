# Sample BigQuery ADK Agent

This project provides a minimal, runnable sample application built with Agent Development Kit (ADK) that integrates with Google BigQuery.

The agent is designed to be simple and demonstrate the most basic BigQuery integration using ADK's built-in BigQuery toolset.  It also contains a sample script to deploy onto Cloud Run.

## Project Structure

```
sample_bigquery_adk_agent/
├── bigquery_agent/          # Agent package directory
│   ├── __init__.py
│   ├── agent.py             # Main agent code with root_agent definition
│   └── prompts.py           # Agent instructions and prompts
├── data/
│   └── sample_sales.csv     # Sample data for BigQuery
├── main.py                  # FastAPI application entry point
├── requirements.txt         # Python dependencies
├── Dockerfile               # Container build instructions
├── deploy_cloudrun.sh       # Cloud Run deployment script
├── .env.example             # Environment variable template
└── .env                     # Your environment configuration (create from .env.example)
```

## Prerequisites

- Python 3.9+
- Access to a Google Cloud Project with BigQuery enabled
- `gcloud` CLI installed and authenticated (`gcloud auth application-default login`)
- **Service Account for Cloud Run** (Not needed for running locally):
  - Create a service account with the following roles:
    - `Vertex AI User` - To access Gemini models
    - `BigQuery Data Viewer` - To query BigQuery datasets
    - `BigQuery Job User` - To run BigQuery jobs

## Setup

1.  **Install dependencies:**
    It is recommended to use a virtual environment.
    ```bash
    python -m venv .venv
    source .venv/bin/activate
    pip install -r requirements.txt
    ```

3.  **Set up BigQuery:**
    - Create a new dataset in your BigQuery project. Let's call it `adk_sample`.
    - Create a table named `sales` within the `adk_sample` dataset. You can use the following SQL command in the BigQuery console, after uploading the `sample_sales.csv` file.

    *(The `sample_sales.csv` and a setup script will be provided in this directory).*

## Configuration

This application uses a `.env` file for configuration. Create a `.env` file by copying the provided template:

```bash
cp .env.example .env
```

Then, edit the `.env` file and replace the placeholder values with your actual Google Cloud project details.

## Running the Agent Locally

You can run the agent using either the ADK web interface or the command-line interface.

### Option 1: ADK Web Interface

1.  **Ensure your `.env` file is configured.**

2.  **Run the ADK web interface:**
    From the project root directory, execute:
    ```bash
    adk web
    ```

3.  **Interact with the agent:**
    - Open your browser to the URL provided (usually `http://127.0.0.1:8000`).
    - Select the `bigquery_agent` from the dropdown menu.
    - Ask questions like:
        - `What is the total quantity of laptops sold?`

### Option 2: ADK Command-Line Interface

Run the agent in interactive CLI mode:
```bash
adk run bigquery_agent
```

### Option 3: FastAPI Development Server

Run the FastAPI application directly:
```bash
python main.py
```
Then access the web interface at `http://localhost:8080`.

## Example Questions

Once your agent is running, try these sample questions based on the included sales data:

- "What is the total revenue from all sales?"
- "Which product sold the most units?"
- "Show me sales from January 18, 2025"
- "Calculate total sales by product"
- "What is the average price of laptops?"

## Deploying to Cloud Run

The included `deploy_cloudrun.sh` script provides a flexible way to deploy the agent to Google Cloud Run, supporting both local execution and CI/CD pipelines.

### Configuration Precedence

The script uses the following order of precedence to determine configuration values:
1.  **Command-Line Flags:** (e.g., `--project <id>`) - Highest priority.
2.  **`.env` File:** Values defined in the local `.env` file.
3.  **System Environment Variables:** (e.g., `$GOOGLE_CLOUD_PROJECT`) - Lowest priority, ideal for CI/CD.

### Local Deployment

1.  **Authenticate with Google Cloud:**
    ```bash
    gcloud auth login
    gcloud auth application-default login
    ```

2.  **Ensure your `.env` file is configured** with your project details. The script uses the following variables from this file:
    -   `GOOGLE_CLOUD_PROJECT`
    -   `BQ_DATASET_ID`
    -   `CLOUD_RUN_REGION`
    -   `CLOUD_RUN_SERVICE_NAME`
    -   `CLOUD_RUN_SERVICE_ACCOUNT` - Service account email for Cloud Run
    -   `CLOUD_RUN_MEMORY`
    -   `CLOUD_RUN_CPU`
    -   `CLOUD_RUN_TIMEOUT`
    -   `CLOUD_RUN_MAX_INSTANCES`

3.  **Run the deployment script:**
    Make sure you are in the `sample_bigquery_adk_agent` directory and the script is executable (`chmod +x deploy_cloudrun.sh`).
    ```bash
    ./deploy_cloudrun.sh
    ```
    You can override any setting from the `.env` file by using command-line flags:
    ```bash
    ./deploy_cloudrun.sh --region us-east1 --service-name my-bq-agent --memory 2Gi --cpu 2
    ```

### CI/CD Deployment

In a CI/CD environment (like GitLab or GitHub Actions), you should not use a `.env` file. Instead, configure the required values as environment variables in your pipeline's settings. The script will automatically use them.

-   `GOOGLE_CLOUD_PROJECT`
-   `BQ_DATASET_ID`
-   `CLOUD_RUN_REGION`
-   `CLOUD_RUN_SERVICE_NAME`
-   `CLOUD_RUN_SERVICE_ACCOUNT` - Service account for Cloud Run
-   `CLOUD_RUN_MEMORY` (optional, defaults to `1Gi`)
-   `CLOUD_RUN_CPU` (optional, defaults to `1`)
-   `CLOUD_RUN_TIMEOUT` (optional, defaults to `300`)
-   `CLOUD_RUN_MAX_INSTANCES` (optional, defaults to `2`)

The `deploy_cloudrun.sh` script will automatically pick up these environment variables.
