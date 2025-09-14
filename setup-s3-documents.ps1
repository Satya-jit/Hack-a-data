# AWS S3 Bucket Setup Script for PRISM Documents
# Creates the required folder structure and uploads test documents

$S3_BUCKET = "prism-doc"
$REGION = "us-east-1"

Write-Host "📁 Setting up S3 bucket structure for PRISM documents..." -ForegroundColor Green

# Create test documents directory locally
$testDocsDir = "test-documents"
if (!(Test-Path $testDocsDir)) {
    New-Item -ItemType Directory -Path $testDocsDir -Force | Out-Null
}

# Sample document 1: Clinical Protocol
$doc1 = @{
    documentId = "PRISM-2024-001"
    title = "Clinical Protocol - Opioid Prescribing Guidelines Update"
    content = @"
CLINICAL PROTOCOL DOCUMENT

Protocol Title: Updated Guidelines for Opioid Prescribing in Chronic Pain Management
Protocol Number: CP-2024-001
Effective Date: September 2024

EXECUTIVE SUMMARY:
This protocol establishes updated guidelines for healthcare providers regarding opioid prescribing practices in accordance with new ODDA requirements.

KEY REQUIREMENTS:
1. Enhanced patient screening procedures
2. Mandatory risk assessment protocols
3. Updated dosage calculation methods
4. Improved monitoring procedures

THERAPEUTIC AREAS: Pain Management, Anesthesiology
DRUGS COVERED: Oxycodone, Morphine, Fentanyl, Hydrocodone
MARKETS: United States, European Union

REGULATORY COMPLIANCE:
- FDA CFR 21 Part 1301
- DEA Controlled Substances Act
- ODDA Guidelines 2024

IMPLEMENTATION TIMELINE:
Phase 1: October 2024 - Training and preparation
Phase 2: November 2024 - Pilot implementation
Phase 3: December 2024 - Full rollout

For questions regarding this protocol, contact the Regulatory Affairs department.
"@
    therapeuticArea = "Pain Management"
    drug = "Oxycodone, Morphine, Fentanyl"
    market = "US, EU"
    documentType = "Clinical Protocol"
    lastModified = "2024-09-01"
    version = "1.2"
    status = "Active"
}

# Sample document 2: Regulatory Submission
$doc2 = @{
    documentId = "PRISM-2024-002"
    title = "Regulatory Submission - Opioid Risk Evaluation and Mitigation Strategy"
    content = @"
REGULATORY SUBMISSION DOCUMENT

Submission Title: Risk Evaluation and Mitigation Strategy (REMS) for Opioid Medications
Submission Number: RS-2024-002
Submission Date: August 2024

PURPOSE:
To outline comprehensive risk mitigation strategies for opioid medications in compliance with updated ODDA requirements.

RISK MITIGATION COMPONENTS:
1. Healthcare Provider Education Programs
2. Patient Counseling Requirements
3. Safe Use Conditions
4. Implementation System

SCOPE OF APPLICATION:
All immediate-release and extended-release opioid analgesics intended for outpatient use.

THERAPEUTIC INDICATION: Management of pain severe enough to require daily, around-the-clock, long-term opioid treatment.

AFFECTED PRODUCTS:
- Oxycodone HCl (all formulations)
- Morphine Sulfate (extended-release)
- Fentanyl Transdermal System
- Hydromorphone HCl

REGULATORY PATHWAY: New Drug Application (NDA) Amendment

COMPLIANCE REQUIREMENTS:
- Monthly safety reporting
- Quarterly effectiveness assessments
- Annual comprehensive review

This submission addresses all requirements outlined in the latest ODDA guidance documents.
"@
    therapeuticArea = "Pain Management"
    drug = "Fentanyl, Morphine, Hydromorphone"
    market = "US"
    documentType = "Regulatory Submission"
    lastModified = "2024-08-15"
    version = "2.1"
    status = "Under Review"
}

# Sample document 3: Safety Monitoring Plan
$doc3 = @{
    documentId = "PRISM-2024-003"
    title = "Safety Monitoring Plan - Chronic Pain Management"
    content = @"
SAFETY MONITORING PLAN

Plan Title: Comprehensive Safety Monitoring for Chronic Pain Medications
Plan Number: SMP-2024-003
Effective Date: July 2024

MONITORING OBJECTIVES:
1. Early detection of adverse events
2. Assessment of benefit-risk profile
3. Identification of safety signals
4. Evaluation of real-world effectiveness

MONITORING SCOPE:
Patient Population: Adults (≥18 years) receiving opioid therapy for chronic non-cancer pain
Duration: Continuous monitoring throughout treatment period

KEY SAFETY PARAMETERS:
- Respiratory depression incidents
- Addiction and abuse potential
- Drug-drug interactions
- Tolerance development
- Withdrawal symptoms

DATA COLLECTION METHODS:
1. Electronic Health Records (EHR) monitoring
2. Patient-reported outcome measures
3. Healthcare provider assessments
4. Prescription drug monitoring programs

REPORTING REQUIREMENTS:
- Serious adverse events: Within 24 hours
- Periodic safety updates: Monthly
- Annual safety reports: Comprehensive analysis

THERAPEUTIC FOCUS: Chronic pain conditions including:
- Osteoarthritis
- Neuropathic pain
- Fibromyalgia
- Lower back pain

This plan ensures compliance with all current safety monitoring requirements and ODDA guidelines.
"@
    therapeuticArea = "Pain Management"
    drug = "Morphine, Oxycodone"
    market = "US"
    documentType = "Safety Plan"
    lastModified = "2024-07-20"
    version = "1.0"
    status = "Active"
}

# Convert to JSON and save locally
$documents = @($doc1, $doc2, $doc3)

foreach ($doc in $documents) {
    $jsonContent = $doc | ConvertTo-Json -Depth 10
    $filename = "$testDocsDir\$($doc.documentId).json"
    $jsonContent | Out-File -FilePath $filename -Encoding UTF8
    Write-Host "✅ Created test document: $($doc.documentId).json" -ForegroundColor Green
}

Write-Host ""
Write-Host "📤 Uploading test documents to S3..." -ForegroundColor Yellow

# Upload documents to S3
foreach ($doc in $documents) {
    $filename = "$testDocsDir\$($doc.documentId).json"
    $s3Key = "documents/$($doc.documentId).json"
    
    try {
        aws s3 cp $filename "s3://$S3_BUCKET/$s3Key"
        Write-Host "✅ Uploaded: $s3Key" -ForegroundColor Green
    } catch {
        Write-Host "⚠️ Failed to upload: $s3Key" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "📋 S3 Bucket Structure Created:" -ForegroundColor Cyan
Write-Host "s3://$S3_BUCKET/"
Write-Host "├── documents/"
Write-Host "│   ├── PRISM-2024-001.json (Clinical Protocol)"
Write-Host "│   ├── PRISM-2024-002.json (Regulatory Submission)"
Write-Host "│   └── PRISM-2024-003.json (Safety Plan)"
Write-Host ""
Write-Host "🎉 S3 setup completed!" -ForegroundColor Green
Write-Host ""
Write-Host "📝 Next Steps:" -ForegroundColor Cyan
Write-Host "1. Verify documents are uploaded: aws s3 ls s3://$S3_BUCKET/documents/"
Write-Host "2. Test Lambda function with document IDs: PRISM-2024-001, PRISM-2024-002, PRISM-2024-003"
Write-Host "3. Add more documents as needed for your specific use case"