import time

from sqlalchemy import Column, Integer, ForeignKey, BigInteger, String
from sqlalchemy.orm import relationship, backref
from ..db import Base
from .user import User
from utils import time_millis, CDN_URL


class Comment(Base):
    __tablename__ = 'comments'

    id = Column(Integer, primary_key=True)
    vlog_id = Column(Integer, ForeignKey('vlogs.id'), index=True)
    user_id = Column(Integer, ForeignKey('users.id'), index=True)
    content = Column(String)
    timestamp = Column(BigInteger, default=time_millis)

    user = relationship(User)
    vlog = relationship('Vlog', backref=backref('comments', lazy='dynamic'))

    def to_dict(self):
        return {
                'id': self.id,
                'vlog_id': self.vlog_id,
                'content': self.content,
                'timestamp': self.timestamp,
                'user': self.user.to_dict(),
                }
