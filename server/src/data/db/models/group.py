from sqlalchemy import Column, Integer, String
from ..db import Base
from sqlalchemy.orm import relationship
from sqlalchemy.ext.associationproxy import association_proxy
from resources.constants import GROUP_ID_XOR


class Group(Base):
    __tablename__ = 'groups'

    id = Column(Integer, primary_key=True)
    name = Column(String(20))
    stories = relationship('Story', lazy='dynamic')

    users = association_proxy('memberships', 'user')

    def to_dict(self):
        return {
            'name': self.name,
            'group_id': self.id,
            'code': int(self.id) ^ GROUP_ID_XOR,
            'members': self.memberships.count()
        }
