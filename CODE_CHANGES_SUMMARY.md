# Code Changes Summary - Backend URL Configuration

## Overview
Fixed the Flutter app to use port 8001 instead of 8000, and created a shared API configuration to prevent port mismatches across all modules.

---

## Files Changed

### 1. NEW FILE: `DocuMind/lib/config/api_config.dart`
**Purpose:** Centralized API configuration for all modules

**Key Changes:**
- Created shared `ApiConfig` class with `baseUrl = 'http://127.0.0.1:8001'`
- Added convenience getters for all API endpoints:
  - `healthUrl`
  - `generateSignaturesUrl`
  - `uploadImageUrl`
  - `generateImageUrl`

**Usage:**
```dart
import 'package:documind/config/api_config.dart';

// Use in any module:
ApiConfig.baseUrl  // 'http://127.0.0.1:8001'
ApiConfig.generateSignaturesUrl  // 'http://127.0.0.1:8001/generate-signatures/'
```

---

### 2. `DocuMind/lib/features/signature_flow/signature_flow_screen.dart`

#### Line 5: Added import
```dart
import 'package:documind/config/api_config.dart';
```

#### Line 74: Changed hardcoded URL
**Before:**
```dart
Uri.parse('http://127.0.0.1:8000/generate-signatures/'),
```

**After:**
```dart
Uri.parse(ApiConfig.generateSignaturesUrl),
```

#### Lines 113-122: Improved error handling
**Before:**
```dart
} else {
  String errorMsg = 'Error ${response.statusCode}: ${response.body}';
  if (response.statusCode == 404) {
    errorMsg = 'Backend server not found. Please ensure the backend is running on http://127.0.0.1:8000';
  }
  _showError(errorMsg);
}
} catch (e) {
  String errorMsg = 'Connection error: $e\n\nPlease ensure:\n1. Backend server is running (python main.py in DocuMind-Backend)\n2. Server is accessible at http://127.0.0.1:8000';
  _showError(errorMsg);
```

**After:**
```dart
} else {
  // Show real error message with status code
  String errorBody = response.body;
  try {
    final errorJson = jsonDecode(errorBody);
    if (errorJson.containsKey('detail')) {
      errorBody = errorJson['detail'];
    }
  } catch (_) {
    // If JSON parsing fails, use raw body
  }
  
  String errorMsg = 'Error ${response.statusCode}: $errorBody';
  if (response.statusCode == 404) {
    errorMsg = 'Backend unreachable at ${ApiConfig.baseUrl}\n\nPlease ensure:\n1. Backend server is running\n2. Server is accessible at ${ApiConfig.baseUrl}';
  }
  _showError(errorMsg);
}
} catch (e) {
  // Connection error - backend is not reachable
  String errorMsg = 'Backend unreachable at ${ApiConfig.baseUrl}\n\nError: $e\n\nPlease ensure:\n1. Backend server is running (python main.py in DocuMind-Backend)\n2. Server is accessible at ${ApiConfig.baseUrl}';
  _showError(errorMsg);
```

#### Lines 797-801: Improved CNN model status detection
**Before:**
```dart
final isModelLoaded = _signatureResult != null && 
                     _signatureResult!.predictions.isNotEmpty &&
                     !_signatureResult!.predictions.any((p) => 
                       p.toLowerCase().contains('not loaded') || 
                       p.toLowerCase().contains('error'));
```

**After:**
```dart
final hasPredictions = _signatureResult != null && _signatureResult!.predictions.isNotEmpty;
final hasErrorMessages = hasPredictions && _signatureResult!.predictions.any((p) => 
  p.toLowerCase().contains('not loaded') || 
  p.toLowerCase().contains('error') ||
  p.toLowerCase().contains('cnn model'));
final isModelLoaded = hasPredictions && !hasErrorMessages;
```

#### Line 857: Updated Model Status display
**Before:**
```dart
value: isModelLoaded ? 'Loaded' : 'Not Loaded',
```

**After:**
```dart
value: isModelLoaded ? 'Loaded' : 'Not Loaded on Backend',
```

#### Lines 888-897: Added CNN model warning message
**Before:**
```dart
if (_signatureResult != null && _signatureImages.isNotEmpty) ...[
  const SizedBox(height: 12),
  const Text(
    'Confidence graph is based on CNN predicted probabilities (if available). Low confidence is shown as "Unknown".',
    style: TextStyle(
      fontSize: 11,
      color: Color(0xFF888888),
    ),
  ),
],
```

**After:**
```dart
if (_signatureResult != null && _signatureImages.isNotEmpty) ...[
  const SizedBox(height: 12),
  if (!isModelLoaded)
    Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.orange.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: const Text(
        'CNN model not loaded on backend. Signatures are displayed, but confidence scores are default values.',
        style: TextStyle(
          fontSize: 11,
          color: Colors.orange,
        ),
      ),
    ),
  const Text(
    'Confidence graph is based on CNN predicted probabilities (if available). Low confidence is shown as "Unknown".',
    style: TextStyle(
      fontSize: 11,
      color: Color(0xFF888888),
    ),
  ),
],
```

---

### 3. `DocuMind/lib/features/ocr/ocr_screen.dart`

#### Line 6: Added import
```dart
import 'package:documind/config/api_config.dart';
```

#### Line 96: Changed hardcoded URL
**Before:**
```dart
const String backendUrl = "http://127.0.0.1:8000/upload-image/";
```

**After:**
```dart
final String backendUrl = ApiConfig.uploadImageUrl;
```

---

### 4. `DocuMind/lib/features/image_generation/image_generation_screen.dart`

#### Line 6: Added import
```dart
import 'package:documind/config/api_config.dart';
```

#### Line 43: Changed hardcoded URL
**Before:**
```dart
Uri.parse('http://127.0.0.1:8000/generate-image/'),
```

**After:**
```dart
Uri.parse(ApiConfig.generateImageUrl),
```

---

## Summary of Changes

1. ✅ Created shared `ApiConfig` class with base URL set to `http://127.0.0.1:8001`
2. ✅ Updated Signature Flow module to use `ApiConfig.generateSignaturesUrl`
3. ✅ Updated OCR module to use `ApiConfig.uploadImageUrl`
4. ✅ Updated Image Generation module to use `ApiConfig.generateImageUrl`
5. ✅ Improved error handling in Signature Flow:
   - Shows real error messages with status codes
   - Better connection error messages with correct URL
   - Parses JSON error responses
6. ✅ Enhanced CNN model status:
   - Shows "Not Loaded on Backend" instead of just "Not Loaded"
   - Better detection of model loading status
   - Added warning message when CNN model is not loaded but signatures are displayed
7. ✅ All modules now use the same base URL configuration

---

## How to Change Backend URL in Future

Simply edit **ONE file**: `DocuMind/lib/config/api_config.dart`

Change this line:
```dart
static const String baseUrl = 'http://127.0.0.1:8001';
```

All modules will automatically use the new URL!

---

## Testing Checklist

- [x] Signature Flow module connects to port 8001
- [x] OCR module connects to port 8001
- [x] Image Generation module connects to port 8001
- [x] Error messages show correct URL (8001)
- [x] CNN model status displays correctly
- [x] Warning message appears when CNN model not loaded
- [x] Signatures still display even if CNN model not loaded

