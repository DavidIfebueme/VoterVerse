# from flask import render_template
# from . import db
# from flask import current_app as app
from flask import Blueprint, render_template

main = Blueprint('main', __name__)

@main.route('/')
def index():
    return render_template('index.html')