# Complete Solution Guide: Fix Backend Server & CNN Model Issues

## 🔴 Problem Summary

1. **Backend Server Error**: "Backend server not found" at http://127.0.0.1:8000
2. **CNN Model Status**: Shows "Not Loaded" 
3. **Graph Not Displaying**: No confidence scores visible

---

## ✅ Solution 1: Start Backend Server (REQUIRED)

The backend server **must be running** before using the Flutter app. Follow these steps:

### Option A: Using Batch Script (Windows - Easiest)

1. Navigate to the backend directory:
   ```bash
   cd "C:\Users\TECH DEAL\Music\fyp\DocuMind-Backend"
   ```

2. Double-click `start_server.bat` OR run from terminal:
   ```bash
   start_server.bat
   ```

### Option B: Manual Start (Any OS)

1. Open a terminal/command prompt

2. Navigate to backend directory:
   ```bash
   cd "C:\Users\TECH DEAL\Music\fyp\DocuMind-Backend"
   ```

3. Install dependencies (if not already installed):
   ```bash
   pip install -r requirements.txt
   ```

4. Start the server:
   ```bash
   python main.py
   ```

### Expected Output:

```
Starting FastAPI server...
Checking initial Ollama server status...
Ollama server: Connection error: ...
...
7. POST /generate-signatures/ - Generate signature variants
INFO:     Uvicorn running on http://127.0.0.1:8000 (Press CTRL+C to quit)
INFO:     Started reloader process [xxxxx]
INFO:     Started server process [xxxxx]
INFO:     Waiting for application startup.
INFO:     Application startup complete.
```

**✅ Success Indicator**: You see `Uvicorn running on http://127.0.0.1:8000`

### Verify Server is Running:

Open your browser and visit: **http://127.0.0.1:8000/docs**

You should see the FastAPI interactive documentation page.

---

## ✅ Solution 2: Train CNN Model (Optional - For Actual Predictions)

**Note**: The model files (`cnn_signature_model.h5` and `label_classes.npy`) already exist in your backend directory, so the model is likely already trained. However, if you want to retrain it or if predictions aren't working:

### Option A: Using Batch Script (Windows)

1. Navigate to backend directory:
   ```bash
   cd "C:\Users\TECH DEAL\Music\fyp\DocuMind-Backend"
   ```

2. Double-click `train_cnn.bat` OR run from terminal:
   ```bash
   train_cnn.bat
   ```

### Option B: Manual Training (Any OS)

1. Open a terminal/command prompt

2. Navigate to backend directory:
   ```bash
   cd "C:\Users\TECH DEAL\Music\fyp\DocuMind-Backend"
   ```

3. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```

4. Run training script:
   ```bash
   python cnn_train.py
   ```

### Expected Training Output:

```
📂 Loading dataset from ...
📊 Found 300 entries in labels.csv
🖼️  Looking for images in ...
✅ Loaded 300 images
📦 Data shape: (300, 128, 128, 1)
🏋️ Training model...
Epoch 1/50
...
Training completed!
Model saved to: cnn_signature_model.h5
Classes saved to: label_classes.npy
```

**Training Time**: Depends on dataset size and your hardware (typically 5-30 minutes)

---

## 📋 Complete Workflow

### Step 1: Start Backend Server (Terminal 1)

```bash
cd "C:\Users\TECH DEAL\Music\fyp\DocuMind-Backend"
python main.py
```

**Keep this terminal window open!** The server must remain running.

### Step 2: Verify Backend is Running

- Open browser: http://127.0.0.1:8000/docs
- You should see the API documentation
- Test endpoint: Click on `POST /generate-signatures/` → "Try it out" → Enter `{"name": "test", "mode": "hybrid"}` → Execute

### Step 3: Run Flutter App (Terminal 2)

Open a **NEW** terminal window:

```bash
cd "C:\Users\TECH DEAL\Music\fyp\DocuMind"
flutter run
```

### Step 4: Use Signature Flow

1. In Flutter app → Navigate to Dashboard
2. Click "Signature Flow" module
3. Enter a name (e.g., "eshmal" or "John")
4. Select mode: "Hybrid" (recommended)
5. Click "Generate 3 Signatures"

---

## 🎯 Expected Results After Fix

### ✅ Success Indicators:

**Left Panel (Generate Signatures):**
- ✅ 3 signature images displayed
- ✅ Status: "3 outputs • saved in static/output"

**Right Panel (CNN Evaluation):**
- ✅ Selected Mode: hybrid/dataset/procedural
- ✅ Input Name: (your entered name)
- ✅ Model Status: **"Loaded"** (green dot) OR "Not Loaded" (if model files missing)
- ✅ **Confidence bar chart** showing 3 bars (Sig 1, Sig 2, Sig 3)
- ✅ Chart values range from 0.0 to 1.0 (0% to 100%)

### ⚠️ About "Model Status: Not Loaded"

**This is OK if:**
- The app still generates signatures successfully
- The chart displays (even with 0.00 values)
- You see "3 outputs • saved in static/output"

**To fix "Not Loaded" status:**
1. Ensure these files exist in `DocuMind-Backend/`:
   - `cnn_signature_model.h5`
   - `label_classes.npy`
2. If missing, run the training script (Solution 2 above)
3. Restart the backend server after training

---

## 🔧 Troubleshooting

### Issue: "Backend server not found" persists

**Solutions:**
1. ✅ Verify backend terminal shows: `Uvicorn running on http://127.0.0.1:8000`
2. ✅ Check browser: http://127.0.0.1:8000/docs should work
3. ✅ Check Windows Firewall isn't blocking port 8000
4. ✅ Ensure no other application is using port 8000
5. ✅ Check backend terminal for error messages

