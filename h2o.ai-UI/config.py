import os

basedir = os.path.abspath(os.path.dirname(__file__))

class Config(object):
    SECRET_KEY = '!Aka@'
    DEBUG = False
    TESTING = False

class Production(Config):
    WTF_CSRF_ENABLED = True

class Development(Config):
    DEBUG = True

class Testing(Config):
    TESTING = True
