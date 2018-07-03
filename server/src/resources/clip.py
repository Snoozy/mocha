import time

from sqlalchemy import and_

from data.db.models.user import User
from data.db.models.group import Group
from data.db.models.flag import Flag
from data.db.models.clip import Clip
from data.db.models.clip_like import ClipLike
from resources.constants import resp_error, resp_success


CLIP_EXPIRATION_LENGTH = 345600000  # in millis. currently 4 days


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


class LikeClipResource:
    def on_post(self, req, resp, user_id):
        clip_id = req.get_param('clip_id')
        user = req.session.query(User).filter(User.id == user_id).first()
        clip = req.session.query(Clip).filter(Clip.id == int(clip_id)).first()
        if not clip or not user:
            resp.json = resp_error()
            return
        if user in clip.likers:
            return
        clip.likers.append(user)
        clip.is_memory = 1
        resp.json = resp_success()


class UnlikeClipResource:
    # BUG (FEATURE): Liking then unliking clip doesn't remove from memories.
    def on_post(self, req, resp, user_id):
        clip_id = req.get_param('clip_id')
        user = req.session.query(User).filter(User.id == user_id).first()
        clip = req.session.query(Clip).filter(Clip.id == int(clip_id)).first()
        if not clip or not user:
            resp.json = resp_error()
            return
        try:
            req.session.query(ClipLike)\
                .filter(and_(ClipLike.user_id == user_id, ClipLike.clip_id == int(clip_id))).delete()
        except ValueError:
            print("Used has not liked clip")
        resp.json = resp_success()
