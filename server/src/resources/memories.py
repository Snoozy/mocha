from data.db.models.user import User
from data.db.models.clip import Clip
from resources.constants import resp_error, resp_success


class GetMemoriesResource:
    def on_get(self, req, resp, user_id):
        user = req.session.query(User).filter(User.id == user_id).first()
        if not user:
            resp.json = resp_error('User does not exist')
            return
        json = []
        for group in user.groups:
            user_blocks = [u.id for u in user.blocks]
            if len(user_blocks):
                memories = group.clips.filter((Clip.is_memory == 1) & (Clip.user_id.notin_(user_blocks))).all()
            else:
                memories = group.clips.filter(Clip.is_memory == 1).all()
            memories_dict = [clip.to_dict(user) for clip in memories]
            json.append({'group_id': group.id, 'clips': memories_dict})
        resp.json = resp_success({'content': json})
        return


class SaveMemoryResource:
    def on_post(self, req, resp, user_id):
        user = req.session.query(User).filter(User.id == user_id).first()
        if not user:
            resp.json = resp_error('User does not exist')
            return
        clip_id = req.get_param('clip_id')
        clip = req.session.query(Clip).filter(Clip.id == int(clip_id)).first()
        if user not in clip.group.users:
            resp.json = resp_error('User not apart of marble')
            return
        clip.is_memory = 1
        resp.json = resp_success()
        return


class RemoveMemoryResource:
    def on_post(self, req, resp, user_id):
        user = req.session.query(User).filter(User.id == user_id).first()
        if not user:
            resp.json = resp_error('User does not exist')
            return
        clip_id = req.get_param('clip_id')
        clip = req.session.query(Clip).filter(Clip.id == int(clip_id)).first()
        if user not in clip.group.users:
            resp.json = resp_error('User not apart of this marble')
            return
        clip.is_memory = 0
        resp.json = resp_success()
        return
