import falcon

from utils import max_body_length

from data.db.models.user import User
from data.db.models.clip import Clip
from data.db.models.group import Group
from data.db.models.vlog import Vlog
from resources.constants import resp_error, resp_success

VLOG_PAGE_SIZE = 15


class GetVlogsResource:
    def on_get(self, req, resp, user_id):
        user = req.session.query(User).filter(User.id == user_id).first()
        group_ids = []
        for group in user.groups:
            group_ids.append(group.id)
        if len(group_ids) > 0:
            after_id = req.get_param('after_id')
            if after_id:
                vlogs = req.session.query(Vlog).filter(Vlog.group_id.in_(group_ids) & Vlog.id < after_id)\
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


def send_posted_notifications(poster: User, groups: Group):
    for group in group:
        for user in group.users:
            if user.id != poster.id:
                badge_num = get_user_badge_num(user)
                msg = "{} posted to {}".format(poster.name, group.name)
                for device in user.devices:
                    print("sending notif to id: " + str(user.id))
                    send_notification(device, msg, badge_num=badge_num)
