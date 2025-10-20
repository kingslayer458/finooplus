# 🔑 Add Kubeconfig Credentials to Jenkins

## Quick Setup (5 Minutes)

### Step 1: Navigate to Credentials
```
http://localhost:8081
↓
Manage Jenkins (left sidebar)
↓
Credentials
↓
System → Global credentials (unrestricted)
↓
+ Add Credentials (left sidebar)
```

### Step 2: Fill the Form

| Field | Value |
|-------|-------|
| **Kind** | `Secret file` ⬇️ |
| **Scope** | `Global (Jenkins, nodes, items, all child items, etc)` |
| **File** | Click **Choose File** → Browse to:<br>`C:\Users\manoj\OneDrive\Desktop\finoopluss\kubeconfig.yaml` |
| **ID** | `kubeconfig-credentials` ⚠️ **MUST BE EXACT** |
| **Description** | `Kubernetes config for Docker Desktop` |

### Step 3: Click "Create" Button

---

## Visual Guide

```
┌─────────────────────────────────────────────┐
│  Add Credentials                         [×] │
├─────────────────────────────────────────────┤
│                                             │
│  Kind: [Secret file ▼]                     │
│                                             │
│  Scope: [Global (Jenkins, nodes...) ▼]     │
│                                             │
│  File: [Choose File]  kubeconfig.yaml      │
│                                             │
│  ID: kubeconfig-credentials                │
│      ⚠️ This must match exactly!           │
│                                             │
│  Description: Kubernetes config for         │
│               Docker Desktop cluster        │
│                                             │
│  [Create]  [Cancel]                        │
└─────────────────────────────────────────────┘
```

---

## Verification Checklist

After clicking "Create", verify:

- ✅ You see `kubeconfig-credentials` in the credentials list
- ✅ Type shows as "Secret file"
- ✅ Description shows your text
- ✅ No error messages appear

---

## What This Credential Does

The `kubeconfig-credentials` allows Jenkins to:
1. Connect to your Docker Desktop Kubernetes cluster
2. Deploy the application using `kubectl` commands
3. Verify the deployment status
4. Rollout updates automatically

Without this credential, Jenkins cannot access Kubernetes and the pipeline will fail at the "Deploy to Kubernetes" stage.

---

## After Adding Credentials

### The pipeline will automatically work! 🎉

Next time you push code to GitHub (or click "Build Now" in Jenkins), the pipeline will:

1. ✅ Checkout code from Git
2. ✅ Build (npm ci)
3. ✅ Test (npm test)
4. ✅ Docker Build
5. ✅ Docker Push → `docker.io/kingslayerone/sample-web-app:BUILD_NUMBER`
6. ✅ **Deploy to Kubernetes** ← This will now work!
7. ✅ Verify Deployment

---

## Troubleshooting

### Error: "File not found"
- Make sure you're selecting the kubeconfig.yaml from:
  ```
  C:\Users\manoj\OneDrive\Desktop\finoopluss\kubeconfig.yaml
  ```

### Error: "ID already exists"
- The credential was already added! Check the credentials list
- If you need to update it, delete the old one first

### Pipeline Still Fails at Kubernetes Stage
1. Check Docker Desktop Kubernetes is running:
   ```powershell
   kubectl cluster-info
   ```
2. Verify the credential ID is exactly: `kubeconfig-credentials` (no spaces, no typos)
3. Check Jenkins console output for detailed error message

---

## Next: Test the Pipeline

After adding credentials, trigger a new build:

### Option A: Push a Change
```powershell
cd C:\Users\manoj\OneDrive\Desktop\finoopluss
echo "# Test" >> README.md
git add README.md
git commit -m "Test Jenkins pipeline"
git push origin main
```

### Option B: Manual Build
1. Go to http://localhost:8081
2. Click **"sample-web-app-pipeline"**
3. Click **"Build Now"**
4. Watch the build progress!

---

## Expected Success Output

```
[Pipeline] Start of Pipeline
✅ Stage 1: Checkout - SUCCESS
✅ Stage 2: Build - SUCCESS
✅ Stage 3: Test - SUCCESS
✅ Stage 4: Docker Build - SUCCESS
✅ Stage 5: Docker Push - SUCCESS
✅ Stage 6: Deploy to Kubernetes - SUCCESS  ← This should now work!
✅ Stage 7: Verify Deployment - SUCCESS

========================================
✅ Pipeline completed successfully!
========================================
Build Number: 5
Docker Image: docker.io/kingslayerone/sample-web-app:5
Deployed to: default namespace
```

---

## Quick Reference

| Item | Value |
|------|-------|
| Jenkins URL | http://localhost:8081 |
| Credential Type | Secret file |
| Credential ID | `kubeconfig-credentials` |
| File Location | `C:\Users\manoj\OneDrive\Desktop\finoopluss\kubeconfig.yaml` |
| Used By | Jenkinsfile stages: "Deploy to Kubernetes" and "Verify Deployment" |

---

**Ready?** → Go to http://localhost:8081 → Manage Jenkins → Credentials → Add!
