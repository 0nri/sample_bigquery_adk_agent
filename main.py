"""
This file initializes a FastAPI application for the Sample BigQuery ADK Agent
with A2A (Agent-to-Agent) protocol support. This makes the agent deployable to
Cloud Run and accessible via Agentspace.
"""

import os

import uvicorn
from dotenv import load_dotenv
from google.adk.a2a.utils.agent_to_a2a import to_a2a

from bigquery_agent.agent import root_agent

# Load environment variables from .env file
load_dotenv()

# Create A2A-compatible FastAPI app
# This will:
# - Expose the agent via A2A protocol (handles POST requests)
# - Auto-generate agent card at /.well-known/agent-card.json
# - Enable Agentspace integration
app = to_a2a(root_agent, port=int(os.environ.get("PORT", 8080)))

if __name__ == "__main__":
    # Use the PORT environment variable for Cloud Run compatibility, default to 8080.
    uvicorn.run(app, host="0.0.0.0", port=int(os.environ.get("PORT", 8080)))
