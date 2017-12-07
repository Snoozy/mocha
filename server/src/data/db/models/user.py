from sqlalchemy import Column, Integer, String
from ..db import Base
from sqlalchemy.ext.associationproxy import association_proxy


class User(Base):
    __tablename__ = 'users'

    id = Column(Integer, primary_key=True)
    name = Column(String(20))
    username = Column(String(15), index=True, unique=True)
    password = Column(String(100))
    
    groups = association_proxy('memberships', 'group')

    blocks = association_proxy('blockings', 'blockee')
    blockers = association_proxy('blockee_obj', 'blocker')

    def to_dict(self):
        return {
            'id': self.id,
            'name': self.name,
            'username': self.username
        }