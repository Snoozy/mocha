from sqlalchemy import Column, Integer, String
from sqlalchemy.ext.associationproxy import association_proxy
from sqlalchemy.orm import relationship

from resources.constants import GROUP_ID_XOR
from ..db import Base


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
