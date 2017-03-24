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
    timestamp = Column(BigInteger, default=(time.time() * 1000))

    user = relationship("User", foreign_keys=[user_id])
    group = relationship("Group", foreign_keys=[group_id])
    
    def to_dict(self):
        return {
                'media_url' : CDN_URL + self.media_id,
                'user_name' : self.user.name,
                'timestamp' : self.timestamp
                }
