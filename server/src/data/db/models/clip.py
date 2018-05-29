import time

from sqlalchemy import Column, Integer, String, ForeignKey, BigInteger, SmallInteger
from sqlalchemy.orm import relationship
from sqlalchemy.ext.associationproxy import association_proxy
from ..db import Base
from .comment import Comment
from utils import time_millis, CDN_URL


class Clip(Base):
    __tablename__ = 'clips'

    id = Column(Integer, primary_key=True)
    media_id = Column(String)
    is_memory = Column(SmallInteger, default=0)  # 0 == not memory, 1 == is memory
    group_id = Column(Integer, ForeignKey("groups.id"), index=True)
    user_id = Column(Integer, ForeignKey('users.id'), index=True)
    timestamp = Column(BigInteger, default=time_millis, index=True)

    user = relationship("User", foreign_keys=[user_id])
    group = relationship("Group", foreign_keys=[group_id])

    likes = association_proxy('clip_likes', 'clip_like')

    def to_dict(self):
        return {
            'media_url': CDN_URL + self.media_id,
            'user_name': self.user.name,
            'user_id': self.user_id,
            'timestamp': self.timestamp,
            'id': self.id,
            'is_memory': self.is_memory == 1,
        }
