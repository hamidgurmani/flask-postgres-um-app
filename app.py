from flask import Flask, render_template, redirect, url_for, request, flash
from flask_sqlalchemy import SQLAlchemy
import os
from datetime import datetime

app = Flask(__name__)
app.secret_key = os.environ.get("SECRET_KEY", "dev-secret-key")

# SQLite configuration
BASE_DIR = os.path.abspath(os.path.dirname(__file__))
DB_PATH = os.path.join(BASE_DIR, "instance", "app.db")

app.config["SQLALCHEMY_DATABASE_URI"] = os.environ.get(
    "DATABASE_URL", f"sqlite:///{DB_PATH}"
)
app.config["SQLALCHEMY_TRACK_MODIFICATIONS"] = False

db = SQLAlchemy(app)

# ---- Model ----
class User(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

# ---- Routes ----
@app.route("/", methods=["GET", "POST"])
def index():
    if request.method == "POST":
        name = request.form.get("name")

        if name:
            user = User(name=name)
            db.session.add(user)
            db.session.commit()
            flash("User added successfully ✅", "success")
        else:
            flash("Name cannot be empty ⚠️", "danger")

        return redirect(url_for("index"))

    users = User.query.all()
    return render_template("index.html", users=users)

@app.route("/delete/<int:user_id>", methods=["POST"])
def delete_user(user_id):
    user = User.query.get_or_404(user_id)
    db.session.delete(user)
    db.session.commit()
    flash("User deleted ❌", "danger")
    return redirect(url_for("index"))

# ---- App Entry Point ----
if __name__ == "__main__":
    with app.app_context():
        db.create_all()

        # Insert sample user only if table is empty
        if User.query.count() == 0:
            user = User(name="First User")
            db.session.add(user)
            db.session.commit()

    app.run(debug=True)