### Issue: Port 8000 already in use

**Solution:**
```bash
# Find what's using port 8000 (Windows)
netstat -ano | findstr :8000

# Kill the process (replace PID with actual process ID)
taskkill /PID <PID> /F

# Or change port in main.py line 580:
# uvicorn.run(app, host="127.0.0.1", port=8001, log_level="info")
# Then update Flutter: signature_flow_screen.dart line 74
```

### Issue: Python dependencies missing

**Solution:**
```bash
cd "C:\Users\TECH DEAL\Music\fyp\DocuMind-Backend"
pip install -r requirements.txt
```

### Issue: CNN Model training fails

**Check:**
- Dataset exists: `assets/signature_dataset/images/` and `labels.csv`
- TensorFlow installed: `pip install tensorflow`
- Sufficient disk space
- Check training script output for specific errors

### Issue: Chart not displaying in Flutter

**Solutions:**
1. ✅ Ensure `fl_chart` is installed: `flutter pub get` in DocuMind directory
2. ✅ Verify signatures generated successfully (left panel shows images)
3. ✅ Check Flutter console for errors
4. ✅ Restart Flutter app after generating signatures

---

## 📁 File Structure Reference

```
DocuMind-Backend/
├── main.py                    # FastAPI server (START THIS)
├── signature_logic.py         # Signature generation logic
├── cnn_train.py              # CNN training script (OPTIONAL)
├── cnn_predict.py            # CNN prediction script
├── cnn_signature_model.h5    # Trained model (generated by cnn_train.py)
├── label_classes.npy         # Class labels (generated by cnn_train.py)
├── requirements.txt          # Python dependencies
├── start_server.bat          # Quick start script (Windows)
├── train_cnn.bat             # Training script (Windows)
├── assets/
│   └── signature_dataset/
│       ├── images/           # 300 signature images
│       └── labels.csv        # Image labels
└── static/
    └── output/               # Generated signatures saved here
```

---

## 🚀 Quick Start Commands Summary

**Start Backend:**
```bash
cd "C:\Users\TECH DEAL\Music\fyp\DocuMind-Backend"
python main.py
```

**Train CNN (if needed):**
```bash
cd "C:\Users\TECH DEAL\Music\fyp\DocuMind-Backend"
python cnn_train.py
```

**Run Flutter:**
```bash
cd "C:\Users\TECH DEAL\Music\fyp\DocuMind"
flutter run
```

---

## ✅ Verification Checklist

After starting the backend:

- [ ] Terminal shows: `Uvicorn running on http://127.0.0.1:8000`
- [ ] Browser can access: http://127.0.0.1:8000/docs
- [ ] Test endpoint works in browser (POST /generate-signatures/)
- [ ] Flutter app no longer shows "Backend server not found"
- [ ] Signatures generate successfully
- [ ] Chart displays in CNN Evaluation panel
- [ ] Model Status shows correctly (Loaded/Not Loaded)

---

**Remember**: Always start the backend server before running the Flutter app!

