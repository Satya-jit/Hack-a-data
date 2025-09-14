import boto3
import json
import os
from datetime import datetime

# AWS Configuration
AWS_ACCESS_KEY_ID = "AKIA2PUE3CS6HTYZ6G5F"
AWS_SECRET_ACCESS_KEY = "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"
REGION = "us-east-1"
BUCKET_NAME = "prism-doc"

def setup_aws_resources():
    """Setup S3 bucket and upload test documents"""
    
    # Initialize AWS clients
    s3_client = boto3.client(
        's3',
        region_name=REGION,
        aws_access_key_id=AWS_ACCESS_KEY_ID,
        aws_secret_access_key=AWS_SECRET_ACCESS_KEY
    )
    
    print("🚀 Starting AWS S3 setup...")
    
    # Create bucket if it doesn't exist
    try:
        s3_client.head_bucket(Bucket=BUCKET_NAME)
        print(f"✅ Bucket {BUCKET_NAME} already exists")
    except:
        try:
            if REGION == 'us-east-1':
                s3_client.create_bucket(Bucket=BUCKET_NAME)
            else:
                s3_client.create_bucket(
                    Bucket=BUCKET_NAME,
                    CreateBucketConfiguration={'LocationConstraint': REGION}
                )
            print(f"✅ Created bucket: {BUCKET_NAME}")
        except Exception as e:
            print(f"❌ Failed to create bucket: {e}")
            return False
    
    # Sample documents
    documents = [
        {
            "documentId": "PRISM-2024-001",
            "title": "Clinical Protocol - Opioid Prescribing Guidelines Update",
            "content": """
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
            """,
            "therapeuticArea": "Pain Management",
            "drug": "Oxycodone, Morphine, Fentanyl",
            "market": "US, EU",
            "documentType": "Clinical Protocol",
            "lastModified": "2024-09-01",
            "version": "1.2",
            "status": "Active"
        },
        {
            "documentId": "PRISM-2024-002",
            "title": "Regulatory Submission - Opioid Risk Evaluation and Mitigation Strategy",
            "content": """
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
            """,
            "therapeuticArea": "Pain Management",
            "drug": "Fentanyl, Morphine, Hydromorphone",
            "market": "US",
            "documentType": "Regulatory Submission",
            "lastModified": "2024-08-15",
            "version": "2.1",
            "status": "Under Review"
        },
        {
            "documentId": "PRISM-2024-003",
            "title": "Safety Monitoring Plan - Chronic Pain Management",
            "content": """
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
            """,
            "therapeuticArea": "Pain Management",
            "drug": "Morphine, Oxycodone",
            "market": "US",
            "documentType": "Safety Plan",
            "lastModified": "2024-07-20",
            "version": "1.0",
            "status": "Active"
        }
    ]
    
    # Upload documents to S3
    print("📤 Uploading test documents to S3...")
    
    for doc in documents:
        try:
            # Convert document to JSON
            json_content = json.dumps(doc, indent=2)
            
            # Upload to S3
            key = f"documents/{doc['documentId']}.json"
            s3_client.put_object(
                Bucket=BUCKET_NAME,
                Key=key,
                Body=json_content,
                ContentType='application/json'
            )
            
            print(f"✅ Uploaded: {doc['documentId']}.json")
            
        except Exception as e:
            print(f"❌ Failed to upload {doc['documentId']}: {e}")
    
    # List bucket contents to verify
    print("\n📋 S3 Bucket Contents:")
    try:
        response = s3_client.list_objects_v2(Bucket=BUCKET_NAME, Prefix="documents/")
        if 'Contents' in response:
            for obj in response['Contents']:
                print(f"  ✅ {obj['Key']} ({obj['Size']} bytes)")
        else:
            print("  📁 No documents found")
    except Exception as e:
        print(f"❌ Failed to list bucket contents: {e}")
    
    print("\n🎉 S3 setup completed!")
    print(f"\n📍 S3 Bucket: s3://{BUCKET_NAME}")
    print("📍 Test Documents:")
    print("  - PRISM-2024-001.json (Clinical Protocol)")
    print("  - PRISM-2024-002.json (Regulatory Submission)")
    print("  - PRISM-2024-003.json (Safety Plan)")
    
    return True

if __name__ == "__main__":
    # Install boto3 if not available
    try:
        import boto3
    except ImportError:
        print("Installing boto3...")
        import subprocess
        subprocess.check_call(["pip", "install", "boto3"])
        import boto3
    
    setup_aws_resources()