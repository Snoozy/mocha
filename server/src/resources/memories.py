from data.db.models.user import User
from data.db.models.story import Story
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
                memories = group.stories.filter((Story.is_memory == 1) & (Story.user_id.notin_(user_blocks))).all()
            else:
                memories = group.stories.filter(Story.is_memory == 1).all()
            memories_dict = [story.to_dict() for story in memories]
            json.append({'group_id': group.id, 'stories': memories_dict})
        resp.json = resp_success({'content': json})
        return


class SaveMemoryResource:
    def on_post(self, req, resp, user_id):
        user = req.session.query(User).filter(User.id == user_id).first()
        if not user:
            resp.json = resp_error('User does not exist')
            return
        story_id = req.get_param('story_id')
        story = req.session.query(Story).filter(Story.id == int(story_id)).first()
        if user_id not in story.group.users:
            resp.json = resp_error('User not apart of marble')
            return
        story.is_memory = 1
        resp.json = resp_success()
        return


class RemoveMemoryResource:
    def on_post(self, req, resp, user_id):
        user = req.session.query(User).filter(User.id == user_id).first()
        if not user:
            resp.json = resp_error('User does not exist')
            return
        story_id = req.get_param('story_id')
        story = req.session.query(Story).filter(Story.id == int(story_id)).first()
        if user_id not in story.group.users:
            resp.json = resp_error('User not apart of this marble')
            return
        story.is_memory = 0
        resp.json = resp_success()
        return
