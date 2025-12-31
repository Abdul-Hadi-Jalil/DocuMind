from flask import Flask, render_template, request
import os

from signature_logic import (
    get_three_signatures,
    save_outputs,
    predict_urls_with_cnn
)

app = Flask(__name__, static_folder='static', static_url_path='/static')

@app.route("/", methods=["GET", "POST"])
def index():
    images = []
    predictions = []
    name = ""
    mode = "hybrid"

    if request.method == "POST":
        name = request.form.get("name", "").strip()
        mode = request.form.get("mode", "hybrid").strip().lower()

        result = get_three_signatures(name, mode=mode)
        images = save_outputs(result, input_name=name)

        # Optional CNN prediction (only works if model exists)
        predictions = predict_urls_with_cnn(images, input_name=name)


    return render_template(
        "index.html",
        images=images,
        predictions=predictions,
        name=name,
        mode=mode
    )

if __name__ == "__main__":
    # For local run
    app.run(debug=True)
