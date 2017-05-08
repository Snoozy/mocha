import time

from sqlalchemy import Column, Integer, String, ForeignKey, BigInteger, SmallInteger
from sqlalchemy.orm import relationship, backref
from ..db import Base

class Device(Base):
    __tablename__ = 'devices'

    id = Column(Integer, primary_key=True)
    type = Column(SmallInteger, default=0)  # 0 == iOS, 1 == Andriod
    arn = Column(String)
    token = Column(String)
    user_id = Column(Integer, ForeignKey('users.id'))

    user = relationship('User', backref=backref('devices', lazy='dynamic'))

    def __init__(self, user_id, type, arn, token):
        self.type = type
        self.user_id = user_id
        self.arn = arn
        self.token = token
