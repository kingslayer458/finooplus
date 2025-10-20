# Understanding Port 3000 vs Accessible Ports

## The Issue Explained

When you see "Server is running on port 3000" in the logs, that's **INSIDE the container**, not on your Windows machine.

### Architecture:

```
┌─────────────────────────────────────────┐
│   Your Windows Machine (localhost)      │
│                                         │
│   Port 80  → Apache                    │
│   Port 8080/8081 → Jenkins             │
│   Port 5000 → (Available for you!)     │
└─────────────────────────────────────────┘
              ↓ (needs port-forward)
┌─────────────────────────────────────────┐
│   Docker Desktop Kubernetes (Linux VM)  │
│                                         │
│   ┌─────────────────────────────────┐  │
│   │ Pod 1: sample-web-app           │  │
│   │  └─ Container Port: 3000        │  │
│   └─────────────────────────────────┘  │
│                                         │
│   ┌─────────────────────────────────┐  │
│   │ Pod 2: sample-web-app           │  │
│   │  └─ Container Port: 3000        │  │
│   └─────────────────────────────────┘  │
│                                         │
│   ┌─────────────────────────────────┐  │
│   │ Pod 3: sample-web-app           │  │
│   │  └─ Container Port: 3000        │  │
│   └─────────────────────────────────┘  │
└─────────────────────────────────────────┘
```

## Why You Can't Access Port 3000 Directly

1. **Port 3000 is inside each container** - it's an isolated environment
2. **The containers are running in a Linux VM** (Docker Desktop Kubernetes)
3. **Your Windows machine can't directly reach that VM's internal network**
4. **You need port-forwarding** to create a tunnel from Windows → Kubernetes → Pod

## The Solution

### Quick Access (Recommended):
```powershell
.\open-app.ps1
```

This script:
- ✅ Finds an available port on Windows (avoiding 80, 8080, 8081, 9090)
- ✅ Creates a port-forward tunnel from Windows → Pod
- ✅ Opens your browser automatically

### Manual Port-Forward:
```powershell
# Forward Windows port 5000 → Service port 80 → Container port 3000
kubectl port-forward service/sample-web-app-service 5000:80
```

Then access: **http://localhost:5000**

## Port Mapping Explained

```
Windows Port 5000 
  ↓ (port-forward)
Service Port 80 
  ↓ (Kubernetes routing)
Container Port 3000 
  ↓ (where Node.js listens)
Your App!
```

## Why Certain Ports Are Busy

| Port | Service | Reason |
|------|---------|--------|
| 80 | Apache | You have Apache/XAMPP running |
| 8080 | Jenkins | Jenkins is running here |
| 8081 | Jenkins | Jenkins also uses this |
| 9090 | Unknown | Something else is using this |
| 3000 | **Inside Container** | Not accessible from Windows |

## Available Ports for You

✅ **5000** - Typically free  
✅ **5001** - Alternative  
✅ **5002** - Alternative  
✅ **6000** - Usually free  
✅ **7000** - Usually free  
✅ **5555** - Fallback option  

## Testing the Connection

Once port-forward is running:

```powershell
# Test health endpoint
curl http://localhost:5000/api/health

# Expected response:
# {"status":"healthy","timestamp":"...","version":"1.0.0"}

# Test API message
curl http://localhost:5000/api/message

# Expected response:
# {"message":"Hello from CI/CD Pipeline!","timestamp":"..."}

# View homepage
start http://localhost:5000
```

## Common Errors and Solutions

### Error: "Site can't be reached"
**Cause**: Port-forward is not running  
**Solution**: Run `.\open-app.ps1` or `kubectl port-forward service/sample-web-app-service 5000:80`

### Error: "Unable to listen on port X"
**Cause**: Port is already in use  
**Solution**: Try a different port - 5001, 5002, 6000, 7000, etc.

### Error: "No pods found"
**Cause**: App is not deployed  
**Solution**: Check deployment with `kubectl get pods -l app=sample-web-app`

### "Server is running on port 3000" but can't access it
**Cause**: Port 3000 is INSIDE the container  
**Solution**: Use port-forward to access it from Windows

## Summary

- ❌ **Don't try to access port 3000 directly** - it's inside the container
- ❌ **Don't use ports 80, 8080** - Apache and Jenkins are using them
- ✅ **Use `.\open-app.ps1`** - automatic and easy
- ✅ **Or use port 5000** - `kubectl port-forward service/sample-web-app-service 5000:80`
- ✅ **Keep the port-forward window open** - closing it breaks the connection

**The app IS running! You just need port-forwarding to reach it from Windows.** 🎉
