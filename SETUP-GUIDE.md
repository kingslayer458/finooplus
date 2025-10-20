# Complete Step-by-Step Setup Guide for Beginners

This guide will walk you through every step needed to set up the CI/CD pipeline from scratch.

## 🎯 What You'll Learn

By the end of this guide, you'll have:
- A working sample web application
- Automated CI/CD pipeline with Jenkins
- Application deployed on Kubernetes
- Understanding of the entire DevOps workflow

## ⏱️ Estimated Time: 2-3 hours

---

## Part 1: Setting Up Your Development Environment (30 minutes)

### Step 1: Install Git

**Windows:**
1. Download Git from: https://git-scm.com/download/win
2. Run the installer
3. Keep default settings
4. Verify installation:
   ```powershell
   git --version
   ```

### Step 2: Install Node.js

1. Download Node.js from: https://nodejs.org/ (LTS version)
2. Run the installer
3. Verify installation:
   ```powershell
   node --version
   npm --version
   ```

### Step 3: Install Docker Desktop

1. Download from: https://www.docker.com/products/docker-desktop/
2. Install Docker Desktop
3. **Important**: Enable Kubernetes in Docker Desktop
   - Open Docker Desktop
   - Go to Settings → Kubernetes
   - Check "Enable Kubernetes"
   - Click "Apply & Restart"
4. Verify:
   ```powershell
   docker --version
   kubectl version --client
   ```

### Step 4: Create Docker Hub Account

1. Go to: https://hub.docker.com/
2. Sign up for a free account
3. Remember your username and password

---

## Part 2: Testing the Application Locally (20 minutes)

### Step 1: Open the Project

1. Open PowerShell
2. Navigate to your project:
   ```powershell
   cd "C:\Users\manoj\OneDrive\Desktop\finoopluss"
   ```

### Step 2: Install Dependencies

```powershell
npm install
```

**Expected Output**: You'll see a progress bar as packages are installed.

### Step 3: Run Tests

```powershell
npm test
```

**Expected Output**: All tests should pass ✓

### Step 4: Run the Application

```powershell
npm start
```

**Expected Output**: "Server is running on port 3000"

### Step 5: Test in Browser

1. Open browser
2. Go to: http://localhost:3000
3. Click "Check Health Status" button
4. You should see a success message

**Press Ctrl+C in PowerShell to stop the server**

---

## Part 3: Building and Testing Docker Container (20 minutes)

### Step 1: Build Docker Image

```powershell
docker build -t sample-web-app:latest .
```

**This might take 2-3 minutes the first time.**

### Step 2: Run Docker Container

```powershell
docker run -d -p 3000:3000 --name test-app sample-web-app:latest
```

### Step 3: Test Container

1. Open browser: http://localhost:3000
2. Test the application

### Step 4: View Container Logs

```powershell
docker logs test-app
```

### Step 5: Stop and Remove Container

```powershell
docker stop test-app
docker rm test-app
```

---

## Part 4: Setting Up Kubernetes (15 minutes)

### Step 1: Verify Kubernetes is Running

```powershell
kubectl cluster-info
kubectl get nodes
```

**Expected Output**: You should see your Docker Desktop node in "Ready" state.

### Step 2: Create Kubernetes Namespace (Optional)

```powershell
kubectl create namespace sample-app
```

### Step 3: Deploy to Kubernetes Manually (to test)

```powershell
# Apply all Kubernetes manifests
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml

# Check status
kubectl get pods
kubectl get services
```

### Step 4: Access the Application

```powershell
# Forward port to access locally
kubectl port-forward service/sample-web-app-service 8080:80
```

Open browser: http://localhost:8080

**Press Ctrl+C to stop port forwarding**

### Step 5: Clean Up (for now)

```powershell
kubectl delete -f k8s/
```

---

## Part 5: Setting Up Jenkins (45 minutes)

### Step 1: Run Jenkins in Docker

```powershell
docker run -d -p 8080:8080 -p 50000:50000 `
  -v jenkins_home:/var/jenkins_home `
  -v /var/run/docker.sock:/var/run/docker.sock `
  --name jenkins `
  jenkins/jenkins:lts
```

**Wait 1-2 minutes for Jenkins to start**

### Step 2: Get Initial Admin Password

```powershell
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
```

**Copy this password!**

