import falcon


class HealthCheckResource:

    needs_auth = False

    def on_get(self, req, resp, user_id):
        resp.body = "OK"
