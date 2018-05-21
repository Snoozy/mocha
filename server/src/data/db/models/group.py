from sqlalchemy import Column, Integer, String, BigInteger
from sqlalchemy.ext.associationproxy import association_proxy
from sqlalchemy.orm import relationship

from resources.constants import GROUP_ID_XOR
from utils import time_millis
from ..db import Base


class Group(Base):
    __tablename__ = 'groups'

    id = Column(Integer, primary_key=True)
    name = Column(String(20))
    clips = relationship('Clip', lazy='dynamic')
    timestamp = Column(BigInteger, default=time_millis)

    users = association_proxy('memberships', 'user')

    def to_dict(self):
        return {
            'name': self.name,
            'group_id': self.id,
            'code': int(self.id) ^ GROUP_ID_XOR,
            'members': self.memberships.count()
        }
