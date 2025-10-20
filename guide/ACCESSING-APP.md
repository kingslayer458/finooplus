# 🔧 Accessing Your Application on Docker Desktop Kubernetes

## Why NodePort (localhost:30080) Doesn't Work

Docker Desktop Kubernetes on Windows/WSL2 has a known limitation where **NodePort services are not directly accessible via `localhost`**. This is because:

1. Kubernetes runs inside Docker Desktop's Linux VM
2. NodePort binds to the VM's internal network (`192.168.65.3`)
3. This internal network is not directly accessible from Windows

## ✅ Solutions That Work

### **Option 1: Port-Forward (RECOMMENDED)**

This is the most reliable method for local development:

```powershell
# Forward port 8080 to your application
kubectl port-forward service/sample-web-app-service 8080:80
```

Then open: **http://localhost:8080**

**Quick Script:**
```powershell
.\open-app.ps1
```
This script automatically starts port-forwarding and opens your browser!

### **Option 2: LoadBalancer Service**

If you need the LoadBalancer service to work on a different port (since port 80 is taken by Apache):

```powershell
# Check the assigned port
kubectl get svc sample-web-app-service

# It shows: 80:XXXXX/TCP
# Use the second port (XXXXX) with localhost
```

Example: If it shows `80:32087/TCP`, use `http://localhost:32087`

### **Option 3: Minikube (If You Want NodePort)**

If you really need NodePort to work, use Minikube instead of Docker Desktop:

```powershell
# Install Minikube
choco install minikube

# Start with tunnel
minikube start
minikube tunnel  # Runs in background, makes NodePort accessible

# Now localhost:30080 will work!
```

## 📊 Quick Access Commands

```powershell
# Method 1: Port-Forward (Port 8080)
kubectl port-forward service/sample-web-app-service 8080:80
# Open: http://localhost:8080

# Method 2: LoadBalancer Random Port
kubectl get svc sample-web-app-service -o jsonpath='{.spec.ports[0].nodePort}'
# Use the port number shown with: http://localhost:PORT

# Method 3: Use the script
.\open-app.ps1
```

## 🎯 For Production/Cloud

In production (AWS EKS, Azure AKS, GCP GKE):
- **LoadBalancer** gets a real external IP
- **NodePort** works on any node's IP
- **Ingress** provides proper domain-based routing

## 🔍 Troubleshooting

### Check if pods are running:
```powershell
kubectl get pods
```

### Check services:
```powershell
kubectl get svc
```

### View application logs:
```powershell
kubectl logs -l app=sample-web-app --tail=50
```

### Test health endpoint:
```powershell
# With port-forward running on 8080:
Invoke-WebRequest http://localhost:8080/api/health
```

## ✅ Current Status

Your application IS working! You just need to access it via:
- ✅ **http://localhost:8080** (with port-forward)
- ✅ **http://localhost:32087** (or whatever port LoadBalancer assigned)
- ❌ ~~http://localhost:30080~~ (NodePort - doesn't work on Docker Desktop)

---

**TL;DR**: Use `.\open-app.ps1` or `kubectl port-forward service/sample-web-app-service 8080:80` and open http://localhost:8080 🚀
