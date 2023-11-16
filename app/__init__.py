from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from app.routes import auth, admin, user, election, dashboard

app = Flask(__name__)
app.config.from_pyfile('config.py')

db = SQLAlchemy(app)


app.register_blueprint(auth.bp)
app.register_blueprint(admin.bp)
app.register_blueprint(user.bp)
app.register_blueprint(election.bp)
app.register_blueprint(dashboard.bp)