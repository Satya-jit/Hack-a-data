# 🚀 COMPLETE STEP-BY-STEP DEPLOYMENT GUIDE
# PRISM Regulatory Intelligence System with Claude 3.7

## ✅ UPDATED: Now Using Claude 3.7 Sonnet Model

---

## 📋 **STEP 1: AWS BEDROCK ACCESS SETUP**

### **1.1 Verify Bedrock Access (Already Granted)**
✅ **You already have access to Claude 3.7 Sonnet** - Great!

### **1.2 Verify Model Access**
```powershell
# Test Bedrock access
aws bedrock list-foundation-models --region us-east-1 --query "modelSummaries[?contains(modelId, 'claude-3-5-sonnet')]"
```

### **1.3 Model Information (Claude 3.7 Sonnet)**
- **Model ID**: `anthropic.claude-3-5-sonnet-20241022-v2:0`
- **Best performance** for complex regulatory analysis
- **Higher quality outputs** than Haiku
- **Optimal for regulatory document analysis**

---

## 📋 **STEP 2: PRE-DEPLOYMENT CHECKS**

### **2.1 Verify AWS CLI Installation**
```powershell
aws --version
# Should show: aws-cli/2.x.x or higher
```

### **2.2 Set AWS Credentials**
```powershell
aws configure
# AWS Access Key ID: AKIA2PUE3CS6HTYZ6G5F
# AWS Secret Access Key: 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
# Default region: us-east-1
# Default output format: json
```

### **2.3 Verify S3 Bucket Access**
```powershell
aws s3 ls s3://prism-doc
# Should show bucket contents or create bucket if doesn't exist
```

---

## 📋 **STEP 3: DEPLOY LAMBDA FUNCTIONS**

### **3.1 Run Deployment Script**
```powershell
# Navigate to project directory
cd "D:\OneDrive - Indegene Limited\Documents\HACKATHON Project"

# Set execution policy (if needed)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Run deployment script
.\deploy-lambda-functions.ps1
```

### **3.2 Expected Output**
```
🚀 Starting AWS Lambda deployment for PRISM Regulatory Intelligence System
✅ AWS CLI is installed
🔐 Creating IAM role for Lambda functions...
✅ IAM role created successfully
📎 Attaching IAM policy to role...
✅ IAM policy attached successfully
📦 Creating deployment packages...
✅ Created package: s3-fetcher.zip
✅ Created package: bedrock-analyzer.zip
✅ Created package: prism-integration.zip
🚀 Deploying Lambda functions...
✅ S3 Document Fetcher deployed successfully
✅ Bedrock Claude Analyzer deployed successfully
✅ PRISM Database Integration deployed successfully
🌐 Creating API Gateway...
✅ API Gateway created: abcd1234ef
🎉 Deployment completed!
```

### **3.3 Setup S3 Test Documents**
```powershell
.\setup-s3-documents.ps1
```

---

## 📋 **STEP 4: API GATEWAY CONFIGURATION**

### **4.1 Access API Gateway Console**
1. **AWS Console** → **API Gateway**
2. **Find your API**: `prism-regulatory-api`
3. **Click on the API name**

### **4.2 Create Resources and Methods**

#### **4.2.1 Create /documents Resource**
1. **Actions** → **Create Resource**
2. **Resource Name**: `documents`
3. **Resource Path**: `/documents`
4. **Enable CORS**: ✅ Checked
5. **Create Resource**

#### **4.2.2 Create GET Method for Documents**
1. **Select /documents resource**
2. **Actions** → **Create Method** → **GET**
3. **Integration Type**: Lambda Function
4. **Lambda Region**: us-east-1
5. **Lambda Function**: `prism-s3-document-fetcher`
6. **Save**
7. **Add Permission**: Yes

#### **4.2.3 Create /analyze Resource**
1. **Actions** → **Create Resource**
2. **Resource Name**: `analyze`
3. **Resource Path**: `/analyze`
4. **Enable CORS**: ✅ Checked
5. **Create Resource**

#### **4.2.4 Create POST Method for Analysis**
1. **Select /analyze resource**
2. **Actions** → **Create Method** → **POST**
3. **Integration Type**: Lambda Function
4. **Lambda Function**: `prism-bedrock-claude-analyzer`
5. **Save**
6. **Add Permission**: Yes

