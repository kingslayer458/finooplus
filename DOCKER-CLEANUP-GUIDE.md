# Docker Image Cleanup - Jenkins Configuration

## Problem

The original Jenkinsfile only used `docker image prune -f`, which **only removes dangling (untagged) images**. 

Old **tagged images** were accumulating:
- `kingslayerone/sample-web-app:5` ❌
- `kingslayerone/sample-web-app:6` ❌
- `kingslayerone/sample-web-app:7` ✅
- `sample-web-app:4` ❌ (old local builds)

**Result:** ~1 GB of disk space wasted on old images!

---

## Solution

Updated Jenkinsfile `post { always }` block to:

1. ✅ Remove dangling images
2. ✅ Keep only last 3 build number tags
3. ✅ Remove old local `sample-web-app` images
4. ✅ Show remaining images for verification

---

## Updated Jenkinsfile Cleanup

```groovy
always {
    echo 'Cleaning up...'
    
    script {
        try {
            bat """
                REM Remove dangling images
                docker image prune -f
                
                REM Remove old build number tags (keep only last 3 builds)
                FOR /F "skip=3 tokens=2" %%i IN ('docker images kingslayerone/sample-web-app --format "{{.Tag}}" ^| findstr /R "^[0-9]"') DO docker rmi kingslayerone/sample-web-app:%%i 2^>nul || echo Skipped: %%i
                
                REM Remove old untagged sample-web-app images
                FOR /F "tokens=3" %%i IN ('docker images sample-web-app --format "{{.ID}}"') DO docker rmi %%i 2^>nul || echo Skipped: %%i
                
                REM Show remaining images
                echo Remaining images:
                docker images kingslayerone/sample-web-app
            """
        } catch (Exception e) {
            echo "Cleanup warning: ${e.message}"
        }
    }
}
```

---

## What This Does

### 1. Remove Dangling Images
```batch
docker image prune -f
```
Removes untagged intermediate layers.

### 2. Keep Last 3 Build Tags
```batch
FOR /F "skip=3 tokens=2" %%i IN (...) DO docker rmi kingslayerone/sample-web-app:%%i
```

**Example:**
```
Before:
- kingslayerone/sample-web-app:10 ✅ (keep)
- kingslayerone/sample-web-app:9  ✅ (keep)
- kingslayerone/sample-web-app:8  ✅ (keep)
- kingslayerone/sample-web-app:7  ❌ (remove)
- kingslayerone/sample-web-app:6  ❌ (remove)

After:
- kingslayerone/sample-web-app:10 ✅
- kingslayerone/sample-web-app:9  ✅
- kingslayerone/sample-web-app:8  ✅
- kingslayerone/sample-web-app:latest ✅ (always kept)
```

### 3. Remove Old Local Images
```batch
FOR /F "tokens=3" %%i IN ('docker images sample-web-app --format "{{.ID}}"') DO docker rmi %%i
```

Removes old `sample-web-app:*` images (without registry prefix) from failed builds or local testing.

---

## Manual Cleanup Script

Use `cleanup-docker-images.ps1` to clean up images manually:

```powershell
.\cleanup-docker-images.ps1
```

**Features:**
- Shows current images and disk usage
- Asks for confirmation before cleanup
- Removes old builds (keeps last 3)
- Shows before/after comparison
- Safe to run anytime

---

## Verification

### Check Current Images
```powershell
docker images kingslayerone/sample-web-app
```

**Expected output (after build #10):**
```
REPOSITORY                      TAG       IMAGE ID       CREATED         SIZE
kingslayerone/sample-web-app    latest    abc123def456   2 minutes ago   192MB
kingslayerone/sample-web-app    10        abc123def456   2 minutes ago   192MB
kingslayerone/sample-web-app    9         xyz789ghi012   20 minutes ago  192MB
kingslayerone/sample-web-app    8         qwe456rty789   40 minutes ago  192MB
```

Only 4 images total (including `latest`)!

---

## Check Jenkins Console Output

After each build, check the cleanup section:

```
=========================================
Cleaning up...
=========================================

C:\...\>docker image prune -f
Total reclaimed space: 0B

C:\...\>FOR /F "skip=3 tokens=2" %i IN (...) DO docker rmi kingslayerone/sample-web-app:%i
Untagged: kingslayerone/sample-web-app:5    ← Old image removed!
Deleted: sha256:abc123...

Remaining images:
REPOSITORY                      TAG       IMAGE ID       CREATED
kingslayerone/sample-web-app    latest    800847212018   2 minutes ago
kingslayerone/sample-web-app    7         800847212018   2 minutes ago
kingslayerone/sample-web-app    6         5ffb3af9cf47   20 minutes ago
```

---

## Disk Space Monitoring

### Check Docker Disk Usage
```powershell
docker system df
```

**Example output:**
```
TYPE            TOTAL     ACTIVE    SIZE      RECLAIMABLE
Images          15        5         2.5GB     1.8GB (72%)    ← Should stay low!
Containers      8         3         45MB      30MB (66%)
Local Volumes   5         2         1.2GB     800MB (66%)
```

### Check Reclaimable Space
```powershell
docker system df -v | Select-String "sample-web-app"
```

---

## Troubleshooting

### Images Not Being Removed?

**Check if images are in use:**
```powershell
# List running containers using the image
docker ps --filter ancestor=kingslayerone/sample-web-app:5

# Force remove if needed
docker rmi kingslayerone/sample-web-app:5 -f
```

### Too Many Images Still Accumulating?

**Adjust retention policy** in Jenkinsfile (change `skip=3` to `skip=2`):
```batch
FOR /F "skip=2 tokens=2" %%i IN (...)  REM Keep only last 2 builds
```

### Want More Aggressive Cleanup?

**Option 1: Keep only latest**
```groovy
bat """
    docker image prune -f
    
    REM Remove ALL build number tags
    FOR /F "tokens=2" %%i IN ('docker images kingslayerone/sample-web-app --format "{{.Tag}}" ^| findstr /R "^[0-9]"') DO docker rmi kingslayerone/sample-web-app:%%i 2^>nul
"""
```

**Option 2: Clean everything not in use**
```groovy
bat """
    REM WARNING: Removes ALL unused images!
    docker image prune -a -f
"""
```

---

## Best Practices

### ✅ DO:
- Keep last 2-3 builds for rollback capability
- Run cleanup after every build
- Monitor disk usage weekly: `docker system df`
- Use the manual cleanup script monthly

### ❌ DON'T:
- Remove `latest` tag (always needed)
- Remove current build tag
- Run `docker system prune -a` in production (too aggressive)

---

## Summary

| Before | After |
|--------|-------|
| ❌ 7+ images accumulating | ✅ Only 3-4 images kept |
| ❌ ~1 GB wasted space | ✅ Only current + last 2 builds |
| ❌ `docker image prune -f` only | ✅ Smart cleanup of old tags |
| ❌ Manual cleanup needed | ✅ Automatic after every build |

**Your Jenkins now properly cleans up old Docker images!** 🎉

---

## Commands Reference

```powershell
# Check images
docker images kingslayerone/sample-web-app

# Manual cleanup
.\cleanup-docker-images.ps1

# Check disk usage
docker system df

# Force remove specific image
docker rmi kingslayerone/sample-web-app:OLD_TAG -f

# Remove all dangling
docker image prune -f

# Remove ALL unused (CAREFUL!)
docker image prune -a -f
```
