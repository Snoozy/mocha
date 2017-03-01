from sqlalchemy import *
from ..db import Base

UserToUser = Table('user_to_user',
        Base.metadata,
        Column('id', Integer, primary_key=True),
        Column('user1_id', Integer, ForeignKey('users.id')),
        Column('user2_id', Integer, ForeignKey('users.id'))
)
