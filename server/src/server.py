import falcon

from middleware.auth import AuthMiddleware
from middleware.db import SQLAlchemySessionManager
from middleware.json import JsonTranslator
from falcon_multipart.middleware import MultipartMiddleware

from resources.auth import PingResource
from resources.upload import ImageUploadResource, VideoUploadResource
from resources.auth import PingResource, SignUpResource, LogInResource
from resources.group import GroupJoinResource, GroupCreateResource, ListGroupsResource, FindGroupResource
from resources.user import GetStoriesResource, BlockUserResource
from resources.health import HealthCheckResource
from resources.story import StorySeenResource, FlagStoryResource

from sqlalchemy import create_engine
from sqlalchemy.orm import scoped_session
from sqlalchemy.orm import sessionmaker

from data.db.db import Base
from data.db.models import *

from config import config

engine = create_engine(config['db']['db_url'])

session_factory = sessionmaker(bind=engine)
Session = scoped_session(session_factory)

app = falcon.API(middleware=[AuthMiddleware(), MultipartMiddleware(), SQLAlchemySessionManager(Session), JsonTranslator()])
app.add_route('/v1/image/upload', ImageUploadResource())
app.add_route('/v1/video/upload', VideoUploadResource())
app.add_route('/v1/ping', PingResource())
app.add_route('/v1/signup', SignUpResource())
app.add_route('/v1/login', LogInResource())
app.add_route('/v1/groups/join', GroupJoinResource())
app.add_route('/v1/groups/create', GroupCreateResource())
app.add_route('/v1/groups/list', ListGroupsResource())
app.add_route('/v1/groups/find', FindGroupResource())
app.add_route('/v1/stories', GetStoriesResource())
app.add_route('/v1/stories/seen', StorySeenResource())
app.add_route('/v1/users/block', BlockUserResource())
app.add_route('/v1/stories/flag', FlagStoryResource())

# ELB Health Check ping
app.add_route('/health', HealthCheckResource())

app.req_options.auto_parse_form_urlencoded = True


def init_db():
    Base.metadata.create_all(bind=engine)
