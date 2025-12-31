import os
import csv
import time
import random
from datetime import datetime

import cv2
import numpy as np
import pandas as pd
from PIL import Image, ImageDraw, ImageFont, ImageFilter

# ---------------- Paths ----------------
BASE_DIR = os.path.dirname(os.path.abspath(__file__))

DATASET_ROOT = os.path.join(BASE_DIR, "assets", "signature_dataset")
LABELS_CSV = os.path.join(DATASET_ROOT, "labels.csv")

FONT_DIR = os.path.join(BASE_DIR, "assets", "fonts")
OUTPUT_DIR = os.path.join(BASE_DIR, "static", "output")
os.makedirs(OUTPUT_DIR, exist_ok=True)

LOG_PATH = os.path.join(OUTPUT_DIR, "generation_log.csv")

# CNN files (optional)
CNN_MODEL_PATH = os.path.join(BASE_DIR, "cnn_signature_model.h5")
CNN_CLASSES_PATH = os.path.join(BASE_DIR, "label_classes.npy")

# ---------------- Load fonts ----------------
FONT_PATHS = []
if os.path.isdir(FONT_DIR):
    for f in os.listdir(FONT_DIR):
        if f.lower().endswith(".ttf") or f.lower().endswith(".otf"):
            FONT_PATHS.append(os.path.join(FONT_DIR, f))

# ---------------- Load dataset index (name -> list of image paths) ----------------
DATASET_INDEX = {}
if os.path.exists(LABELS_CSV):
    try:
        df = pd.read_csv(LABELS_CSV)
        for _, row in df.iterrows():
            filename = str(row["filename"]).strip()
            person = str(row["name"]).strip().lower()
            full_path = os.path.join(DATASET_ROOT, filename)
            if os.path.exists(full_path):
                DATASET_INDEX.setdefault(person, []).append(full_path)
    except Exception as e:
        print("Dataset load error:", e)

# ---------------- Logging ----------------
def _ensure_log_header():
    if not os.path.exists(LOG_PATH):
        with open(LOG_PATH, "w", newline="", encoding="utf-8") as f:
            writer = csv.writer(f)
            writer.writerow([
                "timestamp", "request_id", "input_name", "mode",
                "sample_index", "output_file",
                "source_path",     # dataset mode only
                "text_form",       # procedural only
                "font_file"        # procedural only
            ])

# ---------------- Signature helpers ----------------

