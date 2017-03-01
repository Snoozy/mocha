from sqlalchemy import Column, Integer, String
from ..db import Base
from .user_to_group import UserToGroup
from sqlalchemy.orm import relationship

class User(Base):
    __tablename__ = 'users'

    id = Column(Integer, primary_key=True)
    name = Column(String(20))
    username = Column(String(15), unique=True)
    password = Column(String(100))
    groups = relationship('Group', secondary=UserToGroup, backref='user')
