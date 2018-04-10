import falcon

from middleware.auth import AuthMiddleware
from middleware.db import SQLAlchemySessionManager
from middleware.json import JsonTranslator
from falcon_multipart.middleware import MultipartMiddleware

from resources.upload import ImageUploadResource, VideoUploadResource, CommentUploadResource
from resources.auth import PingResource, SignUpResource, LogInResource
from resources.group import GroupJoinResource, GroupCreateResource, ListGroupsResource,\
    FindGroupResource, GroupLeaveResource, GroupInfoResource
from resources.user import GetStoriesResource, BlockUserResource
from resources.health import HealthCheckResource
from resources.story import StorySeenResource, FlagStoryResource
from resources.memories import GetMemoriesResource, SaveMemoryResource, RemoveMemoryResource
from resources.search import SearchResource, TrendingResource

from sqlalchemy import create_engine
from sqlalchemy.orm import scoped_session
from sqlalchemy.orm import sessionmaker

from data.db.db import Base
from data.db.models import *

from config import config

engine = create_engine(config['db']['db_url'])

session_factory = sessionmaker(bind=engine)
Session = scoped_session(session_factory)

app = falcon.API(middleware=[
    AuthMiddleware(),
    MultipartMiddleware(),
    SQLAlchemySessionManager(Session),
    JsonTranslator()]
)

version = 'v1'

app.add_route('/' + version + '/image/upload', ImageUploadResource())
app.add_route('/' + version + '/video/upload', VideoUploadResource())
app.add_route('/' + version + '/comment/upload', CommentUploadResource())

app.add_route('/' + version + '/ping', PingResource())

app.add_route('/' + version + '/signup', SignUpResource())
app.add_route('/' + version + '/login', LogInResource())

app.add_route('/' + version + '/groups/join', GroupJoinResource())
app.add_route('/' + version + '/groups/leave', GroupLeaveResource())
app.add_route('/' + version + '/groups/create', GroupCreateResource())
app.add_route('/' + version + '/groups/list', ListGroupsResource())
app.add_route('/' + version + '/groups/find', FindGroupResource())
app.add_route('/' + version + '/groups/trending', TrendingResource())

app.add_route('/' + version + '/stories', GetStoriesResource())
app.add_route('/' + version + '/stories/seen', StorySeenResource())

app.add_route('/' + version + '/memories', GetMemoriesResource())
app.add_route('/' + version + '/memories/save', SaveMemoryResource())
app.add_route('/' + version + '/memories/remove', RemoveMemoryResource())
app.add_route('/' + version + '/groups/info', GroupInfoResource())

app.add_route('/' + version + '/users/block', BlockUserResource())
app.add_route('/' + version + '/stories/flag', FlagStoryResource())

app.add_route('/' + version + '/search', SearchResource())

# ELB Health Check ping
app.add_route('/health', HealthCheckResource())

app.req_options.auto_parse_form_urlencoded = True


def init_db():
    Base.metadata.create_all(bind=engine)
