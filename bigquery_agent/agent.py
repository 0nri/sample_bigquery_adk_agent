"""Sample BigQuery ADK Agent."""

import os

from google.adk.agents import LlmAgent
from google.adk.tools.bigquery import BigQueryToolset
from google.adk.tools.bigquery.config import BigQueryToolConfig

from .prompts import get_bigquery_instructions

# Configure BigQuery toolset
bigquery_config = BigQueryToolConfig(
    compute_project_id=os.getenv("GOOGLE_CLOUD_PROJECT"),
)

# Instantiate the BigQuery toolset with configuration
bigquery_toolset = BigQueryToolset(bigquery_tool_config=bigquery_config)

# Define the minimal BigQuery agent
root_agent = LlmAgent(
    model=os.getenv("BIGQUERY_AGENT_MODEL", "gemini-2.5-flash"),
    name="sample_bigquery_adk_agent",
    instruction=get_bigquery_instructions(),
    tools=[
        bigquery_toolset,
    ],
)
