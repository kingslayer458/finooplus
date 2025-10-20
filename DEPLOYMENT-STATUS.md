# 🎉 Your CI/CD Application is Running!

## ✅ What's Working

Your application is successfully deployed on Kubernetes with 3 running pods!

## 🚨 Important: Port 3000 is INSIDE the Container

**Why you can't reach port 3000 directly:**

The pods show "Server is running on port 3000" because **that's the port INSIDE each container**. 

Think of it like this:
```
Your Windows Machine (localhost)
    ↓ (can't directly access)
Docker Desktop Kubernetes (Linux VM)
    ↓ (internal network)
Pod 1: Running on port 3000 (container internal)
Pod 2: Running on port 3000 (container internal)
Pod 3: Running on port 3000 (container internal)
```

**You need port-forwarding to create a tunnel from your Windows machine to the pods.**

## 🌐 How to Access Your Application

### **Method 1: Use the Script (EASIEST) ✅**

```powershell
.\open-app.ps1
```

This will:
1. ✅ Find an available port (avoids 80/8080/8081 conflicts)
2. ✅ Automatically open your browser
3. ✅ Keep the connection alive

### **Method 2: Manual Port-Forward ✅**

```powershell
# Port 5000 (if Apache/Jenkins aren't using it)
kubectl port-forward service/sample-web-app-service 5000:80
```

Then open: **http://localhost:5000**

**If port 5000 is busy, try:**
```powershell
# Try different ports
kubectl port-forward service/sample-web-app-service 5001:80
# or
kubectl port-forward service/sample-web-app-service 6000:80
# or
kubectl port-forward service/sample-web-app-service 7000:80
```

## ❌ Why Ports 80 and 8080 Don't Work

- **Port 80**: Apache is running here
- **Port 8080**: Jenkins is running here
- **Port 8081**: Jenkins is also here
- **Port 3000**: This is INSIDE the container, not accessible from Windows

**Solution**: Use port 5000, 5001, 6000, 7000, or any other available port!

## ❌ Why localhost:30080 Doesn't Work

**Docker Desktop Kubernetes Limitation**: NodePort services don't work with `localhost` on Windows because Kubernetes runs in a Linux VM with an internal network that's not directly accessible from Windows.

**See [`ACCESSING-APP.md`](ACCESSING-APP.md) for detailed explanation.**

## 📊 Your Deployment Status

```powershell
# Check pods (should show 3 running)
kubectl get pods -l app=sample-web-app

# Check services
kubectl get svc -l app=sample-web-app

# View application logs
kubectl logs -l app=sample-web-app --tail=20

# Get a specific pod name
kubectl get pods -l app=sample-web-app -o jsonpath='{.items[0].metadata.name}'
```

## 🎯 Test Your Application

Once you run `.\open-app.ps1` (which opens on port 5000 or another available port):

1. ✅ You'll see a beautiful purple gradient web page
2. ✅ Click **"Check Health Status"** - should return healthy status
3. ✅ Click **"Get Message from API"** - should return "Hello from CI/CD Pipeline!"

**Endpoints to test manually:**
```powershell
# Replace 5000 with whatever port the script chose
curl http://localhost:5000/api/health
curl http://localhost:5000/api/message
curl http://localhost:5000
```

## 🔧 Useful Commands

```powershell
# Restart deployment
kubectl rollout restart deployment sample-web-app

# Scale replicas
kubectl scale deployment sample-web-app --replicas=5

# Watch pod status in real-time
kubectl get pods -l app=sample-web-app --watch

# Port-forward to a specific pod on port 5000
$pod = kubectl get pods -l app=sample-web-app -o jsonpath='{.items[0].metadata.name}'
kubectl port-forward pod/$pod 5000:3000

# Port-forward to service on port 5000
kubectl port-forward service/sample-web-app-service 5000:80

# View real-time logs from all pods
kubectl logs -f -l app=sample-web-app

# View logs from specific pod
kubectl logs sample-web-app-xxxxx

# Delete everything
kubectl delete -f k8s/
```

## 🚀 Next Steps

Now that your app is running, you can:

1. **Set up Jenkins** - Continue with Part 6 of [`SETUP-GUIDE.md`](SETUP-GUIDE.md )
2. **Make code changes** - Edit server.js and redeploy
3. **Test auto-scaling** - The HPA will scale based on load
4. **Add monitoring** - Set up Prometheus/Grafana

## 🐛 Troubleshooting

### App not accessible?
```powershell
# Make sure port-forward is running (use available port)
kubectl port-forward service/sample-web-app-service 5000:80

# Or use the script
.\open-app.ps1

# Check pods are running
kubectl get pods -l app=sample-web-app

# Check pod logs for errors
kubectl logs -l app=sample-web-app --tail=50
```

### Port conflicts (80, 8080, 8081, 9090 busy)?
**Apache and Jenkins are using these ports!**

Use these free ports instead:
- ✅ Port 5000, 5001, 5002
- ✅ Port 6000, 7000
- ✅ Port 5555

```powershell
# Try port 5000
kubectl port-forward service/sample-web-app-service 5000:80

# Or let the script find a free port
.\open-app.ps1
```

### "Site can't be reached" error?
This happens because:
1. **Port 3000 is INSIDE the container** - not accessible from Windows
2. **You need port-forwarding** to access the app
3. **Ports 80/8080 are busy** with Apache/Jenkins

**Solution:**
```powershell
# Use the script (finds free port automatically)
.\open-app.ps1

# Or manual port-forward to available port
kubectl port-forward service/sample-web-app-service 5000:80
```

### Need to rebuild and redeploy?
```powershell
# Build new image
docker build -t sample-web-app:latest .

# Restart deployment to pick up new image
kubectl rollout restart deployment sample-web-app

# Check rollout status
kubectl rollout status deployment sample-web-app
```

---

## 📝 Summary

- ✅ **Application**: Running with 3 pods
- ✅ **Access Method**: Port-forwarding (use `.\open-app.ps1`)
- ✅ **Recommended Port**: 5000, 5001, or 6000 (avoids Apache/Jenkins conflicts)
- ✅ **Health Check**: http://localhost:5000/api/health (or your chosen port)
- ✅ **API Endpoint**: http://localhost:5000/api/message (or your chosen port)
- ❌ **Port 3000**: Inside container only - not directly accessible
- ❌ **Ports 80/8080**: Busy with Apache/Jenkins
- ❌ **NodePort 30080**: Not accessible (Docker Desktop limitation)

**Your app is working perfectly! Just run `.\open-app.ps1` to access it. 🎉**
