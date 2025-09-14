# 🚀 MANUAL AWS DEPLOYMENT GUIDE
# PRISM Regulatory Intelligence System - Step by Step

Since we encountered CLI installation issues, here's a complete manual deployment guide using the AWS Console.

---

## 📋 **STEP 1: CREATE IAM ROLE**

### **1.1 Go to IAM Console**
1. **Login to AWS Console**: https://console.aws.amazon.com/
2. **Navigate to IAM**: Search "IAM" in services
3. **Click "Roles"** in left sidebar
4. **Click "Create role"**

### **1.2 Configure Role**
1. **Select trusted entity**: AWS service
2. **Use case**: Lambda
3. **Click "Next"**

### **1.3 Attach Permissions**
1. **Search and attach these policies**:
   - `AWSLambdaBasicExecutionRole`
   - `AmazonS3FullAccess`
   - `AmazonBedrockFullAccess`
   - `AmazonDynamoDBFullAccess`
2. **Click "Next"**

### **1.4 Name the Role**
1. **Role name**: `prism-lambda-execution-role`
2. **Description**: `Execution role for PRISM regulatory intelligence Lambda functions`
3. **Click "Create role"**

---

## 📋 **STEP 2: CREATE S3 BUCKET**

### **2.1 Go to S3 Console**
1. **Navigate to S3**: https://console.aws.amazon.com/s3/
2. **Click "Create bucket"**

### **2.2 Configure Bucket**
1. **Bucket name**: `prism-doc`
2. **Region**: US East (N. Virginia) us-east-1
3. **Keep all other defaults**
4. **Click "Create bucket"**

### **2.3 Upload Test Documents**
1. **Click on bucket**: `prism-doc`
2. **Create folder**: Click "Create folder" → Name it `documents`
3. **Upload test documents**: Download and upload these 3 JSON files to the `documents/` folder:

**File 1: PRISM-2024-001.json**
```json
{
  "documentId": "PRISM-2024-001",
  "title": "Clinical Protocol - Opioid Prescribing Guidelines Update",
  "content": "CLINICAL PROTOCOL DOCUMENT\n\nProtocol Title: Updated Guidelines for Opioid Prescribing in Chronic Pain Management\nProtocol Number: CP-2024-001\nEffective Date: September 2024\n\nEXECUTIVE SUMMARY:\nThis protocol establishes updated guidelines for healthcare providers regarding opioid prescribing practices in accordance with new ODDA requirements.\n\nKEY REQUIREMENTS:\n1. Enhanced patient screening procedures\n2. Mandatory risk assessment protocols\n3. Updated dosage calculation methods\n4. Improved monitoring procedures\n\nTHERAPEUTIC AREAS: Pain Management, Anesthesiology\nDRUGS COVERED: Oxycodone, Morphine, Fentanyl, Hydrocodone\nMARKETS: United States, European Union\n\nREGULATORY COMPLIANCE:\n- FDA CFR 21 Part 1301\n- DEA Controlled Substances Act\n- ODDA Guidelines 2024",
  "therapeuticArea": "Pain Management",
  "drug": "Oxycodone, Morphine, Fentanyl",
  "market": "US, EU",
  "documentType": "Clinical Protocol",
  "lastModified": "2024-09-01",
  "version": "1.2",
  "status": "Active"
}
```

**File 2: PRISM-2024-002.json**
```json
{
  "documentId": "PRISM-2024-002",
  "title": "Regulatory Submission - Opioid Risk Evaluation and Mitigation Strategy",
  "content": "REGULATORY SUBMISSION DOCUMENT\n\nSubmission Title: Risk Evaluation and Mitigation Strategy (REMS) for Opioid Medications\nSubmission Number: RS-2024-002\nSubmission Date: August 2024\n\nPURPOSE:\nTo outline comprehensive risk mitigation strategies for opioid medications in compliance with updated ODDA requirements.\n\nRISK MITIGATION COMPONENTS:\n1. Healthcare Provider Education Programs\n2. Patient Counseling Requirements\n3. Safe Use Conditions\n4. Implementation System\n\nSCOPE OF APPLICATION:\nAll immediate-release and extended-release opioid analgesics intended for outpatient use.\n\nAFFECTED PRODUCTS:\n- Oxycodone HCl (all formulations)\n- Morphine Sulfate (extended-release)\n- Fentanyl Transdermal System\n- Hydromorphone HCl",
  "therapeuticArea": "Pain Management",
  "drug": "Fentanyl, Morphine, Hydromorphone",
  "market": "US",
  "documentType": "Regulatory Submission",
  "lastModified": "2024-08-15",
  "version": "2.1",
  "status": "Under Review"
}
```

