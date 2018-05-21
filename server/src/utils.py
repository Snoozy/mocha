import falcon
import time


def max_body_length(limit):
    def hook(req, resp, resource, params):
        length = req.content_length
        if length is not None and length > limit:
            msg = ('The size of the request is too large. The body must not '
                   'exceed ' + str(limit) + ' bytes in length.')
            raise falcon.HTTPRequestEntityTooLarge('Request body is too large', msg)

    return hook


def time_millis():
    return time.time() * 1000


CDN_URL = "https://i.marblestatic.com/media/"

