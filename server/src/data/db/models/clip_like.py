from sqlalchemy import Column, Integer, String, ForeignKey, BigInteger, SmallInteger
from sqlalchemy.orm import relationship, backref
from .user import User
from .clip import Clip
from ..db import Base
from utils import time_millis


class ClipLike(Base):
    __tablename__ = 'clip_likes'

    id = Column(Integer, primary_key=True)
    user_id = Column(Integer, ForeignKey('users.id'), index=True)
    clip_id = Column(Integer, ForeignKey('clips.id'), index=True)
    timestamp = Column(BigInteger, default=time_millis)

    user = relationship(User, backref=backref('clip_likes', lazy='dynamic', cascade='all, delete-orphan'))
    clip = relationship(Clip, backref=backref('clip_likes', lazy='dynamic', cascade='all, delete-orphan'))

    def __init__(self, first=None, second=None):
        if isinstance(first, User):
            self.user = first
            self.clip = second
        else:
            self.user = second
            self.clip = first