**File 3: PRISM-2024-003.json**
```json
{
  "documentId": "PRISM-2024-003",
  "title": "Safety Monitoring Plan - Chronic Pain Management",
  "content": "SAFETY MONITORING PLAN\n\nPlan Title: Comprehensive Safety Monitoring for Chronic Pain Medications\nPlan Number: SMP-2024-003\nEffective Date: July 2024\n\nMONITORING OBJECTIVES:\n1. Early detection of adverse events\n2. Assessment of benefit-risk profile\n3. Identification of safety signals\n4. Evaluation of real-world effectiveness\n\nKEY SAFETY PARAMETERS:\n- Respiratory depression incidents\n- Addiction and abuse potential\n- Drug-drug interactions\n- Tolerance development\n- Withdrawal symptoms\n\nREPORTING REQUIREMENTS:\n- Serious adverse events: Within 24 hours\n- Periodic safety updates: Monthly\n- Annual safety reports: Comprehensive analysis",
  "therapeuticArea": "Pain Management",
  "drug": "Morphine, Oxycodone",
  "market": "US",
  "documentType": "Safety Plan",
  "lastModified": "2024-07-20",
  "version": "1.0",
  "status": "Active"
}
```

---

## 📋 **STEP 3: CREATE LAMBDA FUNCTIONS**

### **3.1 Go to Lambda Console**
1. **Navigate to Lambda**: https://console.aws.amazon.com/lambda/
2. **Click "Create function"**

### **3.2 Create S3 Document Fetcher Function**
1. **Function name**: `prism-s3-document-fetcher`
2. **Runtime**: Python 3.11
3. **Execution role**: Use existing role → `prism-lambda-execution-role`
4. **Click "Create function"**

**Code**: Copy and paste the entire content of `lambda_s3_document_fetcher.py`

**Configuration**:
- **Timeout**: 5 minutes
- **Memory**: 1024 MB

### **3.3 Create Bedrock Claude Analyzer Function**
1. **Function name**: `prism-bedrock-claude-analyzer`
2. **Runtime**: Python 3.11
3. **Execution role**: Use existing role → `prism-lambda-execution-role`
4. **Click "Create function"**

**Code**: Copy and paste the entire content of `lambda_bedrock_claude_analyzer.py`

**Configuration**:
- **Timeout**: 5 minutes
- **Memory**: 1024 MB

### **3.4 Create PRISM Database Integration Function**
1. **Function name**: `prism-database-integration`
2. **Runtime**: Python 3.11
3. **Execution role**: Use existing role → `prism-lambda-execution-role`
4. **Click "Create function"**

**Code**: Copy and paste the entire content of `lambda_prism_database_integration.py`

**Configuration**:
- **Timeout**: 5 minutes
- **Memory**: 1024 MB

---

## 📋 **STEP 4: CREATE API GATEWAY**

### **4.1 Go to API Gateway Console**
1. **Navigate to API Gateway**: https://console.aws.amazon.com/apigateway/
2. **Click "Create API"**
3. **Choose "REST API"** (not private)
4. **Click "Build"**

### **4.2 Configure API**
1. **API name**: `prism-regulatory-api`
2. **Description**: `PRISM Regulatory Intelligence API`
3. **Endpoint Type**: Regional
4. **Click "Create API"**

### **4.3 Create Resources and Methods**

#### **4.3.1 Create /documents Resource**
1. **Actions** → **Create Resource**
2. **Resource Name**: `documents`
3. **Resource Path**: `/documents`
4. **Enable CORS**: ✅ Checked
5. **Create Resource**

