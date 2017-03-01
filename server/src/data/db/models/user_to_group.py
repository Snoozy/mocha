from sqlalchemy import *
from ..db import Base

UserToGroup = Table('user_to_group',
        Base.metadata,
        Column('id', Integer, primary_key=True),
        Column('user_id', Integer, ForeignKey('users.id')),
        Column('group_id', Integer, ForeignKey('groups.id'))
)
