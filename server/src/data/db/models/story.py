import time

from sqlalchemy import Column, Integer, String, ForeignKey, BigInteger, SmallInteger
from sqlalchemy.orm import relationship
from ..db import Base
from .comment import Comment
from utils import time_millis

CDN_URL = "https://static.amarbleapp.com/media/"


class Story(Base):
    __tablename__ = 'stories'

    id = Column(Integer, primary_key=True)
    media_id = Column(String)
    media_type = Column(SmallInteger, default=0)  # 0 == image, 1 == video
    is_memory = Column(SmallInteger, default=0)  # 0 == not memory, 1 == is memory
    group_id = Column(Integer, ForeignKey("groups.id"), index=True)
    user_id = Column(Integer, ForeignKey('users.id'), index=True)
    timestamp = Column(BigInteger, default=time_millis, index=True)

    user = relationship("User", foreign_keys=[user_id])
    group = relationship("Group", foreign_keys=[group_id])

    def to_dict(self):
        return {
            'media_url': CDN_URL + self.media_id,
            'media_type': 'video' if self.media_type else 'image',
            'user_name': self.user.name,
            'user_id': self.user_id,
            'timestamp': self.timestamp,
            'id': self.id,
            'is_memory': self.is_memory == 1,
            'comments': [comment.to_dict() for comment in self.comments.order_by(Comment.timestamp).all()]
        }

