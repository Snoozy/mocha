import time
from data.db.models.user import User
from data.db.models.group import Group
from data.db.models.flag import Flag
from data.db.models.story import Story


class StorySeenResource:
    def on_post(self, req, resp, user_id):
        user = req.session.query(User).filter(User.id == user_id).first()
        group_id = req.get_param('group_id')
        group = req.session.query(Group).filter(Group.id == int(group_id)).first()
        if not group:
            resp.json = {
                    'status' : 1
                }
            return
        for m in user.memberships:
            if m.group.id == group.id:
                m.last_seen = time.time() * 1000
                break
        resp.json = {
                'status' : 0
            }
        return


class FlagStoryResource:
    def on_post(self, req, resp, user_id):
        story_id = req.get_param('story_id')
        story = req.session.query(Story).first(Story.id == int(story_id)).first()
        if not story:
            resp.json = {
                    'status' : 1
                }
            return
        new_flag = Flag(story=story)
        req.session.add(new_flag)
        resp.json = {
                'status' : 1
            }
        return
