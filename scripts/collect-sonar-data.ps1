# Phase 4: Collect and organize quality data from SonarQube
# SECURE PowerShell version - NO HARDCODED CREDENTIALS

# Security: Require environment variables - NO DEFAULTS WITH CREDENTIALS
$SONAR_URL = $env:SONAR_HOST_URL
$SONAR_TOKEN = $env:SONAR_TOKEN
$PROJECT_KEY = "sonarqube-testing"
$OUTPUT_DIR = "quality-data\master-reports"

# Validation: Ensure required environment variables are set
if (-not $SONAR_URL) {
    Write-Host "❌ ERROR: SONAR_HOST_URL environment variable not set" -ForegroundColor Red
    Write-Host "Set it with: `$env:SONAR_HOST_URL='your-sonar-url'" -ForegroundColor Yellow
    exit 1
}

if (-not $SONAR_TOKEN) {
    Write-Host "❌ ERROR: SONAR_TOKEN environment variable not set" -ForegroundColor Red
    Write-Host "Set it with: `$env:SONAR_TOKEN='your-token'" -ForegroundColor Yellow
    exit 1
}

Write-Host "📊 SonarQube Data Collection & Organization (SECURE)" -ForegroundColor Cyan
Write-Host "=====================================================" -ForegroundColor Cyan
Write-Host "SonarQube URL: $SONAR_URL"
Write-Host "Project: $PROJECT_KEY"
Write-Host "Output: $OUTPUT_DIR"
Write-Host "Security: ✅ Using environment variables (no hardcoded credentials)"
Write-Host ""

# Create output directory
if (!(Test-Path "quality-data")) { New-Item -ItemType Directory -Path "quality-data" }
if (!(Test-Path $OUTPUT_DIR)) { New-Item -ItemType Directory -Path $OUTPUT_DIR }

Write-Host "🔍 Collecting quality data from SonarQube API..." -ForegroundColor Yellow

# Function to call SonarQube API
function Call-SonarAPI {
    param($endpoint)
    $auth = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("${SONAR_TOKEN}:"))
    $headers = @{ Authorization = "Basic $auth" }
    try {
        Invoke-RestMethod -Uri "$SONAR_URL/api/$endpoint" -Headers $headers
    } catch {
        Write-Host "Error calling API: $_" -ForegroundColor Red
        return $null
    }
}

# 1. Get Project Information
Write-Host "📋 Collecting project information..."
$projectInfo = Call-SonarAPI "projects/search?projects=$PROJECT_KEY"
if ($projectInfo) {
    $projectInfo | ConvertTo-Json -Depth 10 | Out-File "$OUTPUT_DIR\project-info.json" -Encoding UTF8
}

# 2. Get Quality Gate Status
Write-Host "🎯 Collecting quality gate status..."
$qgStatus = Call-SonarAPI "qualitygates/project_status?projectKey=$PROJECT_KEY"
if ($qgStatus) {
    $qgStatus | ConvertTo-Json -Depth 10 | Out-File "$OUTPUT_DIR\quality-gate-status.json" -Encoding UTF8
}

# 3. Get All Measures
Write-Host "📊 Collecting all project measures..."
$measures = Call-SonarAPI "measures/component?component=$PROJECT_KEY&metricKeys=coverage,bugs,vulnerabilities,code_smells,duplicated_lines_density,ncloc,complexity,reliability_rating,security_rating,sqale_rating"
if ($measures) {
    $measures | ConvertTo-Json -Depth 10 | Out-File "$OUTPUT_DIR\measures.json" -Encoding UTF8
}

# 4. Get Issues
Write-Host "🐛 Collecting issues..."
$issues = Call-SonarAPI "issues/search?componentKeys=$PROJECT_KEY&ps=500"
if ($issues) {
    $issues | ConvertTo-Json -Depth 10 | Out-File "$OUTPUT_DIR\issues.json" -Encoding UTF8
}

# 5. Get Coverage Details
Write-Host "🧪 Collecting coverage details..."
$coverage = Call-SonarAPI "measures/component_tree?component=$PROJECT_KEY&metricKeys=coverage,line_coverage,branch_coverage,uncovered_lines&ps=500"
if ($coverage) {
    $coverage | ConvertTo-Json -Depth 10 | Out-File "$OUTPUT_DIR\coverage-details.json" -Encoding UTF8
}

