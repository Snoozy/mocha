import falcon
from data.db.models.user import User
from data.db.models.group import Group


CDN_URL = "https://static.amarbleapp.com/media/"

class GetStoriesResource:
    def on_get(self, req, resp, user_id):
        user = req.session.query(User).filter(User.id == user_id).first()
        groups = user.groups
        json = []
        for group in user.groups:
            stories = group.stories.all()
            #stories.reverse()
            stories_dict = [{"media_url" : CDN_URL + story.media_id, "user_name" : story.user.name} for story in stories]
            json.append({'group_id' : group.id, 'stories' : stories_dict})
        resp.context['json'] = {
                'status' : 0,
                'content' : json
            }
