# 🚀 How to Run DocuMind Application

## Quick Start (2 Terminals Required)

### Terminal 1: Backend Server (FastAPI)

**Option A: Using the batch file (Easiest)**
```bash
cd "C:\Users\TECH DEAL\Music\fyp\DocuMind-Backend"
start_server.bat
```

**Option B: Manual start**
```bash
cd "C:\Users\TECH DEAL\Music\fyp\DocuMind-Backend"
python -m pip install -r requirements.txt
python main.py
```

**✅ Success:** You should see:
```
INFO:     Uvicorn running on http://127.0.0.1:8001 (Press CTRL+C to quit)
```

**⚠️ Keep this terminal open!** The backend must stay running.

---

### Terminal 2: Flutter Frontend

```bash
cd "C:\Users\TECH DEAL\Music\fyp\DocuMind"
flutter pub get
flutter run -d chrome
```

**Or for desktop:**
```bash
flutter run -d windows
```

**Or check available devices:**
```bash
flutter devices
flutter run -d <device-id>
```

---

## Detailed Steps

### Step 1: Install Backend Dependencies (First Time Only)

```bash
cd "C:\Users\TECH DEAL\Music\fyp\DocuMind-Backend"
python -m pip install -r requirements.txt
```

**Required packages:**
- fastapi
- uvicorn
- python-multipart
- pillow
- opencv-python
- numpy
- requests
- openai
- PyJWT
- ollama
- jinja2

### Step 2: Start Backend Server

```bash
cd "C:\Users\TECH DEAL\Music\fyp\DocuMind-Backend"
python main.py
```

**Backend runs on:** `http://127.0.0.1:8001`

**Verify it's working:**
- Open browser: http://127.0.0.1:8001/docs
- You should see FastAPI interactive documentation

### Step 3: Install Flutter Dependencies (First Time Only)

```bash
cd "C:\Users\TECH DEAL\Music\fyp\DocuMind"
flutter pub get
```

### Step 4: Run Flutter App

**For Web (Chrome):**
```bash
flutter run -d chrome
```

**For Windows Desktop:**
```bash
flutter run -d windows
```

**For Android:**
```bash
flutter run -d android
```

---

## API Endpoints

The backend provides these endpoints:

1. **GET** `/health` - Health check
2. **POST** `/upload-image/` - OCR image upload
3. **POST** `/generate-image/` - Generate images with AI
4. **POST** `/generate-signatures/` - Generate signature variants
5. **GET** `/signature-ui/` - Signature generation UI (HTML)
6. **GET** `/api/me` - Get current user info (requires auth token)

**Base URL:** `http://127.0.0.1:8001`

---

## Troubleshooting

### ❌ Backend won't start

**Error: "ModuleNotFoundError"**
```bash
cd "C:\Users\TECH DEAL\Music\fyp\DocuMind-Backend"
pip install -r requirements.txt
```

**Error: "Port 8001 already in use"**
- Close other applications using port 8001
- Or change port in `main.py` (line 728): `uvicorn.run(app, host="127.0.0.1", port=8001, ...)`
- Update `DocuMind/lib/config/api_config.dart` to match

### ❌ Flutter won't compile

**Error: "Package not found"**
```bash
cd "C:\Users\TECH DEAL\Music\fyp\DocuMind"
flutter clean
flutter pub get
flutter run
```

**Error: "Backend unreachable"**
- Verify backend is running: http://127.0.0.1:8001/docs
- Check `api_config.dart` has correct URL: `http://127.0.0.1:8001`
- Check Windows Firewall isn't blocking port 8001

### ❌ Port mismatch

**If backend runs on different port:**

1. Edit `DocuMind-Backend/main.py` (line 728):
   ```python
   uvicorn.run(app, host="127.0.0.1", port=YOUR_PORT, ...)
   ```

2. Edit `DocuMind/lib/config/api_config.dart` (line 11):
   ```dart
   static const String baseUrl = 'http://127.0.0.1:YOUR_PORT';
   ```

3. Restart both backend and Flutter app

---

## Quick Command Reference

```bash
# ============================================
# TERMINAL 1: Backend Server
# ============================================
cd "C:\Users\TECH DEAL\Music\fyp\DocuMind-Backend"
python main.py

# ============================================
# TERMINAL 2: Flutter Frontend
# ============================================
cd "C:\Users\TECH DEAL\Music\fyp\DocuMind"
flutter pub get
flutter run -d chrome
```

---

## Success Checklist

- [ ] Backend server running on port 8001
- [ ] Browser can access http://127.0.0.1:8001/docs
- [ ] Flutter dependencies installed (`flutter pub get`)
- [ ] Flutter app running
- [ ] Can navigate to Dashboard
- [ ] Can access all modules (OCR, Image Generation, PDF Chat, Signature Flow)
- [ ] No "backend not found" errors

---

## Notes

- **Backend must run first** before starting Flutter app
- **Keep both terminals open** while using the application
- **Backend port:** 8001 (configured in `main.py`)
- **Frontend API URL:** `http://127.0.0.1:8001` (configured in `api_config.dart`)
- For production, change `allow_origins=["*"]` in `main.py` to specific domains

---

**Need help?** Check the terminal output for error messages and refer to the troubleshooting section above.

