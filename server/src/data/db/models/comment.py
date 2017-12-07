import time

from sqlalchemy import Column, Integer, ForeignKey, BigInteger, String
from sqlalchemy.orm import relationship, backref
from ..db import Base
from .user import User

CDN_URL = "https://static.amarbleapp.com/media/"


class Comment(Base):
    __tablename__ = 'comments'

    id = Column(Integer, primary_key=True)
    story_id = Column(Integer, ForeignKey('stories.id'), index=True)
    user_id = Column(Integer, ForeignKey('users.id'), index=True)
    media_id = Column(String)
    timestamp = Column(BigInteger)

    user = relationship(User)
    story = relationship('Story', backref=backref('comments', lazy='dynamic'))

    def __init__(self, story_id, media_id, user_id):
        self.story_id = story_id
        self.media_id = media_id
        self.user_id = user_id
        self.timestamp = time.time() * 1000

    def to_dict(self):
        return {
                'id': self.id,
                'story_id': self.story_id,
                'media_url': CDN_URL + self.media_id,
                'timestamp': self.timestamp,
                'user_name': self.user.name,
                'user_id': self.user_id
                }