### Step 3: Complete Jenkins Setup Wizard

1. Open browser: http://localhost:8080
2. Paste the admin password
3. Click "Install suggested plugins"
4. **Wait 5-10 minutes** for plugins to install
5. Create admin user:
   - Username: admin
   - Password: (choose a strong password)
   - Full name: Your Name
   - Email: your@email.com
6. Click "Save and Continue"
7. Click "Save and Finish"
8. Click "Start using Jenkins"

### Step 4: Install Additional Plugins

1. Go to: **Manage Jenkins** → **Manage Plugins**
2. Click **Available** tab
3. Search and select:
   - ☑ Docker Pipeline
   - ☑ Kubernetes CLI
   - ☑ Credentials Binding Plugin
4. Click "Install without restart"
5. Wait for installation to complete

### Step 5: Configure Jenkins Credentials

#### 5.1 Docker Hub Credentials

1. Go to: **Manage Jenkins** → **Manage Credentials**
2. Click **(global)** domain
3. Click **Add Credentials**
4. Configure:
   - Kind: `Username with password`
   - Scope: `Global`
   - Username: Your Docker Hub username
   - Password: Your Docker Hub password
   - ID: `docker-hub-credentials`
   - Description: `Docker Hub Credentials`
5. Click **Create**

#### 5.2 Kubernetes Config

1. First, get your kubeconfig:
   ```powershell
   kubectl config view --raw > kubeconfig.yaml
   ```

2. In Jenkins: **Add Credentials**
3. Configure:
   - Kind: `Secret file`
   - Scope: `Global`
   - File: Upload `kubeconfig.yaml`
   - ID: `kubeconfig-credentials`
   - Description: `Kubernetes Config`
4. Click **Create**

### Step 6: Update Jenkinsfile

1. Open `Jenkinsfile` in a text editor
2. Find line with `DOCKER_REGISTRY`:
   ```groovy
   DOCKER_IMAGE_NAME = 'sample-web-app'
   ```
3. Change to:
   ```groovy
   DOCKER_IMAGE_NAME = 'your-dockerhub-username/sample-web-app'
   ```
   **Replace `your-dockerhub-username` with your actual Docker Hub username**
4. Save the file

---

## Part 6: Setting Up Git Repository (20 minutes)

### Step 1: Create GitHub Repository

1. Go to: https://github.com
2. Click "New repository"
3. Repository name: `cicd-sample-app`
4. Keep it Public
5. **Do NOT** initialize with README
6. Click "Create repository"

### Step 2: Initialize Local Git Repository

```powershell
# Navigate to project directory
cd "C:\Users\manoj\OneDrive\Desktop\finoopluss"

# Initialize Git
git init

# Add all files
git add .

# Commit
git commit -m "Initial commit: Complete CI/CD setup"

# Add remote (replace YOUR-USERNAME)
git remote add origin https://github.com/YOUR-USERNAME/cicd-sample-app.git

# Push to GitHub
git branch -M main
git push -u origin main
```

**If prompted for credentials, use your GitHub username and password (or token)**

---

## Part 7: Creating Jenkins Pipeline (20 minutes)

### Step 1: Create New Pipeline Job

1. In Jenkins, click **New Item**
2. Enter name: `sample-web-app-pipeline`
3. Select: **Pipeline**
4. Click **OK**

### Step 2: Configure Pipeline

#### General Section:
- ☑ Check "GitHub project"
- Project url: `https://github.com/YOUR-USERNAME/cicd-sample-app`

#### Build Triggers:
- ☑ Check "Poll SCM"
- Schedule: `H/5 * * * *`
  (This checks for changes every 5 minutes)

#### Pipeline Section:
- Definition: Select `Pipeline script from SCM`
- SCM: Select `Git`
- Repository URL: `https://github.com/YOUR-USERNAME/cicd-sample-app.git`
- Branch Specifier: `*/main`
- Script Path: `Jenkinsfile`

### Step 3: Save and Build

1. Click **Save**
2. Click **Build Now**

### Step 4: Monitor Build

