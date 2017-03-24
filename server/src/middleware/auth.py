import falcon
from data.redis import redis_client as redis


class AuthMiddleware:
    def process_resource(self, req, resp, resource, params):
        token = req.auth
        params['user_id'] = None
        user_id = None
        if not hasattr(resource, 'needs_auth') or resource.needs_auth:  # default is needs_auth = True. inside this if statement is needs auth = true
            if token is None:
                print("UNAUTHORIZED NO TOKEN")
                raise falcon.HTTPUnauthorized()
            print("token: " + token)
            user_id_raw = redis.get(token)
            if user_id_raw is None:
                print("UNAUTHORIZED REDIS. token: " + token)
                raise falcon.HTTPUnauthorized()
            user_id = int(user_id_raw)
            params['user_id'] = user_id

