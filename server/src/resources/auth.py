import re

import falcon
from data.redis import redis_client as redis
from data.db.models.user import User
from data.db.models.device import Device
from passlib.hash import pbkdf2_sha256
import os, base64
from data.aws import boto_session
from config import config

username_regex = re.compile('^[a-z0-9\.\-_]+$')


class SignUpResource:

    needs_auth = False

    def on_post(self, req, resp, user_id):
        name = req.get_param('name')
        raw_password = req.get_param('password')
        if not raw_password:
            raise falcon.HTTPBadRequest('Malformed request', "")
        password = pbkdf2_sha256.encrypt(req.get_param('password'), rounds=200000, salt_size=16)
        username = req.get_param('username')
        if not username:
            resp.json = {
                    'status': 10,
                    'error' : 'Username malformed.'
                }
            return
        username = username.lower()
        if username_exists(username, req.session):
            resp.json = {
                    'status': 1,
                    'title': 'Username taken',
                    'message': 'This username is in use.'
                }
            return
        if ' ' in username:
            resp.json = {
                    'status': 1,
                    'title': 'Username invalid',
                    'message': 'Username may not contain spaces.'
                }
            return
        if not username[0].isalpha():
            resp.json = {
                    'status': 1,
                    'title': 'Username invalid',
                    'message': 'Username must start with letter.'
                }
            return
        
        if not bool(username_regex.match(username)):
            resp.json = {
                    'status': 1,
                    'title': 'Username invalid',
                    'message': 'Username can only contain letters, numbers, underscore ( _ ), hyphen ( - ), and period ( . ).'
                }
            return

        new_user = User(name=name, username=username, password=password)
        req.session.add(new_user)
        req.session.commit()
        session_id = _log_in(new_user.id)
        
        resp.json = {
                'status': 0,
                "auth_token" : session_id,
                "user_id" : new_user.id
            }

def username_exists(username, session):
    return session.query(User).filter(User.username == username).scalar() != None

class LogInResource:

    needs_auth = False

    def on_post(self, req, resp, user_id):
        username = req.get_param('username')
        password_attempt = req.get_param('password')
        if not username or not password_attempt:
            resp.json = {
                    'status' : 1
                }
            return
        username = username.lower()
        user = req.session.query(User).filter(User.username == username).first()
        if not user:
            resp.json = {
                    'status' : 1
                }
            return
        session_id = log_in(user, password_attempt)
        if session_id:
            resp.json = {
                    'status' : 0,
                    "auth_token" : session_id,
                    "user_id" : user.id
                }
        else:
            resp.json = {
                    'status' : 1
                }

class PingResource:
    def on_get(self, req, resp, user_id):
        if user_id is not None:
            user = req.session.query(User).filter(User.id == user_id).first()
            if user:
                resp.json = {
                        "user_id" : user.id,
                        "name" : user.name,
                        "username" : user.username,
                    }
                return
        resp.status = falcon.HTTP_UNAUTHORIZED

    def on_post(self, req, resp, user_id):
        if user_id is not None:
            device_token = req.get_param('device_token')
            user = req.session.query(User).filter(User.id == user_id).first()
            if user:
                resp.json = {
                        "user_id" : user.id,
                        "name" : user.name,
                        "username" : user.username,
                    }
                if device_token:
                    process_device_token(device_token, user, req.session)
                return
        resp.status = falcon.HTTP_UNAUTHORIZED

APNS_PLATFORM_APP_ARN = 'arn:aws:sns:us-west-2:005648703137:app/APNS/marble' if config['env']['mode'] == 'prod' else 'arn:aws:sns:us-west-2:005648703137:app/APNS_SANDBOX/marble-dev'
SNS_REGION = 'us-west-2'

def process_device_token(token, user, session):
    device = session.query(Device).filter(Device.token == token).first()
    if not device:
        sns = boto_session.resource('sns', region_name=SNS_REGION)
        plat_app = sns.PlatformApplication(APNS_PLATFORM_APP_ARN)
        plat_endpoint = plat_app.create_platform_endpoint(
                    Token=token,
                    CustomUserData='user_id : ' + str(user.id),
                )
        new_device = Device(user_id=user.id, type=0, arn=plat_endpoint.arn, token=token)
        session.add(new_device)

def log_in(user, attempt):
    if pbkdf2_sha256.verify(attempt, user.password):
            return _log_in(user.id)
    return None

def _log_in(user_id):
    session_id = base64.b64encode(os.urandom(32)).decode('ascii')
    redis.set(session_id, user_id)
    return session_id
