from sqlalchemy import *
from sqlalchemy.orm import relationship, backref
from .user import User
from .group import Group
import time

from ..db import Base

class Membership(Base):
    __tablename__ = 'memberships'

    id = Column(Integer, primary_key=True)
    user_id = Column(Integer, ForeignKey('users.id'))
    group_id = Column(Integer, ForeignKey('groups.id'))
    timestamp = Column(BigInteger, default=(time.time() * 1000))
    last_seen = Column(BigInteger, default=None)

    group = relationship(Group, backref=backref('memberships', lazy='dynamic'))
    user = relationship(User, backref=backref('memberships', lazy='dynamic'))

    def __init__(self, first=None, second=None, last_seen=None):
        if isinstance(first, User):
            self.user = first
            self.group = second
        else:
            self.user = second
            self.group = first
        self.last_seen = last_seen
