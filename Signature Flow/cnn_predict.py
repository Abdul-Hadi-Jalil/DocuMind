import os
import numpy as np
import cv2
import tensorflow as tf

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
OUTPUT_DIR = os.path.join(BASE_DIR, "static", "output")

MODEL_PATH = os.path.join(BASE_DIR, "cnn_signature_model.h5")
CLASSES_PATH = os.path.join(BASE_DIR, "label_classes.npy")


def predict_folder(threshold=0.60):
    if not (os.path.exists(MODEL_PATH) and os.path.exists(CLASSES_PATH)):
        print("❌ Model not found. Train first using: python cnn_train.py")
        return

    model = tf.keras.models.load_model(MODEL_PATH)
    classes = np.load(CLASSES_PATH, allow_pickle=True)

    files = sorted([f for f in os.listdir(OUTPUT_DIR) if f.lower().endswith(".png")])
    if not files:
        print("❌ No PNG files found in static/output/")
        return

    print(f"🔎 Found {len(files)} images in static/output/")
    print("----- Predictions -----")

    for f in files:
        path = os.path.join(OUTPUT_DIR, f)
        img = cv2.imread(path, cv2.IMREAD_GRAYSCALE)
        if img is None:
            continue

        img = cv2.resize(img, (128, 128)).astype("float32") / 255.0
        x = img[np.newaxis, ..., np.newaxis]  # (1,128,128,1)

        prob = model.predict(x, verbose=0)[0]
        idx = int(np.argmax(prob))
        conf = float(prob[idx])

        if conf < threshold:
            print(f"{f}: Unknown ({conf:.2f})")
        else:
            print(f"{f}: {classes[idx]} ({conf:.2f})")


if __name__ == "__main__":
    predict_folder()