1. Click on build number (e.g., #1)
2. Click **Console Output**
3. Watch the build process

**First build will take 10-15 minutes**

### Expected Output:
- ✅ Checkout
- ✅ Build
- ✅ Test
- ✅ Docker Build
- ✅ Docker Push
- ✅ Deploy to Kubernetes
- ✅ Verify Deployment

---

## Part 8: Verifying the Deployment (10 minutes)

### Step 1: Check Kubernetes Pods

```powershell
kubectl get pods
```

**Expected**: You should see 3 pods running

### Step 2: Check Services

```powershell
kubectl get services
```

### Step 3: Access the Application

#### Method 1: Port Forward
```powershell
kubectl port-forward service/sample-web-app-service 8080:80
```
Open: http://localhost:8080

#### Method 2: NodePort
```powershell
# Get node port
kubectl get svc sample-web-app-nodeport
```
Open: http://localhost:30080

### Step 4: Test the API

```powershell
# Health check
curl http://localhost:8080/api/health

# Get message
curl http://localhost:8080/api/message
```

---

## Part 9: Testing the CI/CD Pipeline (15 minutes)

### Step 1: Make a Code Change

1. Open `server.js`
2. Find the line:
   ```javascript
   message: 'Hello from CI/CD Pipeline!',
   ```
3. Change to:
   ```javascript
   message: 'Hello from Automated CI/CD Pipeline! 🚀',
   ```
4. Save the file

### Step 2: Commit and Push

```powershell
git add server.js
git commit -m "Update welcome message"
git push origin main
```

### Step 3: Watch Jenkins

1. Go to Jenkins dashboard
2. Within 5 minutes, a new build should start automatically
3. Monitor the build progress

### Step 4: Verify Update

1. Wait for build to complete
2. Refresh your browser at http://localhost:8080
3. Click "Get Message from API"
4. You should see the updated message!

---

## Part 10: Understanding What You Built

### The CI/CD Flow:

1. **Developer** makes code changes
2. **Git** tracks the changes
3. **Jenkins** detects the commit (polls every 5 minutes)
4. **Jenkins Pipeline** automatically:
   - Pulls the latest code
   - Installs dependencies
   - Runs tests
   - Builds Docker image
   - Pushes image to Docker Hub
   - Deploys to Kubernetes
   - Verifies deployment
5. **Kubernetes** runs your application in containers
6. **Users** access the updated application

### Key Components:

- **Jenkinsfile**: Defines the pipeline stages
- **Dockerfile**: Defines how to build the container
- **k8s/deployment.yaml**: Defines how to run in Kubernetes
- **k8s/service.yaml**: Defines how to access the application

---

## 🎉 Congratulations!

You've successfully set up a complete CI/CD pipeline!

## What's Next?

### Enhance Your Pipeline:

1. **Add Slack/Email Notifications**
2. **Set up GitHub Webhooks** (instead of polling)
3. **Add Code Quality Checks** (ESLint, SonarQube)
4. **Implement Blue-Green Deployment**
5. **Add Monitoring** (Prometheus, Grafana)
6. **Set up Log Aggregation** (ELK Stack)

### Learn More:

- Jenkins best practices
- Kubernetes advanced features
- Docker optimization techniques
- DevOps security practices

---

## 🆘 Getting Help

### If Something Goes Wrong:

1. **Check Jenkins Console Output**
   - Shows exactly where the build failed

2. **Check Kubernetes Logs**
   ```powershell
   kubectl get pods
   kubectl logs <pod-name>
   kubectl describe pod <pod-name>
   ```

3. **Check Docker Logs**
   ```powershell
   docker logs jenkins
   ```

4. **Common Issues**:
   - Docker not running → Start Docker Desktop
   - Kubernetes not ready → Enable in Docker Desktop
   - Jenkins can't connect → Check credentials
   - Port already in use → Stop other services

### Useful Commands Reference:

```powershell
# Jenkins
docker restart jenkins
docker logs jenkins

# Kubernetes
kubectl get all
kubectl describe pod <pod-name>
kubectl logs <pod-name>
kubectl delete pod <pod-name>

# Docker
docker ps
docker images
docker system prune

# Git
git status
git log
git reset --hard HEAD
```

---

## 📚 Resources

- [Jenkins Documentation](https://www.jenkins.io/doc/)
- [Kubernetes Tutorials](https://kubernetes.io/docs/tutorials/)
- [Docker Getting Started](https://docs.docker.com/get-started/)
- [Git Guide](https://git-scm.com/doc)

**Keep learning and happy coding! 🚀**
