import time
from data.db.models.user import User
from data.db.models.group import Group
from data.db.models.flag import Flag
from data.db.models.story import Story
from resources.constants import resp_error, resp_success


class StorySeenResource:
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


class FlagStoryResource:
    def on_post(self, req, resp, user_id):
        story_id = req.get_param('story_id')
        story = req.session.query(Story).filter(Story.id == int(story_id)).first()
        if not story:
            resp.json = resp_error()
            return
        new_flag = Flag(story=story)
        req.session.add(new_flag)
        resp.json = resp_success()
        return


class SaveStoryResource:
    def on_post(self, req, resp, user_id):
        story_id = req.get_param('story_id')
        story = req.session.query(Story).filter(Story.id == int(story_id)).first()
        if not story:
            resp.json = resp_error('Story does not exist.')
            return
        story.is_memory = 1
        resp.json = resp_success()
        return
