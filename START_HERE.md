# 🚀 START HERE - Quick Fix Guide

## ⚠️ Current Issue
- **Error**: "Backend server not found" at http://127.0.0.1:8000
- **Solution**: Start the backend server before running Flutter app

---

## ✅ QUICK FIX (3 Steps)

### Step 1: Start Backend Server

**Windows (Easiest):**
```bash
cd "C:\Users\TECH DEAL\Music\fyp\DocuMind-Backend"
start_server.bat
```

**Or Manually:**
```bash
cd "C:\Users\TECH DEAL\Music\fyp\DocuMind-Backend"
python main.py
```

**✅ Wait for:** `Uvicorn running on http://127.0.0.1:8000`

### Step 2: Verify Server (Optional but Recommended)

Open browser: **http://127.0.0.1:8000/docs**

You should see the API documentation page.

### Step 3: Run Flutter App

**Open a NEW terminal window:**

```bash
cd "C:\Users\TECH DEAL\Music\fyp\DocuMind"
flutter run
```

---

## 🎯 Expected Result

After clicking "Generate 3 Signatures":
- ✅ Left panel: 3 signature images appear
- ✅ Right panel: CNN Evaluation shows data and chart
- ✅ No error messages

---

## 📋 CNN Model Training (Optional)

**Only needed if:** "Model Status: Not Loaded" AND you want actual predictions

**Windows:**
```bash
cd "C:\Users\TECH DEAL\Music\fyp\DocuMind-Backend"
train_cnn.bat
```

**Or Manually:**
```bash
cd "C:\Users\TECH DEAL\Music\fyp\DocuMind-Backend"
python cnn_train.py
```

**Training time:** 5-30 minutes (depends on dataset and hardware)

---

## 🔧 Still Having Issues?

See **COMPLETE_SOLUTION_GUIDE.md** for detailed troubleshooting.

---

**Remember**: Backend server MUST be running before using the Flutter app!

