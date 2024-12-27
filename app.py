# app.py
from flask import (
    Flask, render_template, redirect, url_for, flash, jsonify
)
from flask_wtf import FlaskForm
from wtforms import StringField, PasswordField, SubmitField
from wtforms.validators import DataRequired
import os
import subprocess


app = Flask(__name__)
app.config['SECRET_KEY'] = os.getenv('FLASK_SECRET_KEY', 'default_secret_key')


APP_VERSION = "1.0"
APP_DESCRIPTION = "Gabriel Okom's pre-interview technical test."


def get_last_commit_sha():
    """Get the last commit SHA from Git or environment variable."""
    commit_sha = os.getenv("LAST_COMMIT_SHA")
    if commit_sha:
        return commit_sha
    try:
        return subprocess.check_output(
            ["git", "rev-parse", "HEAD"]
        ).strip().decode('utf-8')
    except Exception as e:
        return str(e)


class LoginForm(FlaskForm):
    username = StringField('Username', validators=[DataRequired()])
    password = PasswordField('Password', validators=[DataRequired()])
    submit = SubmitField('Login')


@app.route('/', methods=['GET', 'POST'])
def login():
    form = LoginForm()
    if form.validate_on_submit():
        flash(f'Welcome, {form.username.data}!', 'success')
        return redirect(url_for('login'))

    return render_template('login.html', form=form)


@app.route('/healthcheck', methods=['GET'])
def healthcheck():
    last_commit_sha = get_last_commit_sha()
    response = {
        "version": APP_VERSION,
        "description": APP_DESCRIPTION,
        "last_commit_sha": last_commit_sha
    }
    return jsonify(response), 200


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=3000, debug=True)
