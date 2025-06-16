#!/bin/bash

# Quality Data Organization Script for Phase 4: Consolidate

echo "🗂️ Quality Data Organization Script"
echo "==================================="

# Create directories for organized data
mkdir -p quality-data/{metrics,trends,reports,issues}

echo "📊 Collecting current quality metrics..."

# Extract metrics from SonarQube API (if available)
SONAR_URL="${SONAR_HOST_URL:-http://194.163.40.149:9000}"
PROJECT_KEY="Sonarqube-testing"

echo "Project: $PROJECT_KEY"
echo "SonarQube URL: $SONAR_URL"

# Organize test results
echo "🧪 Organizing test results..."
if [ -d "target/surefire-reports" ]; then
    cp -r target/surefire-reports/* quality-data/reports/ 2>/dev/null || true
    
    # Count test results
    TOTAL_TESTS=$(find target/surefire-reports -name "*.xml" -exec grep -l "testsuite" {} \; | wc -l)
    FAILED_TESTS=$(find target/surefire-reports -name "*.xml" -exec grep -l 'failures="[^0]"' {} \; | wc -l)
    
    echo "Total test suites: $TOTAL_TESTS" > quality-data/metrics/test-summary.txt
    echo "Failed test suites: $FAILED_TESTS" >> quality-data/metrics/test-summary.txt
fi

# Organize coverage data
echo "📈 Organizing coverage data..."
if [ -f "target/site/jacoco/jacoco.xml" ]; then
    cp target/site/jacoco/jacoco.xml quality-data/metrics/
    
    # Extract coverage percentage
    INSTRUCTION_COVERED=$(grep -o 'instruction covered="[0-9]*"' target/site/jacoco/jacoco.xml | grep -o '[0-9]*' | head -1)
    INSTRUCTION_MISSED=$(grep -o 'instruction missed="[0-9]*"' target/site/jacoco/jacoco.xml | grep -o '[0-9]*' | head -1)
    
    if [ ! -z "$INSTRUCTION_COVERED" ] && [ ! -z "$INSTRUCTION_MISSED" ]; then
        TOTAL=$((INSTRUCTION_COVERED + INSTRUCTION_MISSED))
        COVERAGE_PERCENT=$((INSTRUCTION_COVERED * 100 / TOTAL))
        echo "Coverage: ${COVERAGE_PERCENT}%" > quality-data/metrics/coverage-summary.txt
        echo "Instructions covered: $INSTRUCTION_COVERED" >> quality-data/metrics/coverage-summary.txt
        echo "Instructions missed: $INSTRUCTION_MISSED" >> quality-data/metrics/coverage-summary.txt
    fi
fi

# Organize source code metrics
echo "📋 Organizing source code metrics..."
if [ -d "src/main/java" ]; then
    JAVA_FILES=$(find src/main/java -name "*.java" | wc -l)
    TOTAL_LINES=$(find src/main/java -name "*.java" -exec wc -l {} + | tail -1 | awk '{print $1}')
    
    echo "Java files: $JAVA_FILES" > quality-data/metrics/source-summary.txt
    echo "Total lines: $TOTAL_LINES" >> quality-data/metrics/source-summary.txt
fi

# Create trend data entry
echo "📊 Creating trend data entry..."
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
BUILD_NUM=${BUILD_NUMBER:-$(date +%s)}

cat > quality-data/trends/build-${BUILD_NUM}.json << EOF
{
  "timestamp": "$TIMESTAMP",
  "build_number": "$BUILD_NUM",
  "commit_sha": "${GITHUB_SHA:-unknown}",
  "branch": "${GITHUB_REF_NAME:-main}",
  "metrics": {
    "coverage_percent": ${COVERAGE_PERCENT:-0},
    "java_files": ${JAVA_FILES:-0},
    "total_lines": ${TOTAL_LINES:-0},
    "total_tests": ${TOTAL_TESTS:-0},
    "failed_tests": ${FAILED_TESTS:-0}
  },
  "quality_gate": "pending"
}
EOF

# Generate consolidated report
echo "📄 Generating consolidated report..."
cat > quality-data/reports/consolidated-$(date +%Y%m%d).md << EOF
# Quality Data Consolidation Report

**Generated**: $(date -u)
**Build**: ${BUILD_NUM}
**Project**: ${PROJECT_KEY}

## Summary Dashboard

### Code Metrics
- **Source Files**: ${JAVA_FILES:-N/A}
- **Lines of Code**: ${TOTAL_LINES:-N/A}
- **Test Coverage**: ${COVERAGE_PERCENT:-N/A}%

### Test Metrics  
- **Test Suites**: ${TOTAL_TESTS:-N/A}
- **Failed Tests**: ${FAILED_TESTS:-N/A}
- **Success Rate**: $(( (TOTAL_TESTS - FAILED_TESTS) * 100 / TOTAL_TESTS ))%

### Quality Status
- **Analysis Date**: $(date -u)
- **SonarQube Project**: [$PROJECT_KEY]($SONAR_URL/dashboard?id=$PROJECT_KEY)
- **Data Organization**: Complete ✅

## Data Files Organized
$(find quality-data -type f | sed 's/^/- /')

## Next Steps
1. Review SonarQube dashboard for detailed metrics
2. Track trends over time using trend data
3. Set up alerts for quality regressions
4. Use organized data for reporting

EOF

echo "✅ Quality data organization complete!"
echo ""
echo "📁 Organized data structure:"
find quality-data -type f | head -10

echo ""
echo "📊 Key metrics summary:"
[ -f quality-data/metrics/coverage-summary.txt ] && cat quality-data/metrics/coverage-summary.txt
[ -f quality-data/metrics/test-summary.txt ] && cat quality-data/metrics/test-summary.txt
[ -f quality-data/metrics/source-summary.txt ] && cat quality-data/metrics/source-summary.txt