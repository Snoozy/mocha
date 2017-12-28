import time

from sqlalchemy import Column, Integer, ForeignKey, BigInteger
from sqlalchemy.orm import relationship, backref
from ..db import Base
from .user import User
from utils import time_millis


class Block(Base):
    __tablename__ = 'blocks'

    id = Column(Integer, primary_key=True)
    blocker_id = Column(Integer, ForeignKey('users.id'), index=True)
    blockee_id = Column(Integer, ForeignKey('users.id'))
    timestamp = Column(BigInteger, default=time_millis)

    blocker = relationship(User, foreign_keys=[blocker_id], backref=backref('blockings', lazy='dynamic'))
    blockee = relationship(User, foreign_keys=[blockee_id])
