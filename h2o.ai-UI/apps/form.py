from flask_wtf import Form
from wtforms import validators, StringField

class ClusterForm(Form):

    stackName = StringField('Cluster Name', [validators.Required(),
                                        validators.Length(min=3,max=60)])
    vmCount = StringField('Number of Instances', [validators.Required()])
