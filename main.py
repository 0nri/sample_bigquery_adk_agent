"""
This file initializes a FastAPI application for the Sample BigQuery ADK Agent
using get_fast_api_app() from ADK. This makes the agent deployable to Cloud Run.
"""

import os
import uvicorn
from dotenv import load_dotenv
from fastapi import FastAPI
from google.adk.cli.fast_api import get_fast_api_app

# Load environment variables from .env file
load_dotenv()

# The directory containing this script is the root for agent discovery.
AGENT_DIR = os.path.dirname(os.path.abspath(__file__))

# Create the FastAPI app using the ADK helper.
# This will discover the 'sample_bigquery_adk_agent' agent package.
app: FastAPI = get_fast_api_app(
    agents_dir=AGENT_DIR,
    web=True  # Serve the ADK web UI as well
)

app.title = "Sample BigQuery ADK Agent"
app.description = "A sample ADK agent for BigQuery."

if __name__ == "__main__":
    # Use the PORT environment variable for Cloud Run compatibility, default to 8080.
    uvicorn.run(app, host="0.0.0.0", port=int(os.environ.get("PORT", 8080)))