def signature_text_forms(name: str):
    """
    Create 3 text variants from a name:
    1) full (or shortened) name
    2) initials emphasis
    3) stylized short form
    """
    name = name.strip()
    if not name:
        return ["", "", ""]

    parts = name.split()
    first = parts[0]
    last = parts[-1] if len(parts) > 1 else ""

    # variant 1: full-ish
    v1 = name if len(name) <= 18 else (first + " " + last)

    # variant 2: initial + last
    if last:
        v2 = f"{first[0]}. {last}"
    else:
        v2 = first

    # variant 3: shortened + flourish dot
    v3 = (first[:max(3, len(first)//2)] + (last[:3] if last else "")) + "."
    return [v1, v2, v3]


def render_name(text, font_path=None, canvas_size=(600, 250)):
    """
    Render text using PIL on a black background with white ink.
    """
    img = Image.new("L", canvas_size, 0)  # black bg
    draw = ImageDraw.Draw(img)

    # choose font size
    font_size = random.randint(70, 110)
    if font_path and os.path.exists(font_path):
        try:
            font = ImageFont.truetype(font_path, font_size)
        except Exception:
            font = ImageFont.load_default()
    else:
        font = ImageFont.load_default()

    # center text
    bbox = draw.textbbox((0, 0), text, font=font)
    w = bbox[2] - bbox[0]
    h = bbox[3] - bbox[1]

    x = (canvas_size[0] - w) // 2
    y = (canvas_size[1] - h) // 2

    draw.text((x, y), text, fill=255, font=font)

    return np.array(img)


def emphasize_initial(img):
    """
    Make the first letter slightly bolder by dilation.
    """
    # simple global dilation sometimes works fine for demo
    k = random.choice([1, 2])
    if k == 1:
        return img
    kernel = np.ones((2, 2), np.uint8)
    return cv2.dilate(img, kernel, iterations=1)


def random_affine(img):
    """
    Apply small shear + translation.
    """
    h, w = img.shape
    shear = random.uniform(-0.15, 0.15)
    tx = random.uniform(-20, 20)
    ty = random.uniform(-10, 10)

    M = np.float32([[1, shear, tx],
                    [0, 1,     ty]])
    out = cv2.warpAffine(img, M, (w, h), borderValue=0)
    return out


def baseline_wobble(img, strength=4.0):
    """
    Wobble rows slightly to mimic handwriting baseline variation.
    """
    h, w = img.shape
    out = np.zeros_like(img)

    for y in range(h):
        shift = int(strength * np.sin(2 * np.pi * y / random.uniform(60, 120)))
        out[y] = np.roll(img[y], shift)

    return out


def pressure_effect(img):
    """
    Simulate pen pressure: random blur + contrast adjust.
    """
    out = img.copy()
    if random.random() < 0.7:
        out = cv2.GaussianBlur(out, (3, 3), 0)

    # contrast stretch
    alpha = random.uniform(1.0, 1.3)
    out = np.clip(alpha * out, 0, 255).astype(np.uint8)
    return out


def loop_flourish(img):
    """
    Small filled dot flourish near underline end (not a ring).
    """
    coords = cv2.findNonZero(img)
    if coords is None:
        return img

    x, y, w, h = cv2.boundingRect(coords)
    H, W = img.shape

    dot_x = min(W - 4, x + w + random.randint(5, 15))
    dot_y = min(H - 4, y + h + random.randint(10, 18))
    r = random.choice([1, 2])

    cv2.circle(img, (dot_x, dot_y), r, 255, -1)
    return img


def signature_underline(img):
    """
    Underline + end-dot like real signatures:
    - underline placed BELOW the text bounding box with a safe gap
    - dot anchored near the underline end (below the signature)
    - optional second underline (like the sample)
    """
    coords = cv2.findNonZero(img)
    if coords is None:
        return img

    x, y, w, h = cv2.boundingRect(coords)

    # Decide whether to draw underline
    if random.random() > 0.90:  # ~10% no underline
        return img

    H, W = img.shape

    # Safe gap below text to avoid crossing letters
    gap = random.randint(10, 18)          # key: keep it clearly below
    line_y = min(H - 4, y + h + gap)

    # Underline start/end relative to signature width
    start_pad = random.randint(5, 20)
    end_pad = random.randint(18, 40)

    start_x = max(3, x - start_pad)
    end_x = min(W - 6, x + w + end_pad)

    thickness = random.choice([1, 2])
    cv2.line(img, (start_x, line_y), (end_x, line_y), 255, thickness)

    # Optional 2nd underline (like sample 1)
    if random.random() < 0.35:
        line_y2 = min(H - 3, line_y + random.randint(6, 10))
        cv2.line(img, (start_x + random.randint(8, 20), line_y2),
                 (end_x - random.randint(10, 25), line_y2), 255, thickness)

    # Dot near end of underline (below, slightly after end)
    if random.random() < 0.70:
        dot_r = random.choice([1, 2])
        dot_x = min(W - 4, end_x + random.randint(4, 12))
        dot_y = min(H - 4, line_y + random.randint(-1, 1))
        cv2.circle(img, (dot_x, dot_y), dot_r, 255, -1)

    return img



def finish_to_128(img, out_size=128):
    """
    Crop tight bounding box and resize to 128x128.
    """
    coords = cv2.findNonZero(img)
    if coords is not None:
        x, y, w, h = cv2.boundingRect(coords)
        cropped = img[y:y+h, x:x+w]
    else:
        cropped = img

    # pad to square
    h, w = cropped.shape
    size = max(h, w) + 20
    square = np.zeros((size, size), dtype=np.uint8)

    yoff = (size - h) // 2
    xoff = (size - w) // 2
    square[yoff:yoff+h, xoff:xoff+w] = cropped

    resized = cv2.resize(square, (out_size, out_size))
    return resized


# ---------------- Main generators ----------------

def generate_3_procedural(name):
    texts = signature_text_forms(name)
    outs = []
    used_fonts = []

    font_list = FONT_PATHS if FONT_PATHS else [None]

    for t in texts:
        fp = random.choice(font_list)
        used_fonts.append(fp if fp else "")

        img = render_name(t, fp)
        img = emphasize_initial(img)

        img = random_affine(img)
        img = baseline_wobble(img, strength=float(random.uniform(2, 6)))
        img = pressure_effect(img)

        if random.random() < 0.75:
            img = loop_flourish(img)

        img = signature_underline(img)
        img = finish_to_128(img)

        outs.append(img)

    return outs, texts, used_fonts


def pick_3_from_dataset(name):
    key = name.strip().lower()
    if key not in DATASET_INDEX:
        return []

    paths = DATASET_INDEX[key]
    if len(paths) >= 3:
        return random.sample(paths, 3)
    # if less than 3, repeat
    return (paths * 3)[:3]


def get_three_signatures(name, mode="hybrid"):
    """
    mode: "dataset", "procedural", "hybrid"
    """
    name = (name or "").strip()
    if not name:
        return {"mode": "procedural", "images": [np.zeros((128, 128), np.uint8)] * 3,
                "texts": ["", "", ""], "fonts": ["", "", ""]}

    mode = (mode or "hybrid").lower()

    if mode == "dataset":
        paths = pick_3_from_dataset(name)
        if paths:
            return {"mode": "dataset", "paths": paths}
        # fallback
        imgs, texts, fonts = generate_3_procedural(name)
        return {"mode": "procedural", "images": imgs, "texts": texts, "fonts": fonts}

    if mode == "procedural":
        imgs, texts, fonts = generate_3_procedural(name)
        return {"mode": "procedural", "images": imgs, "texts": texts, "fonts": fonts}

    # hybrid
    paths = pick_3_from_dataset(name)
    if paths:
        return {"mode": "dataset", "paths": paths}
    imgs, texts, fonts = generate_3_procedural(name)
    return {"mode": "procedural", "images": imgs, "texts": texts, "fonts": fonts}


# ---------------- Save + log outputs ----------------

def save_outputs(result, input_name=""):
    """
    Save images into static/output with unique request id and log to CSV.
    Returns list of URLs.
    """
    _ensure_log_header()

    request_id = str(int(time.time() * 1000))
    ts = datetime.now().isoformat(timespec="seconds")
    out_urls = []

    if result["mode"] == "dataset":
        for i, src_path in enumerate(result["paths"], start=1):
            img = cv2.imread(src_path, cv2.IMREAD_GRAYSCALE)
            if img is None:
                img = np.zeros((128, 128), np.uint8)

            out_name = f"sig_{request_id}_{i}.png"
            out_path = os.path.join(OUTPUT_DIR, out_name)
            cv2.imwrite(out_path, img)

            out_urls.append(f"/static/output/{out_name}")

            with open(LOG_PATH, "a", newline="", encoding="utf-8") as f:
                writer = csv.writer(f)
                writer.writerow([ts, request_id, input_name, "dataset", i, out_name, src_path, "", ""])

    else:
        images = result["images"]
        texts = result.get("texts", ["", "", ""])
        fonts = result.get("fonts", ["", "", ""])

        for i, img in enumerate(images, start=1):
            out_name = f"sig_{request_id}_{i}.png"
            out_path = os.path.join(OUTPUT_DIR, out_name)
            cv2.imwrite(out_path, img)

            out_urls.append(f"/static/output/{out_name}")

            text_form = texts[i - 1] if i - 1 < len(texts) else ""
            font_file = os.path.basename(fonts[i - 1]) if i - 1 < len(fonts) else ""

            with open(LOG_PATH, "a", newline="", encoding="utf-8") as f:
                writer = csv.writer(f)
                writer.writerow([ts, request_id, input_name, "procedural", i, out_name, "", text_form, font_file])

    return out_urls


# ---------------- CNN Prediction (optional) ----------------

def _load_cnn():
    """
    Loads TensorFlow model if files exist.
    Returns (model, class_names) or (None, None).
    """
    if not (os.path.exists(CNN_MODEL_PATH) and os.path.exists(CNN_CLASSES_PATH)):
        return None, None

    try:
        import tensorflow as tf
        model = tf.keras.models.load_model(CNN_MODEL_PATH)
        class_names = np.load(CNN_CLASSES_PATH, allow_pickle=True)
        return model, class_names
    except Exception as e:
        print("CNN load error:", e)
        return None, None


def predict_urls_with_cnn(urls, input_name="", threshold=0.60):
    """
    Returns list of strings for UI:
    - Top predicted class + confidence
    - Match score for the *input name* (if input name exists in classes)
    Example:
      "Pred: Hamza (0.87) • Match(Ahmad)=0.10"
    """
    model, classes = _load_cnn()
    if model is None:
        return []

    input_key = (input_name or "").strip().lower()
    class_lower = [str(c).strip().lower() for c in classes]
    input_idx = class_lower.index(input_key) if input_key in class_lower else None

    preds = []
    for u in urls:
        filename = u.split("/")[-1]
        path = os.path.join(OUTPUT_DIR, filename)

        img = cv2.imread(path, cv2.IMREAD_GRAYSCALE)
        if img is None:
            preds.append("N/A")
            continue

        img = cv2.resize(img, (128, 128)).astype("float32") / 255.0
        x = img[np.newaxis, ..., np.newaxis]  # (1,128,128,1)

        prob = model.predict(x, verbose=0)[0]

        top_i = int(np.argmax(prob))
        top_conf = float(prob[top_i])
        top_name = str(classes[top_i])

        # unknown logic
        pred_text = f"Pred: {top_name} ({top_conf:.2f})"
        if top_conf < threshold:
            pred_text = f"Pred: Unknown ({top_conf:.2f})"

        # match score against input name
        if input_idx is not None:
            match_conf = float(prob[input_idx])
            pred_text += f" • Match({input_name})={match_conf:.2f}"

        preds.append(pred_text)

    return preds
