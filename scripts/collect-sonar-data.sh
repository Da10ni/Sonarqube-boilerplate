#!/bin/bash

# Phase 4: Collect and organize quality data from SonarQube
# Creates master sheet with all metrics

set -e

SONAR_URL="${SONAR_HOST_URL:-http://3.140.201.58:9000}"
SONAR_TOKEN="${SONAR_TOKEN:-sqp_0521d96305b1f799e03c4f931b27ecb0cd357d43}"
PROJECT_KEY="sonarqube-testing"
OUTPUT_DIR="quality-data/master-reports"

echo "📊 SonarQube Data Collection & Organization"
echo "==========================================="
echo "SonarQube URL: $SONAR_URL"
echo "Project: $PROJECT_KEY"
echo "Output: $OUTPUT_DIR"
echo ""

# Create output directory
mkdir -p "$OUTPUT_DIR"

echo "🔍 Collecting quality data from SonarQube API..."

# Function to call SonarQube API
call_sonar_api() {
    local endpoint="$1"
    curl -s -u "$SONAR_TOKEN:" "$SONAR_URL/api/$endpoint"
}

# 1. Get Project Information
echo "📋 Collecting project information..."
PROJECT_INFO=$(call_sonar_api "projects/search?projects=$PROJECT_KEY")
echo "$PROJECT_INFO" > "$OUTPUT_DIR/project-info.json"

# 2. Get Quality Gate Status
echo "🎯 Collecting quality gate status..."
QG_STATUS=$(call_sonar_api "qualitygates/project_status?projectKey=$PROJECT_KEY")
echo "$QG_STATUS" > "$OUTPUT_DIR/quality-gate-status.json"

# 3. Get All Measures/Metrics
echo "📊 Collecting all project measures..."
MEASURES=$(call_sonar_api "measures/component?component=$PROJECT_KEY&metricKeys=coverage,bugs,vulnerabilities,code_smells,duplicated_lines_density,ncloc,complexity,test_success_rate,reliability_rating,security_rating,sqale_rating")
echo "$MEASURES" > "$OUTPUT_DIR/measures.json"

# 4. Get Issues (Bugs, Vulnerabilities, Code Smells)
echo "🐛 Collecting issues..."
ISSUES=$(call_sonar_api "issues/search?componentKeys=$PROJECT_KEY&ps=500")
echo "$ISSUES" > "$OUTPUT_DIR/issues.json"

# 5. Get Test Coverage Details
echo "🧪 Collecting coverage details..."
COVERAGE=$(call_sonar_api "measures/component_tree?component=$PROJECT_KEY&metricKeys=coverage,line_coverage,branch_coverage,uncovered_lines&ps=500")
echo "$COVERAGE" > "$OUTPUT_DIR/coverage-details.json"

echo "📈 Creating master sheet from collected data..."

# Create CSV Master Sheet
MASTER_CSV="$OUTPUT_DIR/master-quality-report.csv"
TIMESTAMP=$(date -u +"%Y-%m-%d %H:%M:%S UTC")
BUILD_NUM=${BUILD_NUMBER:-$(date +%s)}

# CSV Header
cat > "$MASTER_CSV" << 'EOF'
Date,Build,Project,Coverage %,Bugs,Vulnerabilities,Code Smells,Duplicated Lines %,Lines of Code,Complexity,Quality Gate,Reliability Rating,Security Rating,Maintainability Rating
EOF

# Extract metrics and create CSV row
if command -v jq >/dev/null 2>&1; then
    # Use jq to parse JSON if available
    COVERAGE_VAL=$(jq -r '.component.measures[] | select(.metric=="coverage") | .value // "0"' "$OUTPUT_DIR/measures.json" 2>/dev/null || echo "0")
    BUGS_VAL=$(jq -r '.component.measures[] | select(.metric=="bugs") | .value // "0"' "$OUTPUT_DIR/measures.json" 2>/dev/null || echo "0")
    VULNERABILITIES_VAL=$(jq -r '.component.measures[] | select(.metric=="vulnerabilities") | .value // "0"' "$OUTPUT_DIR/measures.json" 2>/dev/null || echo "0")
    CODE_SMELLS_VAL=$(jq -r '.component.measures[] | select(.metric=="code_smells") | .value // "0"' "$OUTPUT_DIR/measures.json" 2>/dev/null || echo "0")
    DUPLICATED_VAL=$(jq -r '.component.measures[] | select(.metric=="duplicated_lines_density") | .value // "0"' "$OUTPUT_DIR/measures.json" 2>/dev/null || echo "0")
    NCLOC_VAL=$(jq -r '.component.measures[] | select(.metric=="ncloc") | .value // "0"' "$OUTPUT_DIR/measures.json" 2>/dev/null || echo "0")
    COMPLEXITY_VAL=$(jq -r '.component.measures[] | select(.metric=="complexity") | .value // "0"' "$OUTPUT_DIR/measures.json" 2>/dev/null || echo "0")
    QG_STATUS_VAL=$(jq -r '.projectStatus.status // "UNKNOWN"' "$OUTPUT_DIR/quality-gate-status.json" 2>/dev/null || echo "UNKNOWN")
    RELIABILITY_VAL=$(jq -r '.component.measures[] | select(.metric=="reliability_rating") | .value // "0"' "$OUTPUT_DIR/measures.json" 2>/dev/null || echo "0")
    SECURITY_VAL=$(jq -r '.component.measures[] | select(.metric=="security_rating") | .value // "0"' "$OUTPUT_DIR/measures.json" 2>/dev/null || echo "0")
    MAINTAINABILITY_VAL=$(jq -r '.component.measures[] | select(.metric=="sqale_rating") | .value // "0"' "$OUTPUT_DIR/measures.json" 2>/dev/null || echo "0")
