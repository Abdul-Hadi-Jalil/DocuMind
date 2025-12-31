# 🚀 How to Run the Flutter App Now

## Prerequisites

1. ✅ Backend server running on port **8001**
2. ✅ Flutter dependencies installed
3. ✅ All code changes applied (already done!)

---

## Step-by-Step Instructions

### Step 1: Start Backend Server (Terminal 1)

**Open Command Prompt or PowerShell:**

```bash
cd "C:\Users\TECH DEAL\Music\fyp\DocuMind-Backend"
python main.py
```

**Important:** Make sure your backend is configured to run on port **8001** (not 8000).

**✅ Success Indicator:**
```
Starting FastAPI server...
...
INFO:     Uvicorn running on http://127.0.0.1:8001 (Press CTRL+C to quit)
```

**⚠️ Keep this terminal window open!** Don't close it while using the app.

---

### Step 2: Verify Backend is Running

**Open your browser and go to:**
```
http://127.0.0.1:8001/docs
```

You should see the FastAPI interactive documentation page.

**Test the endpoint:**
- Click on `POST /generate-signatures/`
- Click "Try it out"
- Enter JSON: `{"name": "test", "mode": "hybrid"}`
- Click "Execute"
- Should return 200 with signature data

---

### Step 3: Install Flutter Dependencies

**Open a NEW terminal window:**

```bash
cd "C:\Users\TECH DEAL\Music\fyp\DocuMind"
flutter pub get
```

This ensures all dependencies (including `fl_chart`) are installed.

---

### Step 4: Run Flutter App

**In the same terminal (or new one):**

```bash
cd "C:\Users\TECH DEAL\Music\fyp\DocuMind"
flutter run
```

**Or for web:**
```bash
flutter run -d chrome
```

**Or for a specific device:**
```bash
flutter devices  # See available devices
flutter run -d <device-id>
```

---

### Step 5: Test Signature Flow

1. **Navigate to Dashboard**
   - The app should open to the Dashboard or Landing page
   - If on Landing page, sign in first

2. **Open Signature Flow Module**
   - Click on the "Signature Flow" module card (4th module)
   - Should navigate to the Signature Flow screen

3. **Generate Signatures**
   - Enter a name (e.g., "test" or "john")
   - Select mode: "Hybrid" (recommended)
   - Click "Generate 3 Signatures"

4. **Expected Results:**
   - ✅ No "backend not found" error
   - ✅ Left panel: 3 signature images appear
   - ✅ Right panel: CNN Evaluation panel shows:
     - Selected Mode: hybrid
     - Input Name: (your entered name)
     - Model Status: "Loaded" or "Not Loaded on Backend"
     - Confidence bar chart with 3 bars

---

## Quick Commands Summary

```bash
# Terminal 1 - Backend Server
cd "C:\Users\TECH DEAL\Music\fyp\DocuMind-Backend"
python main.py

# Terminal 2 - Flutter App
cd "C:\Users\TECH DEAL\Music\fyp\DocuMind"
flutter pub get
flutter run
```

---

## Troubleshooting

### ❌ Error: "Backend unreachable at http://127.0.0.1:8001"

**Solutions:**
1. Check Terminal 1 - is backend server running?
2. Verify backend is on port 8001 (not 8000)
3. Check browser: http://127.0.0.1:8001/docs should work
4. Check Windows Firewall isn't blocking port 8001

### ❌ Error: "ModuleNotFoundError" in backend

**Solution:**
```bash
cd "C:\Users\TECH DEAL\Music\fyp\DocuMind-Backend"
pip install -r requirements.txt
```

### ❌ Error: "fl_chart" not found in Flutter

**Solution:**
```bash
cd "C:\Users\TECH DEAL\Music\fyp\DocuMind"
flutter pub get
```

### ❌ Backend runs on different port

**If your backend runs on a different port (not 8001):**

Edit this file:
```
DocuMind/lib/config/api_config.dart
```

Change line 11:
```dart
static const String baseUrl = 'http://127.0.0.1:8001';  // Change to your port
```

Then restart Flutter app.

### ❌ Flutter app doesn't compile

**Solution:**
```bash
cd "C:\Users\TECH DEAL\Music\fyp\DocuMind"
flutter clean
flutter pub get
flutter run
```

---

## Success Checklist

- [ ] Backend server running on port 8001
- [ ] Browser can access http://127.0.0.1:8001/docs
- [ ] Flutter dependencies installed (`flutter pub get`)
- [ ] Flutter app running
- [ ] Signature Flow module opens without errors
- [ ] Can generate signatures successfully
- [ ] No "backend not found" error
- [ ] CNN Evaluation panel displays correctly

---

## What Changed?

✅ All modules now use port **8001** (was 8000)
✅ Centralized API configuration (`api_config.dart`)
✅ Better error messages
✅ CNN model status improvements
✅ All modules use shared config (no more port mismatches)

---

**Remember:** 
- Keep backend server running (Terminal 1)
- Flutter app runs separately (Terminal 2)
- Both need to be running at the same time!

