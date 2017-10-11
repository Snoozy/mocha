import falcon
from utils import max_body_length
from data.aws import boto_session
import uuid
from data.db.models.story import Story
from data.db.models.comment import Comment
from data.db.models.user import User
from data.db.models.group import Group
from typing import List
from data.notifications import send_notification, get_user_badge_num


BLANK_CAPTION_RAND_STR = 'a67722d1-c43b-492a-b899-3131057bee3a'


class ImageUploadResource:

    @falcon.before(max_body_length(1024 * 1024 * 6))  # 6MB max size
    def on_post(self, req, resp, user_id):
        user = req.session.query(User).filter(User.id == user_id).first()
        
        group_ids = req.get_param('group_ids')
        media = req.get_param('image')
        caption = req.get_param('caption')
        
        if group_ids is None or media is None:
            raise falcon.HTTPBadRequest()

        s3 = boto_session.resource('s3')

        rand_str = str(uuid.uuid4())

        print(group_ids)
        group_ids = [int(id) for id in group_ids.split(',')]

        s3.Bucket('amarbleapp').put_object(Body=media.file, Key="media/" + rand_str, ContentType="image/jpeg")

        print("UPLOAD: " + rand_str)

        caption_rand_str = None

        if caption is not None:
            caption_rand_str = str(uuid.uuid4())
            s3.Bucket('amarbleapp').put_object(Body=caption.file, Key="media/" + caption_rand_str,
                                               ContentType="image/png")
            print('CAPTION UPLOAD: ' + caption_rand_str)

        for group_id in group_ids:
            new_story = Story(media_id=rand_str, group_id=group_id, user_id=user_id, media_type=0)
            req.session.add(new_story)
            req.session.commit()
            if caption is not None:
                comment = Comment(story_id=new_story.id, media_id=caption_rand_str, user_id=user_id)
                new_story.comments.append(comment)
            else:
                comment = Comment(story_id=new_story.id, media_id=BLANK_CAPTION_RAND_STR, user_id=user_id)
                new_story.comments.append(comment)
        
        groups = req.session.query(Group).filter(Group.id.in_(group_ids)).all()
        send_posted_notifications(user, groups)

        resp.json = {
                "media_id": rand_str
            }
        return


class VideoUploadResource:

    @falcon.before(max_body_length(1024 * 1024 * 15))  # 18 MB max size
    def on_post(self, req, resp, user_id):
        user = req.session.query(User).filter(User.id == user_id).first()
        if not user:
            resp.json = {
                    'status': 1
                }
            return

        group_ids = req.get_param('group_ids')
        video = req.get_param('video')
        caption = req.get_param('caption')

        if group_ids is None or video is None:
            raise falcon.HTTPBadReqest()

        s3 = boto_session.resource('s3')

        rand_str = str(uuid.uuid4())

        group_ids = [int(id) for id in group_ids.split(',')]

        s3.Bucket('amarbleapp').put_object(Body=video.file, Key="media/" + rand_str, ContentType='video/mp4')
        print("VIDEO UPLOAD: " + rand_str)
        
        caption_rand_str = None

        if caption is not None:
            caption_rand_str = str(uuid.uuid4())
            s3.Bucket('amarbleapp').put_object(Body=caption.file, Key="media/" + caption_rand_str, ContentType="image/png")
            print('CAPTION UPLOAD: ' + caption_rand_str)

        for group_id in group_ids:
            new_story = Story(media_id=rand_str, group_id=group_id, user_id=user_id, media_type=1)
            req.session.add(new_story)
            req.session.commit()
            if caption is not None:
                comment = Comment(story_id=new_story.id, media_id=caption_rand_str, user_id=user_id)
                new_story.comments.append(comment)
            else:
                comment = Comment(story_id=new_story.id, media_id=BLANK_CAPTION_RAND_STR, user_id=user_id)
                new_story.comments.append(comment)
        
        groups = req.session.query(Group).filter(Group.id.in_(group_ids)).all()
        send_posted_notifications(user, groups)

        resp.json = {
                'media_id': rand_str
            }
        return


class CommentUploadResource:

    @falcon.before(max_body_length(1024 * 1024 * 6))  # 6MB max size
    def on_post(self, req, resp, user_id):
        story_id = req.get_param('story_id')
        media = req.get_param('image')
        
        if story_id is None or media is None:
            raise falcon.HTTPBadRequest()

        s3 = boto_session.resource('s3')

        rand_str = str(uuid.uuid4())

        story_id = int(story_id)
        story = req.session.query(Story).filter(Story.id == story_id).first()
        if not story:
            raise falcon.HTTPBadRequest()

        s3.Bucket('amarbleapp').put_object(Body=media.file, Key="media/" + rand_str, ContentType="image/png")

        print("UPLOAD: " + rand_str)
 
        new_comment = Comment(story_id=story.id, media_id=rand_str, user_id=user_id)
        story.comments.append(new_comment)

        req.session.commit()

        user = req.session.query(User).filter(User.id == user_id).first()
        send_commented_notifications(story.user, user, story)

        resp.json = new_comment.to_dict()
        return


def send_commented_notifications(orig_poster: User, commenter: User, story: Story):
    group = story.group
    msg = "{} commented on your post in {}".format(commenter.name, group.name)
    badge_num = get_user_badge_num(orig_poster)
    for device in orig_poster.devices:
        send_notification(device, msg, badge_num=badge_num)
    users_seen = [orig_poster.id]
    for comment in story.comments:
        user = comment.user
        if user.id not in users_seen:
            users_seen.append(user.id)
            msg = "{} also commented on a post in {}".format(commenter.name, group.name)
            badge_num = get_user_badge_num(user)
            for device in user.devices:
                send_notification(device, msg, badge_num=badge_num)


def send_posted_notifications(poster: User, groups: List[Group]):
    for group in groups:
        for user in group.users:
            if user.id != poster.id:
                badge_num = get_user_badge_num(user)
                msg = "{} posted to {}".format(poster.name, group.name)
                for device in user.devices:
                    print("sending notif to id: " + str(user.id))
                    send_notification(device, msg, badge_num=badge_num)

