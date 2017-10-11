import time

from sqlalchemy import Column, Integer, String, ForeignKey, BigInteger, SmallInteger
from sqlalchemy.orm import relationship
from ..db import Base
from .comment import Comment

CDN_URL = "https://static.amarbleapp.com/media/"


class Story(Base):
    __tablename__ = 'stories'

    id = Column(Integer, primary_key=True)
    media_id = Column(String)
    media_type = Column(SmallInteger, default=0)  # 0 == image, 1 == video
    group_id = Column(Integer, ForeignKey("groups.id"))
    user_id = Column(Integer, ForeignKey('users.id'))
    timestamp = Column(BigInteger)

    user = relationship("User", foreign_keys=[user_id])
    group = relationship("Group", foreign_keys=[group_id])

    def __init__(self, media_id, group_id, user_id, media_type):
        self.media_id = media_id
        self.group_id = group_id
        self.user_id = user_id
        self.timestamp = time.time() * 1000
        self.media_type = media_type

    def to_dict(self):
        return {
            'media_url': CDN_URL + self.media_id,
            'media_type': 'video' if self.media_type else 'image',
            'user_name': self.user.name,
            'user_id': self.user_id,
            'timestamp': self.timestamp,
            'id': self.id,
            'comments': [comment.to_dict() for comment in self.comments.order_by(Comment.timestamp).all()]
        }
