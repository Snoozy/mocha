import falcon

from utils import max_body_length
from data.aws import boto_session
import uuid

from sqlalchemy import and_

from data.db.models.user import User
from data.db.models.clip import Clip
from data.db.models.group import Group
from data.db.models.vlog import Vlog
from data.db.models.comment import Comment
from resources.constants import resp_error, resp_success

VLOG_PAGE_SIZE = 10
S3_BUCKET_NAME = 'marble-s3'


class GetVlogsResource:
    def on_get(self, req, resp, user_id):
        user = req.session.query(User).filter(User.id == user_id).first()
        group_ids = []
        for group in user.groups:
            group_ids.append(group.id)
        if len(group_ids) > 0:
            after_id = req.get_param('after_id')
            if after_id:
                vlogs = req.session.query(Vlog).filter(and_(Vlog.group_id.in_(group_ids), Vlog.id < after_id))\
                    .order_by(Vlog.timestamp.desc()).limit(VLOG_PAGE_SIZE)
            else:
                vlogs = req.session.query(Vlog).filter(Vlog.group_id.in_(group_ids)).order_by(Vlog.timestamp.desc())\
                    .limit(VLOG_PAGE_SIZE)
            resp.json = resp_success({'content': [v.to_dict() for v in vlogs]})
        else:
            resp.json = resp_success({'content': []})


class VlogUploadResource:

    @falcon.before(max_body_length(1024 * 1024 * 15))  # 18 MB max size
    def on_post(self, req, resp, user_id):
        user = req.session.query(User).filter(User.id == user_id).first()
        if not user:
            resp.json = resp_error()
            return

        group_id = req.get_param('group_id')
        video = req.get_param('video')
        descr = req.get_param('description')
        clip_ids_str = req.get_param('clip_ids')

        clip_ids = []
        print(clip_ids_str)
        for c_str in clip_ids_str.split(','):
            try:
                clip_ids.append(int(c_str))
            except ValueError:
                resp.json = resp_error('Invalid clip ids format')
                raise falcon.HTTPBadRequest()

        group = req.session.query(Group).filter(Group.id == group_id).first()

        if group is None or video is None:
            raise falcon.HTTPBadReqest()

        s3 = boto_session.resource('s3')

        rand_str = str(uuid.uuid4())

        s3.Bucket(S3_BUCKET_NAME).put_object(Body=video.file, Key="media/" + rand_str, ContentType='video/mp4')
        print("VLOG UPLOAD: " + rand_str)

        new_vlog = Vlog(media_id=rand_str, group_id=group_id, editor_id=user_id, description=descr)
        req.session.add(new_vlog)
        req.session.commit()

        # send_posted_notifications(user, group)

        resp.json = resp_success({'media_id': rand_str})
        return


class GetVlogCommentsResource:
    def on_post(self, req, resp, user_id):
        vlog_id = req.get_param('vlog_id')
        if not vlog_id:
            resp.json = resp_error('No vlog id')
            raise falcon.HTTPBadRequest()
        vlog = req.session.query(Vlog).filter(Vlog.id == int(vlog_id)).first()
        if not vlog:
            resp.json = resp_error('Vlog does not exist')
            raise falcon.HTTPBadRequest()
        resp.json = resp_success({'comments': [c.to_dict() for c in vlog.comments]})


class VlogNewCommentResource:
    def on_post(self, req, resp, user_id):
        user = req.session.query(User).filter(User.id == user_id).first()
        vlog_id = req.get_param('vlog_id')
        comment_content = req.get_param('comment_content')
        if not comment_content or not user or not vlog_id:
            resp.json = resp_error('Invalid parameters')
            raise falcon.HTTPBadRequest()
        vlog = req.session.query(Vlog).filter(Vlog.id == vlog_id).first()
        if not vlog:
            resp.json = resp_error('Vlog does not exist')
            raise falcon.HTTPBadRequest()
        new_comment = Comment(vlog_id=vlog.id, user_id=user.id, content=comment_content)
        vlog.comments.append(new_comment)
        req.session.commit()
        resp.json = resp_success({'comment': new_comment.to_dict()})


def send_posted_notifications(poster: User, group: Group):
    for user in group.users:
        if user.id != poster.id:
            badge_num = get_user_badge_num(user)
            msg = "{} posted to {}".format(poster.name, group.name)
            for device in user.devices:
                print("sending notif to id: " + str(user.id))
                send_notification(device, msg, badge_num=badge_num)
