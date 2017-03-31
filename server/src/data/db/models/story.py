import time

from sqlalchemy import Column, Integer, String, ForeignKey, BigInteger
from sqlalchemy.orm import relationship
from ..db import Base

CDN_URL = "https://static.amarbleapp.com/media/"

class Story(Base):
    __tablename__ = 'stories'

    id = Column(Integer, primary_key=True)
    media_id = Column(String)
    group_id = Column(Integer, ForeignKey("groups.id"))
    user_id = Column(Integer, ForeignKey('users.id'))
    timestamp = Column(BigInteger)

    user = relationship("User", foreign_keys=[user_id])
    group = relationship("Group", foreign_keys=[group_id])

    def __init__(self, media_id, group_id, user_id):
        self.media_id = media_id
        self.group_id = group_id
        self.user_id = user_id
        self.timestamp = time.time() * 1000
    
    def to_dict(self):
        return {
                'media_url' : CDN_URL + self.media_id,
                'user_name' : self.user.name,
                'timestamp' : self.timestamp
                }
