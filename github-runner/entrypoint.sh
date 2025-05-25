#!/bin/bash

# GitHub Actions Self-Hosted Runner Entrypoint Script

set -e

# Validate required environment variables
if [[ -z "$GITHUB_TOKEN" ]]; then
    echo "Error: GITHUB_TOKEN environment variable is required"
    exit 1
fi

if [[ -z "$GITHUB_OWNER" ]] && [[ -z "$GITHUB_REPOSITORY" ]]; then
    echo "Error: Either GITHUB_OWNER or GITHUB_REPOSITORY environment variable is required"
    exit 1
fi

# Set default values
RUNNER_NAME=${RUNNER_NAME:-"docker-runner-$(hostname)"}
RUNNER_LABELS=${RUNNER_LABELS:-"docker,ubuntu,self-hosted"}

# Configure the runner
if [[ -n "$GITHUB_REPOSITORY" ]]; then
    # Repository-level runner
    RUNNER_URL="https://github.com/${GITHUB_REPOSITORY}"
    echo "Configuring repository-level runner for ${GITHUB_REPOSITORY}"
else
    # Organization-level runner
    RUNNER_URL="https://github.com/${GITHUB_OWNER}"
    echo "Configuring organization-level runner for ${GITHUB_OWNER}"
fi

echo "Runner name: ${RUNNER_NAME}"
echo "Runner labels: ${RUNNER_LABELS}"

# Get registration token
if [[ -n "$GITHUB_REPOSITORY" ]]; then
    # Repository token
    REGISTRATION_TOKEN=$(curl -s -X POST \
        -H "Authorization: token ${GITHUB_TOKEN}" \
        -H "Accept: application/vnd.github.v3+json" \
        "https://api.github.com/repos/${GITHUB_REPOSITORY}/actions/runners/registration-token" | jq -r .token)
else
    # Organization token
    REGISTRATION_TOKEN=$(curl -s -X POST \
        -H "Authorization: token ${GITHUB_TOKEN}" \
        -H "Accept: application/vnd.github.v3+json" \
        "https://api.github.com/orgs/${GITHUB_OWNER}/actions/runners/registration-token" | jq -r .token)
fi

if [[ "$REGISTRATION_TOKEN" == "null" ]] || [[ -z "$REGISTRATION_TOKEN" ]]; then
    echo "Error: Failed to get registration token. Check your GitHub token permissions."
    exit 1
fi

# Configure the runner
./config.sh \
    --url "$RUNNER_URL" \
    --token "$REGISTRATION_TOKEN" \
    --name "$RUNNER_NAME" \
    --labels "$RUNNER_LABELS" \
    --work "_work" \
    --unattended \
    --replace

# Cleanup function
cleanup() {
    echo "Removing runner..."
    if [[ -n "$GITHUB_REPOSITORY" ]]; then
        # Repository removal token
        REMOVAL_TOKEN=$(curl -s -X POST \
            -H "Authorization: token ${GITHUB_TOKEN}" \
            -H "Accept: application/vnd.github.v3+json" \
            "https://api.github.com/repos/${GITHUB_REPOSITORY}/actions/runners/remove-token" | jq -r .token)
    else
        # Organization removal token
        REMOVAL_TOKEN=$(curl -s -X POST \
            -H "Authorization: token ${GITHUB_TOKEN}" \
            -H "Accept: application/vnd.github.v3+json" \
            "https://api.github.com/orgs/${GITHUB_OWNER}/actions/runners/remove-token" | jq -r .token)
    fi
    
    if [[ "$REMOVAL_TOKEN" != "null" ]] && [[ -n "$REMOVAL_TOKEN" ]]; then
        ./config.sh remove --token "$REMOVAL_TOKEN"
    fi
}

# Set up signal handlers
trap 'cleanup; exit 130' INT
trap 'cleanup; exit 143' TERM

# Start the runner
echo "Starting GitHub Actions runner..."
./run.sh &

# Wait for the runner process
wait $!