#### **4.3.2 Add GET Method to /documents**
1. **Select /documents resource**
2. **Actions** → **Create Method** → **GET**
3. **Integration Type**: Lambda Function
4. **Lambda Region**: us-east-1
5. **Lambda Function**: `prism-s3-document-fetcher`
6. **Save** → **OK** (Add permission)

#### **4.3.3 Create /analyze Resource**
1. **Actions** → **Create Resource**
2. **Resource Name**: `analyze`
3. **Resource Path**: `/analyze`
4. **Enable CORS**: ✅ Checked
5. **Create Resource**

#### **4.3.4 Add POST Method to /analyze**
1. **Select /analyze resource**
2. **Actions** → **Create Method** → **POST**
3. **Integration Type**: Lambda Function
4. **Lambda Function**: `prism-bedrock-claude-analyzer`
5. **Save** → **OK**

#### **4.3.5 Create /prism Resource**
1. **Actions** → **Create Resource**
2. **Resource Name**: `prism`
3. **Resource Path**: `/prism`
4. **Enable CORS**: ✅ Checked
5. **Create Resource**

#### **4.3.6 Add POST Method to /prism**
1. **Select /prism resource**
2. **Actions** → **Create Method** → **POST**
3. **Integration Type**: Lambda Function
4. **Lambda Function**: `prism-database-integration`
5. **Save** → **OK**

### **4.4 Enable CORS for All Methods**
For each resource (/documents, /analyze, /prism):
1. **Select the resource**
2. **Actions** → **Enable CORS**
3. **Access-Control-Allow-Origin**: `*`
4. **Access-Control-Allow-Headers**: `Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token`
5. **Access-Control-Allow-Methods**: Select appropriate methods
6. **Enable CORS and replace existing CORS headers**

### **4.5 Deploy API**
1. **Actions** → **Deploy API**
2. **Deployment stage**: New Stage
3. **Stage name**: `prod`
4. **Deploy**

### **4.6 Get API Endpoints**
After deployment, your endpoints will be:
```
GET  https://YOUR_API_ID.execute-api.us-east-1.amazonaws.com/prod/documents?documentId=PRISM-2024-001
POST https://YOUR_API_ID.execute-api.us-east-1.amazonaws.com/prod/analyze
POST https://YOUR_API_ID.execute-api.us-east-1.amazonaws.com/prod/prism
```

---

## 📋 **STEP 5: TEST THE DEPLOYMENT**

### **5.1 Test S3 Document Fetcher**
```
GET https://YOUR_API_ID.execute-api.us-east-1.amazonaws.com/prod/documents?documentId=PRISM-2024-001
```

### **5.2 Test Claude Analysis**
```
POST https://YOUR_API_ID.execute-api.us-east-1.amazonaws.com/prod/analyze
Content-Type: application/json

{
  "prompt": "Analyze this regulatory document for compliance issues."
}
```

### **5.3 Test PRISM Integration**
```
POST https://YOUR_API_ID.execute-api.us-east-1.amazonaws.com/prod/prism
Content-Type: application/json

{
  "oddaTitle": "FDA Issues Updated Guidance on Opioid Prescribing",
  "therapeuticAreas": ["Pain Management"],
  "drugs": ["Oxycodone"]
}
```

---

## 🎉 **DEPLOYMENT COMPLETE!**

### **✅ What You've Built:**
- ✅ **S3 Bucket** with test regulatory documents
- ✅ **3 Lambda Functions** with Claude 3.7 Sonnet integration
- ✅ **API Gateway** with REST endpoints
- ✅ **IAM Role** with proper permissions
- ✅ **Complete regulatory intelligence workflow**

### **🔗 Your API Endpoints:**
Replace `YOUR_API_ID` with your actual API Gateway ID:
- **Document Fetcher**: `GET /documents?documentId=PRISM-2024-001`
- **Claude Analyzer**: `POST /analyze`
- **PRISM Integration**: `POST /prism`

### **📝 Next Steps:**
1. **Update Ria.html** with your actual API Gateway URLs
2. **Test all endpoints** using a tool like Postman or curl
3. **Add more documents** to S3 as needed
4. **Configure DynamoDB** for real PRISM data (optional)

Your PRISM Regulatory Intelligence System is now live! 🚀