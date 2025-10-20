# Automatic Pod Replacement Guide

## 🎯 Problem Statement

Previously, after building and pushing a new Docker image, you had to **manually** run commands to update the Kubernetes deployment:

```powershell
kubectl rollout undo deployment/sample-web-app
kubectl set image deployment/sample-web-app sample-web-app=kingslayerone/sample-web-app:8
```

This was because the Jenkins pipeline was using `kubectl rollout restart`, which only restarts pods with the **same image** instead of updating to the new image tag.

---

## ✅ Solution Implemented

### What Changed in Jenkinsfile

**BEFORE (Lines 233-234):**
```groovy
REM Restart deployment to pick up new image
kubectl rollout restart deployment/${K8S_DEPLOYMENT_NAME} -n ${K8S_NAMESPACE} --kubeconfig=%KUBECONFIG%
```

**AFTER (Lines 233-235):**
```groovy
REM Update deployment with new image tag
echo Updating deployment image to: ${FULL_IMAGE_NAME}
kubectl set image deployment/${K8S_DEPLOYMENT_NAME} ${K8S_DEPLOYMENT_NAME}=${FULL_IMAGE_NAME} -n ${K8S_NAMESPACE} --kubeconfig=%KUBECONFIG%
```

### How It Works Now

1. **Build Stage:** Creates Docker image `kingslayerone/sample-web-app:9` (build number increments)
2. **Push Stage:** Pushes image to Docker Hub (or keeps local for `imagePullPolicy: Never`)
3. **Deploy Stage:** **Automatically updates** deployment with new image tag
4. **Kubernetes:** Triggers rolling update, terminates old pods, creates new ones

---

## 🔄 Kubernetes Rolling Update Process

When `kubectl set image` is executed:

```
Step 1: Create new ReplicaSet with image tag :9
Step 2: Start 1 new pod with image :9
Step 3: Wait for new pod to be Ready
Step 4: Terminate 1 old pod with image :8
Step 5: Repeat until all 3 pods are replaced
```

**Zero Downtime:** Old pods keep serving traffic until new pods are ready! 🎉

---

## 📊 What You'll See in Jenkins Console

```
Stage 6: Deploying to Kubernetes
=========================================
Deploying to Kubernetes cluster...
deployment.apps/sample-web-app unchanged
service/sample-web-app-service unchanged
configmap/sample-web-app-config unchanged

Updating deployment image to: docker.io/kingslayerone/sample-web-app:9
deployment.apps/sample-web-app image updated

Deployment initiated successfully
```

Then in **Stage 7: Verify Deployment**:
```
Waiting for deployment "sample-web-app" rollout to finish: 1 out of 3 new replicas have been updated...
Waiting for deployment "sample-web-app" rollout to finish: 2 out of 3 new replicas have been updated...
Waiting for deployment "sample-web-app" rollout to finish: 1 old replicas are pending termination...
deployment "sample-web-app" successfully rolled out
```

---

## 🎯 Benefits

| Before | After |
|--------|-------|
| ❌ Manual intervention required | ✅ Fully automatic |
| ❌ Pipeline says "success" but uses old image | ✅ Pipeline deploys new image every time |
| ❌ Must run kubectl commands manually | ✅ No manual steps needed |
| ❌ Error-prone (might forget) | ✅ Consistent and reliable |

---

## 🧪 Testing the Fix

### Next Build Will Automatically:

1. **Build** image with tag `:9`
2. **Push** to Docker Hub (or use local image)
3. **Update** deployment to use `:9`
4. **Terminate** old pods (with `:8`)
5. **Create** new pods (with `:9`)
6. **Verify** all pods are running

### Manual Verification:

After Build #9 completes, check:

```powershell
# Should show image tag :9
kubectl get deployment sample-web-app -o jsonpath='{.spec.template.spec.containers[0].image}'

# Should show 3 pods all running (new ReplicaSet)
kubectl get pods -l app=sample-web-app

# Should show recent rolling update
kubectl rollout history deployment/sample-web-app
```

---

## 🔍 Understanding the Commands

### `kubectl rollout restart` (OLD - What We Removed)
- Restarts pods with **same image** already in deployment spec
- Useful for: Applying ConfigMap changes, restarting unhealthy pods
- **NOT** useful for: Deploying new image versions

### `kubectl set image` (NEW - What We Added)
- **Updates** deployment spec with new image tag
- Triggers **rolling update** automatically
- Kubernetes creates new pods and terminates old ones
- **Perfect** for: CI/CD pipelines with versioned images

---

## 📝 Summary

**No more manual steps!** Your CI/CD pipeline now handles everything:

```
Git Push → Jenkins Build → Docker Image → Deploy to K8s → New Pods Automatically!
```

Every commit triggers a complete deployment with automatic pod replacement. 🚀

---

## 🎓 For Learning

If you want to understand what's happening behind the scenes:

```powershell
# Watch the rolling update in real-time
kubectl get pods -l app=sample-web-app -w

# See deployment history
kubectl rollout history deployment/sample-web-app

# See detailed pod events
kubectl describe pod <pod-name>

# Check current image in deployment
kubectl get deployment sample-web-app -o yaml | Select-String -Pattern "image:"
```

---

**Last Updated:** Build #8 → Build #9 (Fixed automatic pod replacement)
