# 🔄 Restart Backend Server - Step by Step

## Problem
The server is running, but the `/generate-signatures/` endpoint returns 404. This means the server needs to be restarted to load the latest code.

---

## ✅ Solution: Restart the Server

### Step 1: Stop the Current Server

**Find the running Python process:**

1. Open Command Prompt or PowerShell
2. Run:
   ```bash
   netstat -ano | findstr :8000
   ```
3. Note the PID (last number, e.g., 19148)

**Stop the process:**

```bash
taskkill /PID 19148 /F
```

Replace `19148` with your actual PID number.

---

### Step 2: Start the Server Fresh

**Option A: Using Batch Script (Easiest)**

1. Open File Explorer
2. Navigate to: `C:\Users\TECH DEAL\Music\fyp\DocuMind-Backend`
3. Double-click: **`start_server.bat`**

**Option B: Manual Start**

1. Open Command Prompt
2. Run:
   ```bash
   cd "C:\Users\TECH DEAL\Music\fyp\DocuMind-Backend"
   python main.py
   ```

---

### Step 3: Verify Server Started Correctly

**Look for this in the terminal:**
```
Starting FastAPI server...
...
7. POST /generate-signatures/ - Generate signature variants
INFO:     Uvicorn running on http://127.0.0.1:8000
```

**Test in browser:**
- Go to: http://127.0.0.1:8000/docs
- You should see the API documentation
- Look for `POST /generate-signatures/` in the list

---

### Step 4: Test the Endpoint

In the browser at http://127.0.0.1:8000/docs:

1. Click on **`POST /generate-signatures/`**
2. Click **"Try it out"**
3. Enter this JSON:
   ```json
   {
     "name": "test",
     "mode": "hybrid"
   }
   ```
4. Click **"Execute"**

**✅ Success:** You should see a 200 response with signature data

**❌ Failure:** If you still get 404, the server didn't restart properly

---

## 🎯 After Server Restarts

1. **Keep the terminal open** (don't close it)
2. **Go back to Flutter app**
3. **Try generating signatures again**
4. The error should be fixed!

---

## ⚠️ Important Notes

- **Keep the server terminal open** - closing it stops the server
- **Restart server after code changes** - the server needs to reload
- **One server instance only** - don't run multiple instances

---

## 📋 Quick Commands Summary

**Stop server:**
```bash
taskkill /PID <PID> /F
```

**Start server:**
```bash
cd "C:\Users\TECH DEAL\Music\fyp\DocuMind-Backend"
python main.py
```

**Verify:**
- Browser: http://127.0.0.1:8000/docs
- Should see API documentation with all endpoints

