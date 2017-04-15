import time

from sqlalchemy import Column, Integer, BigInteger, ForeignKey
from ..db import Base
from sqlalchemy.orm import relationship
from .story import Story

class Flag(Base):
    __tablename__ = 'flags'

    id = Column(Integer, primary_key=True)
    story_id = Column(Integer, ForeignKey('stories.id'))
    timestamp = Column(BigInteger)

    story = relationship(Story)

    def __init__(self, story):
        self.story = story
        self.timestamp = time.time() * 1000
