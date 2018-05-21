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
    timestamp = Column(BigInteger, default=time_millis)

    editor = relationship('User', foreign_keys=[editor_id])

    def to_dict(self):
        return {
            'id': self.id,
            'media_url': CDN_URL + self.media_id,
            'editor_name': self.editor.name,
            'editor_id': self.editor_id,
            'timestamp': self.timestamp,
            'description': self.description
        }