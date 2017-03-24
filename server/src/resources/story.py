import falcon
import time
from data.db.models.user import User
from data.db.models.group import Group

class StorySeenResource:
    def on_post(self, req, resp, user_id):
        user = req.session.query(User).filter(User.id == user_id).first()
        group_id = req.get_param('group_id')
        group = req.session.query(Group).filter(Group.id == int(group_id)).first()
        if not group:
            resp.context['json'] = {
                    'status' : 1
                }
            return
        for m in user.memberships:
            if m.group.id == group.id:
                m.last_seen = time.time() * 1000
                break
        resp.context['json'] = {
                'status' : 0
            }
