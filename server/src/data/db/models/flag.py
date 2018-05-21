import time

from sqlalchemy import Column, Integer, BigInteger, ForeignKey
from ..db import Base
from sqlalchemy.orm import relationship
from .clip import Clip
from utils import time_millis


class Flag(Base):
    __tablename__ = 'flags'

    id = Column(Integer, primary_key=True)
    clip_id = Column(Integer, ForeignKey('clips.id'))
    timestamp = Column(BigInteger, default=time_millis)

    clip = relationship(Clip)
