from sqlalchemy import Column, Integer, String
from ..db import Base
from sqlalchemy.orm import relationship, backref
from .user_to_group import UserToGroup

class Group(Base):
    __tablename__ = 'groups'

    id = Column(Integer, primary_key=True)
    name = Column(String(20))
    users = relationship('User', secondary=UserToGroup, lazy='dynamic', backref=backref('group', lazy='dynamic'))
    stories = relationship('Story', lazy='dynamic')
