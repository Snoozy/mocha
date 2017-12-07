import time

from sqlalchemy import Column, Integer, ForeignKey, BigInteger
from sqlalchemy.orm import relationship, backref
from ..db import Base
from .user import User


class Block(Base):
    __tablename__ = 'blocks'

    id = Column(Integer, primary_key=True)
    blocker_id = Column(Integer, ForeignKey('users.id'), index=True)
    blockee_id = Column(Integer, ForeignKey('users.id'))
    timestamp = Column(BigInteger)

    blocker = relationship(User, foreign_keys=[blocker_id], backref=backref('blockings', lazy='dynamic'))
    blockee = relationship(User, foreign_keys=[blockee_id])

    def __init__(self, blockee):
        self.blockee = blockee
        self.timestamp = time.time() * 1000
