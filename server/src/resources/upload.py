import falcon
from utils import max_body_length
from data.aws import boto_session
import uuid
from data.db.models.story import Story
from io import StringIO

class UploadResource:

    @falcon.before(max_body_length(1024 * 1024 * 6))  # 6MB max size
    def on_post(self, req, resp, user_id):
        group_ids = req.get_param('group_ids')
        media = req.get_param('media')
        
        if group_ids is None or media is None:
            raise falcon.HTTPBadRequest()

        s3 = boto_session.resource('s3')

        rand_str = str(uuid.uuid4())

        print(group_ids)
        group_ids = [int(id) for id in group_ids.split(',')]

        s3.Bucket('amarbleapp').put_object(Body=media.file, Key="media/" + rand_str, ContentType="image/png")

        print("UPLOAD: " + rand_str)
        
        for group_id in group_ids:
            new_story = Story(media_id=rand_str, group_id=group_id, user_id=user_id)
            req.session.add(new_story)

        resp.context['json'] = {
                "media_id" : rand_str
            }
