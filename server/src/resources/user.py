import falcon
from data.db.models.user import User
from data.db.models.group import Group
from data.db.models.story import Story


class GetStoriesResource:
    def on_get(self, req, resp, user_id):
        user = req.session.query(User).filter(User.id == user_id).first()
        groups = user.groups
        json = []
        for group in user.groups:
            stories = None
            if user.blocks:
                stories = group.stories.filter(Story.user_id.notin_([u.id for u in user.blocks])).order_by(Story.timestamp).all()
            else:
                stories = group.stories.order_by(Story.timestamp).all()
            stories_dict = [story.to_dict() for story in stories]
            json.append({'group_id' : group.id, 'stories' : stories_dict})
        resp.json = {
                'status' : 0,
                'content' : json
            }
        return

class BlockUserResource:
    def on_post(self, req, resp, user_id):
        user = req.session.query(User).filter(User.id == user_id).first()
        blockee_id = req.get_param('blockee_id')
        blockee = req.session.query(User).filter(User.id == blockee_id).first()
        if not user or not blockee:
            resp.json = {
                    'status' : 1,
                    'error': 'Blockee does not exist.'
                }
            return
        if user.id == blockee_id:
            resp.json = {
                    'status' : 2,
                    'error' : 'Cannot block yourself.'
                }
        if blockee not in user.blocks:
            user.blocks.append(blockee)
        resp.json = {
                'status' : 0
            }
        return
