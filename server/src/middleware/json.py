import falcon
import json

class JsonTranslator:
    def process_response(self, req, resp, resource):
        if not hasattr(resp, 'json'):
            return
        resp.body = json.dumps(resp.json)