else
    # Fallback: basic grep parsing
    COVERAGE_VAL=$(grep -o '"coverage"[^}]*"value":"[^"]*"' "$OUTPUT_DIR/measures.json" | grep -o '"value":"[^"]*"' | cut -d'"' -f4 || echo "0")
    BUGS_VAL=$(grep -o '"bugs"[^}]*"value":"[^"]*"' "$OUTPUT_DIR/measures.json" | grep -o '"value":"[^"]*"' | cut -d'"' -f4 || echo "0")
    VULNERABILITIES_VAL="0"
    CODE_SMELLS_VAL="0"
    DUPLICATED_VAL="0"
    NCLOC_VAL="0"
    COMPLEXITY_VAL="0"
    QG_STATUS_VAL="UNKNOWN"
    RELIABILITY_VAL="0"
    SECURITY_VAL="0"
    MAINTAINABILITY_VAL="0"
fi

# Add row to CSV
echo "$TIMESTAMP,$BUILD_NUM,$PROJECT_KEY,$COVERAGE_VAL,$BUGS_VAL,$VULNERABILITIES_VAL,$CODE_SMELLS_VAL,$DUPLICATED_VAL,$NCLOC_VAL,$COMPLEXITY_VAL,$QG_STATUS_VAL,$RELIABILITY_VAL,$SECURITY_VAL,$MAINTAINABILITY_VAL" >> "$MASTER_CSV"

echo "📋 Creating comprehensive quality report..."

# Create comprehensive report
REPORT_FILE="$OUTPUT_DIR/comprehensive-quality-report.md"
cat > "$REPORT_FILE" << EOF
# Master Quality Report

**Generated**: $TIMESTAMP  
**Build**: $BUILD_NUM  
**Project**: $PROJECT_KEY  

## Quality Dashboard Summary

| Metric | Value |
|--------|-------|
| **Coverage** | ${COVERAGE_VAL}% |
| **Bugs** | $BUGS_VAL |
| **Vulnerabilities** | $VULNERABILITIES_VAL |
| **Code Smells** | $CODE_SMELLS_VAL |
| **Duplicated Lines** | ${DUPLICATED_VAL}% |
| **Lines of Code** | $NCLOC_VAL |
| **Complexity** | $COMPLEXITY_VAL |
| **Quality Gate** | $QG_STATUS_VAL |

## Ratings

| Category | Rating |
|----------|--------|
| **Reliability** | $RELIABILITY_VAL |
| **Security** | $SECURITY_VAL |
| **Maintainability** | $MAINTAINABILITY_VAL |

## Data Files Generated

- 📊 **Master CSV**: [master-quality-report.csv](master-quality-report.csv)
- 📋 **Project Info**: [project-info.json](project-info.json)
- 🎯 **Quality Gate**: [quality-gate-status.json](quality-gate-status.json)
- 📊 **All Measures**: [measures.json](measures.json)
- 🐛 **Issues**: [issues.json](issues.json)
- 🧪 **Coverage**: [coverage-details.json](coverage-details.json)

## SonarQube Links

- 🌐 **Project Dashboard**: [$SONAR_URL/dashboard?id=$PROJECT_KEY]($SONAR_URL/dashboard?id=$PROJECT_KEY)
- 🐛 **Issues**: [$SONAR_URL/project/issues?id=$PROJECT_KEY]($SONAR_URL/project/issues?id=$PROJECT_KEY)
- 📊 **Measures**: [$SONAR_URL/component_measures?id=$PROJECT_KEY]($SONAR_URL/component_measures?id=$PROJECT_KEY)

## Next Steps

1. Review the master CSV for trends
2. Address quality gate failures if any
3. Set up regular data collection
4. Compare metrics across builds

EOF

echo "✅ Data collection and organization complete!"
echo ""
echo "📁 Generated Files:"
find "$OUTPUT_DIR" -type f | sed 's/^/  /'
echo ""
echo "📊 Master CSV Preview:"
head -5 "$MASTER_CSV"
echo ""
echo "🎯 Key Metrics:"
echo "   Coverage: ${COVERAGE_VAL}%"
echo "   Bugs: $BUGS_VAL"
echo "   Quality Gate: $QG_STATUS_VAL"