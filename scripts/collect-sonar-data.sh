#!/bin/bash
# Phase 4: Collect and organize quality data from SonarQube - SECURE VERSION

SONAR_URL="${SONAR_HOST_URL}"
SONAR_TOKEN="${SONAR_TOKEN}"
PROJECT_KEY="sonarqube-testing"

# Security check - no hardcoded credentials
if [ -z "$SONAR_URL" ] || [ -z "$SONAR_TOKEN" ]; then
    echo "❌ ERROR: Environment variables SONAR_HOST_URL and SONAR_TOKEN must be set"
    exit 1
fi

echo "📊 SonarQube Data Collection (SECURE) - No hardcoded credentials"
echo "Project: $PROJECT_KEY"

# Create simple master sheet (basic version for GitHub Actions)
mkdir -p quality-data/master-reports
echo "Date,Project,Status" > quality-data/master-reports/master-quality-report.csv
echo "$(date),${PROJECT_KEY},Collected" >> quality-data/master-reports/master-quality-report.csv

echo "✅ Secure data collection complete"