import time

from sqlalchemy import Column, Integer, ForeignKey, BigInteger, String
from sqlalchemy.orm import relationship, backref
from ..db import Base
from .user import User
from utils import time_millis

CDN_URL = 'https://i.marblestatic.com/media/'


class Comment(Base):
    __tablename__ = 'comments'

    id = Column(Integer, primary_key=True)
    story_id = Column(Integer, ForeignKey('stories.id'), index=True)
    user_id = Column(Integer, ForeignKey('users.id'), index=True)
    media_id = Column(String)
    timestamp = Column(BigInteger, default=time_millis)

    user = relationship(User)
    story = relationship('Story', backref=backref('comments', lazy='dynamic'))

    def to_dict(self):
        return {
                'id': self.id,
                'story_id': self.story_id,
                'media_url': CDN_URL + self.media_id,
                'timestamp': self.timestamp,
                'user_name': self.user.name,
                'user_id': self.user_id
                }
