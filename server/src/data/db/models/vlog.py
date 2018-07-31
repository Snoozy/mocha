from sqlalchemy import Column, Integer, String, ForeignKey, BigInteger, SmallInteger
from sqlalchemy.orm import relationship
from ..db import Base
from utils import time_millis, CDN_URL


class Vlog(Base):
    __tablename__ = 'vlogs'

    id = Column(Integer, primary_key=True)
    media_id = Column(String)
    group_id = Column(Integer, ForeignKey('groups.id'), index=True)
    editor_id = Column(Integer, ForeignKey('users.id'), index=True)
    description = Column(String)
    clip_ids = Column(String)  # list separated by ','
    views = Column(Integer, default=0)
    timestamp = Column(BigInteger, default=time_millis)

    editor = relationship('User', foreign_keys=[editor_id])
    group = relationship('Group', foreign_keys=[group_id])

    def to_dict(self):
        return {
            'id': self.id,
            'media_url': CDN_URL + self.media_id,
            'editor_id': self.editor_id,
            'group_id': self.group.id,
            'group_name': self.group.name,
            'timestamp': self.timestamp,
            'description': self.description,
            'views': self.views,
            'comments_count': self.comments.count()
        }