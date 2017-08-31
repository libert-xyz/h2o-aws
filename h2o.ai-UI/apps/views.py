from apps import app
from flask import render_template, request, url_for,redirect,flash,jsonify,abort
from apps.form import ClusterForm
import datetime
import logging
from logging.handlers import RotatingFileHandler
from h2oAws import create_stack

# @app.route('/',methods=['GET','POST'])
# def index():
#     return render_template('register_form.html')

@app.route('/' , methods = ('GET', 'POST'))
def register():

    form = ClusterForm()
    registerError = None
    if form.validate_on_submit():
        nameCluster = form.stackName.data
        vmCount = form.vmCount.data

        create_stack(nameCluster,vmCount)

        return redirect('/success')

    return render_template('register.html', form=form)

@app.route('/success' , methods = ['GET'])
def success():
    return render_template('success.html')
