import time

from sqlalchemy import Column, Integer, BigInteger, ForeignKey
from ..db import Base
from sqlalchemy.orm import relationship
from .story import Story
from utils import time_millis


class Flag(Base):
    __tablename__ = 'flags'

    id = Column(Integer, primary_key=True)
    story_id = Column(Integer, ForeignKey('stories.id'))
    timestamp = Column(BigInteger, default=time_millis)

    story = relationship(Story)
