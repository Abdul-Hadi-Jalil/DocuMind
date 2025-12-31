import os
import numpy as np
import pandas as pd
import cv2

from sklearn.model_selection import train_test_split
from sklearn.preprocessing import LabelEncoder

import tensorflow as tf
from tensorflow.keras import layers, models

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
DATASET_ROOT = os.path.join(BASE_DIR, "assets", "signature_dataset")
LABELS_PATH = os.path.join(DATASET_ROOT, "labels.csv")

IMG_SIZE = 128

def load_data():
    df = pd.read_csv(LABELS_PATH)

    X, y = [], []
    for _, row in df.iterrows():
        img_path = os.path.join(DATASET_ROOT, str(row["filename"]).strip())
        img = cv2.imread(img_path, cv2.IMREAD_GRAYSCALE)
        if img is None:
            continue

        img = cv2.resize(img, (IMG_SIZE, IMG_SIZE))
        img = img.astype("float32") / 255.0

        X.append(img)
        y.append(str(row["name"]).strip())

    X = np.array(X)[..., np.newaxis]  # (N,128,128,1)

    le = LabelEncoder()
    y_enc = le.fit_transform(np.array(y))

    return X, y_enc, le


def build_cnn(num_classes):
    model = models.Sequential([
        layers.Input(shape=(IMG_SIZE, IMG_SIZE, 1)),

        layers.Conv2D(32, 3, activation="relu"),
        layers.MaxPooling2D(),

        layers.Conv2D(64, 3, activation="relu"),
        layers.MaxPooling2D(),

        layers.Conv2D(128, 3, activation="relu"),
        layers.MaxPooling2D(),

        layers.Flatten(),
        layers.Dense(128, activation="relu"),
        layers.Dropout(0.3),

        layers.Dense(num_classes, activation="softmax")
    ])

    model.compile(
        optimizer="adam",
        loss="sparse_categorical_crossentropy",
        metrics=["accuracy"]
    )
    return model


def main():
    X, y, le = load_data()

    # split: 70% train, 15% val, 15% test (stratified)
    X_train, X_temp, y_train, y_temp = train_test_split(
        X, y, test_size=0.30, random_state=42, stratify=y
    )
    X_val, X_test, y_val, y_test = train_test_split(
        X_temp, y_temp, test_size=0.50, random_state=42, stratify=y_temp
    )

    model = build_cnn(num_classes=len(le.classes_))

    callbacks = [
        tf.keras.callbacks.EarlyStopping(patience=5, restore_best_weights=True),
        tf.keras.callbacks.ModelCheckpoint("cnn_signature_model.h5", save_best_only=True)
    ]

    model.fit(
        X_train, y_train,
        validation_data=(X_val, y_val),
        epochs=30,
        batch_size=16,
        callbacks=callbacks
    )

    loss, acc = model.evaluate(X_test, y_test, verbose=0)
    print(f"✅ Test Accuracy: {acc:.4f}")

    # save label names
    np.save("label_classes.npy", le.classes_)
    print("✅ Saved: cnn_signature_model.h5 and label_classes.npy")


if __name__ == "__main__":
    main()
