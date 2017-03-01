import falcon
from data.redis import redis_client as redis
from data.db.models.user import User
from passlib.hash import pbkdf2_sha256
import os, base64


class SignUpResource:
    needs_auth = False
    def on_post(self, req, resp, user_id):
        name = req.get_param('name')
        raw_password = req.get_param('password')
        if not raw_password:
            raise falcon.HTTPBadRequest('Malformed request', "")
        print(raw_password)
        password = pbkdf2_sha256.encrypt(req.get_param('password'), rounds=200000, salt_size=16)
        username = req.get_param('username')
        new_user = User(name=name, username=username, password=password)
        req.session.add(new_user)
        req.session.commit()
        session_id = _log_in(new_user.id)

        resp.context['json'] = {
                "auth_token" : session_id,
                "user_id" : new_user.id
            }


class LogInResource:
    needs_auth = False
    def on_post(self, req, resp, user_id):
        username = req.get_param('username')
        password_attempt = req.get_param('password')
        user = req.session.query(User).filter(User.username == username).first()
        if not user:
            raise falcon.HTTPUnauthorized('Invalid credentials')
        session_id = log_in(user, password_attempt)
        if session_id:
            resp.context['json'] = {
                    "auth_token" : session_id,
                    "user_id" : user.id
                }
        else:
            raise falcon.HTTPUnauthorized('Invalid credentials')


class PingResource:
    def on_get(self, req, resp, user_id):
        if user_id is not None:
            user = req.session.query.filter(User.id == user_id).first()
            if user:
                resp.context['json'] = {
                        "name" : user.name,
                        "username" : user.username,
                    }
                return
        resp.status = falcon.HTTP_UNAUTHORIZED


def log_in(user, attempt):
    if pbkdf2_sha256.verify(attempt, user.password):
            return _log_in(user.id)
    return None

def _log_in(user_id):
    session_id = base64.b64encode(os.urandom(32)).decode('ascii')
    redis.set(session_id, user_id)
    return session_id
