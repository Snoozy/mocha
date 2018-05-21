import time
from data.db.models.user import User
from data.db.models.clip import Clip

CLIP_EXPIRATION_LENGTH = 172800000  # in millis. currently 48 hours


class GetClipsResource:
    def on_get(self, req, resp, user_id):
        user = req.session.query(User).filter(User.id == user_id).first()
        json = []
        for group in user.groups:
            time_cutoff = int(time.time() * 1000) - CLIP_EXPIRATION_LENGTH
            user_blocks = [u.id for u in user.blocks]
            if len(user_blocks):
                clips = group.clips.filter((Clip.timestamp > time_cutoff) & (Clip.user_id.notin_(user_blocks)))\
                    .order_by(Clip.timestamp).all()
            else:
                clips = group.clips.filter(Clip.timestamp > time_cutoff).order_by(Clip.timestamp).all()
            clips_dict = [clip.to_dict() for clip in clips]
            json.append({'group_id': group.id, 'clips': clips_dict})
        resp.json = {
                'status': 0,
                'content': json
            }
        return


class BlockUserResource:
    def on_post(self, req, resp, user_id):
        user = req.session.query(User).filter(User.id == user_id).first()
        blockee_id = req.get_param('blockee_id')
        blockee = req.session.query(User).filter(User.id == blockee_id).first()
        if not user or not blockee:
            resp.json = {
                    'status': 1,
                    'error': 'Blockee does not exist.'
                }
            return
        if user.id == blockee_id:
            resp.json = {
                    'status': 2,
                    'error': 'Cannot block yourself.'
                }
        if blockee not in user.blocks:
            user.blocks.append(blockee)
        resp.json = {
                'status': 0
            }
        return
