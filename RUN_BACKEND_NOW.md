# 🚀 RUN BACKEND SERVER NOW - Step by Step

## Current Status Check

I see Python is installed (version 3.12.8) and there might be a Python process running. Let's start the backend server properly.

---

## ✅ METHOD 1: Using Batch Script (Easiest)

### Step 1: Open File Explorer
Navigate to:
```
C:\Users\TECH DEAL\Music\fyp\DocuMind-Backend
```

### Step 2: Double-Click the File
Double-click: **`start_server.bat`**

A command window will open and start the server automatically.

**✅ Success:** You'll see `Uvicorn running on http://127.0.0.1:8000`

---

## ✅ METHOD 2: Using Command Prompt (Manual)

### Step 1: Open Command Prompt or PowerShell

Press `Windows Key + R`, type `cmd` and press Enter

### Step 2: Navigate to Backend Directory

Copy and paste these commands one by one:

```bash
cd "C:\Users\TECH DEAL\Music\fyp\DocuMind-Backend"
```

### Step 3: Start the Server

```bash
python main.py
```

**✅ Success:** You'll see:
```
Starting FastAPI server...
...
INFO:     Uvicorn running on http://127.0.0.1:8000 (Press CTRL+C to quit)
```

**⚠️ IMPORTANT:** Keep this window open! Don't close it.

---

## ✅ METHOD 3: Using PowerShell (Current Terminal)

If you're already in PowerShell, run:

```powershell
cd "C:\Users\TECH DEAL\Music\fyp\DocuMind-Backend"
python main.py
```

---

## 🔍 Verify Server is Running

### Test 1: Check Browser
Open your web browser and go to:
```
http://127.0.0.1:8000/docs
```

**✅ Success:** You should see a page with "FastAPI" and API documentation

**❌ Failure:** If you see "This site can't be reached", the server is NOT running

### Test 2: Check Terminal Output
Look at the terminal where you ran `python main.py`

**✅ Success:** You see `Uvicorn running on http://127.0.0.1:8000`

**❌ Failure:** You see error messages (share them for help)

---

## 🎯 After Server Starts

1. **Keep the terminal window open** (don't close it)
2. **Open a NEW terminal** for Flutter app
3. Run Flutter app:
   ```bash
   cd "C:\Users\TECH DEAL\Music\fyp\DocuMind"
   flutter run
   ```
4. Try generating signatures again

---

## ❌ Common Errors & Fixes

### Error: "python is not recognized"
**Fix:** Python is not in PATH. Try:
```bash
py main.py
```
or
```bash
python3 main.py
```

### Error: "No module named 'fastapi'"
**Fix:** Install dependencies:
```bash
cd "C:\Users\TECH DEAL\Music\fyp\DocuMind-Backend"
pip install -r requirements.txt
```

### Error: "Address already in use"
**Fix:** Port 8000 is already taken. Either:
- Close the other application using port 8000
- Or change port in `main.py` line 580 to `port=8001`

### Error: "ModuleNotFoundError: No module named 'signature_logic'"
**Fix:** Make sure you're in the `DocuMind-Backend` directory when running

---

## 📞 Still Having Issues?

Share the exact error message you see in the terminal, and I'll help you fix it!