#### **4.2.5 Create /prism Resource**
1. **Actions** → **Create Resource**
2. **Resource Name**: `prism`
3. **Resource Path**: `/prism`
4. **Enable CORS**: ✅ Checked
5. **Create Resource**

#### **4.2.6 Create POST Method for PRISM**
1. **Select /prism resource**
2. **Actions** → **Create Method** → **POST**
3. **Integration Type**: Lambda Function
4. **Lambda Function**: `prism-database-integration`
5. **Save**
6. **Add Permission**: Yes

### **4.3 Deploy API**
1. **Actions** → **Deploy API**
2. **Deployment Stage**: New Stage
3. **Stage Name**: `prod`
4. **Stage Description**: Production
5. **Deploy**

### **4.4 Get API Endpoints**
After deployment, you'll get URLs like:
```
https://abcd1234ef.execute-api.us-east-1.amazonaws.com/prod/documents?documentId=PRISM-2024-001
https://abcd1234ef.execute-api.us-east-1.amazonaws.com/prod/analyze
https://abcd1234ef.execute-api.us-east-1.amazonaws.com/prod/prism
```

---

## 📋 **STEP 5: DYNAMODB SETUP (OPTIONAL)**

### **5.1 Create PRISM Table**
```powershell
aws dynamodb create-table \
    --table-name prism-regulatory-documents \
    --attribute-definitions \
        AttributeName=document_id,AttributeType=S \
    --key-schema \
        AttributeName=document_id,KeyType=HASH \
    --provisioned-throughput \
        ReadCapacityUnits=5,WriteCapacityUnits=5 \
    --region us-east-1
```

### **5.2 Add Sample Data**
```powershell
# Sample item
aws dynamodb put-item \
    --table-name prism-regulatory-documents \
    --item '{
        "document_id": {"S": "PRISM-2024-001"},
        "title": {"S": "Clinical Protocol - Opioid Prescribing"},
        "therapeutic_area": {"S": "Pain Management"},
        "drug": {"S": "Oxycodone"},
        "market": {"S": "US"},
        "document_type": {"S": "Clinical Protocol"},
        "last_modified": {"S": "2024-09-01"}
    }' \
    --region us-east-1
```

---

## 📋 **STEP 6: TEST DEPLOYMENT**

### **6.1 Test S3 Document Fetcher**
```powershell
curl "https://YOUR_API_ID.execute-api.us-east-1.amazonaws.com/prod/documents?documentId=PRISM-2024-001"
```

### **6.2 Test Claude Analysis**
```powershell
curl -X POST "https://YOUR_API_ID.execute-api.us-east-1.amazonaws.com/prod/analyze" \
    -H "Content-Type: application/json" \
    -d '{
        "prompt": "Analyze this regulatory document for compliance issues."
    }'
```

### **6.3 Test PRISM Integration**
```powershell
curl -X POST "https://YOUR_API_ID.execute-api.us-east-1.amazonaws.com/prod/prism" \
    -H "Content-Type: application/json" \
    -d '{
        "oddaTitle": "FDA Issues Updated Guidance on Opioid Prescribing",
        "therapeuticAreas": ["Pain Management"],
        "drugs": ["Oxycodone"]
    }'
```

---

## 📋 **STEP 7: UPDATE FRONTEND**

### **7.1 Update Ria.html with API Endpoints**
Replace placeholder URLs in `Ria.html` with your actual API Gateway URLs.

---

## ⚠️ **TROUBLESHOOTING**

### **Common Issues:**

1. **Bedrock Access Denied**
   - Check model access approval status
   - Verify IAM permissions include Bedrock actions

2. **Lambda Timeout**
   - Increase timeout in Lambda configuration
   - Check CloudWatch logs for errors

3. **CORS Issues**
   - Enable CORS on all API Gateway methods
   - Add proper headers in Lambda responses

4. **S3 Access Denied**
   - Verify bucket name is correct: `prism-doc`
   - Check IAM permissions for S3 access

---

## 🎉 **SUCCESS INDICATORS**

- ✅ All 3 Lambda functions deployed without errors
- ✅ API Gateway endpoints return valid responses
- ✅ Claude 3.7 model accessible in Bedrock
- ✅ S3 documents uploaded and retrievable
- ✅ Frontend connects to backend APIs

**Your PRISM Regulatory Intelligence System is now ready!** 🚀