# 🤖 Jenkins Setup Guide - Step by Step

## 🔑 Initial Admin Password

```
46f5845b8f5d4ce294bc71b99639c4b6
```

Copy this password! You'll need it in Step 3.

---

## 📋 Step-by-Step Instructions

### Step 1: Open Jenkins ✅

Jenkins should already be open in your browser at: **http://localhost:8081**

If not, open it manually.

### Step 2: Wait for Unlock Screen

You'll see: **"Unlock Jenkins"**

### Step 3: Enter Admin Password

1. Paste the password: `46f5845b8f5d4ce294bc71b99639c4b6`
2. Click **"Continue"**

### Step 4: Install Plugins (IMPORTANT!)

You'll see: **"Customize Jenkins"**

1. Click **"Install suggested plugins"**
2. ⏳ **Wait 5-10 minutes** (grab a coffee ☕)
3. You'll see progress bars for each plugin installing

### Step 5: Create First Admin User

After plugins install, you'll see: **"Create First Admin User"**

Fill in:
- **Username**: `admin`
- **Password**: `admin` (or your choice - remember it!)
- **Confirm password**: `admin`
- **Full name**: `Admin User`
- **Email**: `admin@example.com`

Click **"Save and Continue"**

### Step 6: Instance Configuration

You'll see: **"Instance Configuration"**

- **Jenkins URL**: Leave as `http://localhost:8081/`
- Click **"Save and Finish"**

### Step 7: Start Using Jenkins

Click **"Start using Jenkins"**

🎉 **You're in!**

---

## 🔧 Next Steps: Install Additional Plugins

Once you're in Jenkins:

### 1. Go to Plugin Manager

1. Click **"Manage Jenkins"** (on the left)
2. Click **"Manage Plugins"** (or "Plugins" in newer versions)
3. Click **"Available plugins"** tab

### 2. Search and Install These Plugins:

Search for each plugin and check the box:

1. ☑️ **"Docker Pipeline"** - For Docker support
2. ☑️ **"Kubernetes CLI"** - For kubectl commands
3. ☑️ **"Git Plugin"** - For Git integration (may already be installed)

### 3. Install Plugins

1. After checking all boxes, click **"Install without restart"**
2. ⏳ Wait for installation (2-3 minutes)
3. When done, you'll see checkmarks ✅

---

## 🎯 What's Next?

After installing plugins, come back to VS Code and let me know!

We'll then:
1. Configure Jenkins credentials (Docker Hub & Kubernetes)
2. Create your first pipeline
3. Set up automatic builds on Git commits

---

## 🐛 Troubleshooting

### Can't access localhost:8081?
```powershell
# Check Jenkins is running
docker ps | findstr jenkins

# Check logs
docker logs jenkins --tail 50

# Restart Jenkins
docker restart jenkins
```

### Forgot the password?
```powershell
# Get it again
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
```

### Jenkins is slow?
This is normal during initial setup. Give it 5-10 minutes for all plugins to install.

---

**Follow the steps above in your browser, then come back here when Jenkins is ready!** 🚀