Write-Host "📈 Creating master sheet from collected data..." -ForegroundColor Green

# Extract key metrics
$coverageVal = "0"
$bugsVal = "0"
$vulnerabilitiesVal = "0"
$codeSmellsVal = "0"
$qgStatusVal = "UNKNOWN"

if ($measures -and $measures.component -and $measures.component.measures) {
    foreach ($measure in $measures.component.measures) {
        switch ($measure.metric) {
            "coverage" { $coverageVal = $measure.value }
            "bugs" { $bugsVal = $measure.value }
            "vulnerabilities" { $vulnerabilitiesVal = $measure.value }
            "code_smells" { $codeSmellsVal = $measure.value }
        }
    }
}

if ($qgStatus -and $qgStatus.projectStatus) {
    $qgStatusVal = $qgStatus.projectStatus.status
}

# Create CSV Master Sheet
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss UTC"
$buildNum = if ($env:BUILD_NUMBER) { $env:BUILD_NUMBER } else { "local-secure-$(Get-Date -Format 'yyyyMMddHHmm')" }

$csvHeader = "Date,Build,Project,Coverage %,Bugs,Vulnerabilities,Code Smells,Quality Gate"
$csvRow = "$timestamp,$buildNum,$PROJECT_KEY,$coverageVal,$bugsVal,$vulnerabilitiesVal,$codeSmellsVal,$qgStatusVal"

$csvContent = @($csvHeader, $csvRow) -join "`n"
$csvContent | Out-File "$OUTPUT_DIR\master-quality-report.csv" -Encoding UTF8

# Create comprehensive report
$reportContent = @"
# Master Quality Report (SECURE)

**Generated**: $timestamp  
**Build**: $buildNum  
**Project**: $PROJECT_KEY  
**Security**: ✅ No hardcoded credentials used

## Quality Dashboard Summary

| Metric | Value |
|--------|-------|
| **Coverage** | ${coverageVal}% |
| **Bugs** | $bugsVal |
| **Vulnerabilities** | $vulnerabilitiesVal |
| **Code Smells** | $codeSmellsVal |
| **Quality Gate** | $qgStatusVal |

## Data Files Generated

- 📊 **Master CSV**: [master-quality-report.csv](master-quality-report.csv)
- 📋 **Project Info**: [project-info.json](project-info.json)
- 🎯 **Quality Gate**: [quality-gate-status.json](quality-gate-status.json)
- 📊 **All Measures**: [measures.json](measures.json)
- 🐛 **Issues**: [issues.json](issues.json)
- 🧪 **Coverage**: [coverage-details.json](coverage-details.json)

## Security Notice

✅ This script uses environment variables for credentials  
✅ No hardcoded tokens or URLs in source code  
✅ Safe for version control and team sharing  

## Usage Instructions

Set environment variables before running:
```powershell
`$env:SONAR_HOST_URL="your-sonarqube-url"
`$env:SONAR_TOKEN="your-token"
.\scripts\collect-sonar-data-secure.ps1
```

## Next Steps

1. Review the master CSV for trends
2. Address quality gate failures if any
3. Set up regular data collection with secure credentials
"@

$reportContent | Out-File "$OUTPUT_DIR\comprehensive-quality-report.md" -Encoding UTF8

Write-Host "✅ SECURE data collection complete!" -ForegroundColor Green
Write-Host ""
Write-Host "📁 Generated Files:" -ForegroundColor Cyan
Get-ChildItem $OUTPUT_DIR | Format-Table Name, Length
Write-Host ""
Write-Host "📊 Master CSV Preview:" -ForegroundColor Cyan
Get-Content "$OUTPUT_DIR\master-quality-report.csv"
Write-Host ""
Write-Host "🎯 Key Metrics:" -ForegroundColor Cyan
Write-Host "   Coverage: ${coverageVal}%"
Write-Host "   Bugs: $bugsVal"
Write-Host "   Quality Gate: $qgStatusVal"
Write-Host ""
Write-Host "🔒 Security: ✅ No hardcoded credentials used" -ForegroundColor Green