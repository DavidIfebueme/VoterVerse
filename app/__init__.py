from flask import Flask
from config import Config
from flask_sqlalchemy import SQLAlchemy

def create_app(config_class=Config):
    app = Flask(__name__)
    app.config.from_object(config_class)

    from app.routes import main
    app.register_blueprint(main)

    return app        