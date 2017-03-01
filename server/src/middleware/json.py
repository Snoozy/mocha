import falcon
import json

class JsonTranslator:
    def process_response(self, req, resp, resource):
        if 'json' not in resp.context:
            return
        resp.body = json.dumps(resp.context['json'])
