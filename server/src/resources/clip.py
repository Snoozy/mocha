import time
from data.db.models.user import User
from data.db.models.group import Group
from data.db.models.flag import Flag
from data.db.models.clip import Clip
from resources.constants import resp_error, resp_success


class ClipSeenResource:
    def on_post(self, req, resp, user_id):
        user = req.session.query(User).filter(User.id == user_id).first()
        group_id = req.get_param('group_id')
        group = req.session.query(Group).filter(Group.id == int(group_id)).first()
        if not group:
            resp.json = resp_error()
            return
        for m in user.memberships:
            if m.group.id == group.id:
                m.last_seen = time.time() * 1000
                break
        resp.json = resp_success()
        return


class FlagClipResource:
    def on_post(self, req, resp, user_id):
        clip_id = req.get_param('clip_id')
        clip = req.session.query(Clip).filter(Clip.id == int(clip_id)).first()
        if not clip:
            resp.json = resp_error()
            return
        new_flag = Flag(clip_id=clip.id)
        req.session.add(new_flag)
        resp.json = resp_success()
        return
