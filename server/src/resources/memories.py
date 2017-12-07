from data.db.models.user import User
from resources.constants import RESP_ERR_JSON


class GetMemoriesResource:
    def on_get(self, req, resp, user_id):
        user = req.session.query(User).filter(User.id == user_id).first()
        if not user:
            resp.json = RESP_ERR_JSON
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
        resp.json = {
            'status': 0,
            'content': json
        }
        return
