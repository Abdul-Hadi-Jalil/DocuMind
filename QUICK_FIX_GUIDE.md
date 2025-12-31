# Quick Fix Guide for Signature Flow Issues

## Problem: 404 Error and CNN Graph Not Loading

### Root Cause
The backend server is not running, causing a 404 error when the Flutter app tries to call the API endpoint.

## Solution Steps:

### 1. Start the Backend Server

Open a terminal/command prompt and run:

```bash
# Navigate to backend directory
cd "C:\Users\TECH DEAL\Music\fyp\DocuMind-Backend"

# Start the FastAPI server
python main.py
```

**Expected Output:**
```
Starting FastAPI server...
...
7. POST /generate-signatures/ - Generate signature variants
INFO:     Uvicorn running on http://127.0.0.1:8000 (Press CTRL+C to quit)
```

### 2. Verify Backend is Running

Open your browser and visit: http://127.0.0.1:8000/docs

You should see the FastAPI interactive documentation page. This confirms the server is running.

### 3. Test the Endpoint

In the browser, go to the `/generate-signatures/` endpoint in the docs and try a test request:
- Click on "POST /generate-signatures/"
- Click "Try it out"
- Enter JSON: `{"name": "test", "mode": "hybrid"}`
- Click "Execute"
- You should see a 200 response with signature data

### 4. Run the Flutter App

Open a **NEW** terminal window (keep the backend running in the first terminal):

```bash
cd "C:\Users\TECH DEAL\Music\fyp\DocuMind"

flutter run
```

### 5. Use Signature Flow

1. In the Flutter app, navigate to Dashboard
2. Click on "Signature Flow" module
3. Enter a name (e.g., "John" or "eshmal")
4. Select a mode (Hybrid recommended)
5. Click "Generate 3 Signatures"

### Expected Results:

✅ **Success Indicators:**
- Left panel shows 3 signature images
- Right panel shows CNN Evaluation with:
  - Selected Mode: hybrid/dataset/procedural
  - Input Name: (your entered name)
  - Model Status: Loaded (with green dot) OR Not Loaded (if CNN model files are missing)
  - Confidence bar chart with 3 bars (Sig 1, Sig 2, Sig 3)

⚠️ **Note about CNN Model:**
- If "Model Status: Not Loaded", the app will still work but show default confidence scores (0.00)
- This is normal if the CNN model files (`cnn_signature_model.h5` and `label_classes.npy`) are missing or not properly trained
- The signature generation will still work without the CNN model

### Troubleshooting:

**If you still get 404 error:**
1. Check the backend terminal for any error messages
2. Verify the backend is running on port 8000
3. Check Flutter console for connection errors
4. Ensure no firewall is blocking port 8000

**If CNN model shows "Not Loaded":**
- This is OK - the app works without it
- To enable CNN predictions, ensure these files exist:
  - `DocuMind-Backend/cnn_signature_model.h5`
  - `DocuMind-Backend/label_classes.npy`
- The model should be trained using `cnn_train.py` if you want actual predictions

**If chart doesn't display:**
- Ensure signatures were generated successfully (left panel shows images)
- Check Flutter console for any errors
- Verify `fl_chart` package is installed: `flutter pub get`

### Files Modified:

1. ✅ Enhanced error messages in Flutter app
2. ✅ Improved backend error handling for CNN predictions
3. ✅ Better model status detection logic

### Next Steps:

1. Keep backend running: `python main.py` in DocuMind-Backend directory
2. Run Flutter app in separate terminal
3. Test signature generation
4. Check both panels display correctly

