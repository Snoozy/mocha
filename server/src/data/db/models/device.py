from sqlalchemy import Column, Integer, String, ForeignKey, BigInteger, SmallInteger
from sqlalchemy.orm import relationship, backref
from ..db import Base


class Device(Base):
    __tablename__ = 'devices'

    id = Column(Integer, primary_key=True)
    type = Column(SmallInteger, default=0)  # 0 == iOS, 1 == Andriod
    arn = Column(String)
    token = Column(String)
    user_id = Column(Integer, ForeignKey('users.id'), index=True)

    user = relationship('User', backref=backref('devices', lazy='dynamic'))
