from data.db.models.user import User
from data.db.models.group import Group
import json
from resources.constants import GROUP_ID_XOR, resp_success, resp_error
from falcon import Request, Response


class SearchResource:
    def on_get(self, req, resp, user_id):
        query = req.get_param('query')
        if len(query) > 2:
            res_raw = req.session.query(Group).filter(Group.name.like('%' + query + '%')).all()
            results = []
            for r in res_raw:
                results.append(r.to_dict())
            resp.json = resp_success({'results': results})
        else:
            resp.json = resp_success({'results': []})
