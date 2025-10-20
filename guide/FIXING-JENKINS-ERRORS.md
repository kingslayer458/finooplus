# Fixing Jenkins Pipeline Errors

## Issues Encountered in Build #4

### ❌ Issue 1: Docker Push Failed
**Error**: `push access denied, repository does not exist or may require authorization`

**Root Cause**: The image was being pushed to `docker.io/library/sample-web-app` instead of `docker.io/kingslayerone/sample-web-app`

**✅ Fixed**: Updated `DOCKER_IMAGE_NAME` in Jenkinsfile from `sample-web-app` to `kingslayerone/sample-web-app`

---

### ❌ Issue 2: Kubernetes Credentials Missing
**Error**: `Could not find credentials entry with ID 'kubeconfig-credentials'`

**Root Cause**: The kubeconfig file hasn't been added to Jenkins credentials store yet.

**✅ Solution**: Follow the steps below to add Kubernetes credentials

---

## Step-by-Step: Add Kubernetes Credentials to Jenkins

### Step 1: Open Jenkins Credentials Page
1. Go to Jenkins: **http://localhost:8081**
2. Click on **"Manage Jenkins"** (left sidebar)
3. Click on **"Credentials"**
4. Click on **"System"** → **"Global credentials (unrestricted)"**
5. Click **"Add Credentials"** (left sidebar)

### Step 2: Add Kubeconfig as Secret File
Fill in the form:
- **Kind**: `Secret file`
- **Scope**: `Global (Jenkins, nodes, items, all child items, etc)`
- **File**: Click **"Choose File"** and select: `C:\Users\manoj\OneDrive\Desktop\finoopluss\kubeconfig.yaml`
- **ID**: `kubeconfig-credentials` (MUST be exactly this)
- **Description**: `Kubernetes config for Docker Desktop cluster`

Click **"Create"**

### Step 3: Verify Credentials Were Added
1. You should see `kubeconfig-credentials` in the credentials list
2. It should show type: "Secret file"

---

## Alternative: Deploy to Local Kubernetes Without Jenkins

If you want to test the deployment directly first:

```powershell
# Navigate to project directory
cd C:\Users\manoj\OneDrive\Desktop\finoopluss

# Build the Docker image locally
docker build -t kingslayerone/sample-web-app:latest .

# Apply Kubernetes manifests
kubectl apply -f k8s/deployment-local.yaml
kubectl apply -f k8s/service.yaml
kubectl apply -f k8s/configmap.yaml

# Check deployment status
kubectl get pods
kubectl get deployments
kubectl get services

# Access the application
kubectl port-forward service/sample-web-app-service 8080:80
```

Then open: http://localhost:8080

---

## After Adding Credentials: Re-run Jenkins Pipeline

### Option 1: Manual Build
1. Go to Jenkins: http://localhost:8081
2. Click on **"sample-web-app-pipeline"** job
3. Click **"Build Now"** (left sidebar)
4. Monitor the build progress

### Option 2: Push New Code (Automatic Build)
```powershell
# Commit the Jenkinsfile fix
cd C:\Users\manoj\OneDrive\Desktop\finoopluss
git add Jenkinsfile
git commit -m "Fix Docker image name for Docker Hub push"
git push origin main
```

Jenkins will automatically detect the change (polling every 5 minutes) and start a new build.

---

## Expected Successful Pipeline Output

When everything is configured correctly, you should see:

```
✅ Stage 1: Checkout - SUCCESS
✅ Stage 2: Build - SUCCESS (npm ci completes)
✅ Stage 3: Test - SUCCESS (all tests pass)
✅ Stage 4: Docker Build - SUCCESS (image built)
✅ Stage 5: Docker Push - SUCCESS (pushed to docker.io/kingslayerone/sample-web-app:5)
✅ Stage 6: Deploy to Kubernetes - SUCCESS (deployed to cluster)
✅ Stage 7: Verify Deployment - SUCCESS (3 pods running)

✅ Pipeline completed successfully!
```

---

## Troubleshooting

### If Docker Push Still Fails After Fix
Check your Docker Hub credentials in Jenkins:
1. Go to **Manage Jenkins** → **Credentials**
2. Verify `docker-hub-credentials` exists
3. Username should be: `kingslayerone`
4. Password should be your Docker Hub access token

### If Kubernetes Deploy Fails
Check that:
1. Docker Desktop Kubernetes is running
2. The kubeconfig.yaml file is correct
3. You can run `kubectl get nodes` successfully from PowerShell

### If Image Pull Fails in Kubernetes
Since you're using Docker Hub, you'll need to:
1. Make the repository public on Docker Hub, OR
2. Add an image pull secret to Kubernetes

**Quick fix - Make repo public:**
1. Go to https://hub.docker.com
2. Login as `kingslayerone`
3. Go to Repositories → `sample-web-app`
4. Click **Settings** → Make repository **Public**

---

## Summary of Changes Made

| File | Change | Reason |
|------|--------|--------|
| `Jenkinsfile` | Changed `DOCKER_IMAGE_NAME` from `sample-web-app` to `kingslayerone/sample-web-app` | Docker Hub requires `username/repository` format |
| Jenkins Credentials | Need to add `kubeconfig-credentials` | Pipeline needs kubeconfig to deploy to Kubernetes |

---

## Next Steps

1. ✅ **Commit and push the Jenkinsfile fix**
2. ⚠️ **Add kubeconfig-credentials to Jenkins** (follow Step 2 above)
3. ⚠️ **Create Docker Hub repository** (if it doesn't exist)
4. ⚠️ **Re-run the Jenkins pipeline**
5. ✅ **Verify deployment** with `kubectl get pods`

---

## Quick Commands Reference

```powershell
# Check Jenkins is running
docker ps | Select-String jenkins

# Check Kubernetes cluster
kubectl cluster-info
kubectl get nodes

# Check existing deployments
kubectl get deployments
kubectl get pods
kubectl get services

# View application logs
kubectl logs -l app=sample-web-app --tail=50

# Port forward to access app
kubectl port-forward service/sample-web-app-service 8080:80
```

---

**Need Help?** Check the Jenkins console output for detailed error messages. Each stage shows exactly what command failed and why.
