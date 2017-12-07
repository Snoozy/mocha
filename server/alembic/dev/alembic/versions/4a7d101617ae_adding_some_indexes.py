"""Adding some indexes

Revision ID: 4a7d101617ae
Revises: d2c39b30bc86
Create Date: 2017-12-06 19:04:55.404086

"""
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = '4a7d101617ae'
down_revision = 'd2c39b30bc86'
branch_labels = None
depends_on = None


def upgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    op.create_index(op.f('ix_blocks_blocker_id'), 'blocks', ['blocker_id'], unique=False)
    op.create_index(op.f('ix_comments_story_id'), 'comments', ['story_id'], unique=False)
    op.create_index(op.f('ix_comments_user_id'), 'comments', ['user_id'], unique=False)
    op.create_index(op.f('ix_devices_user_id'), 'devices', ['user_id'], unique=False)
    op.create_index(op.f('ix_memberships_group_id'), 'memberships', ['group_id'], unique=False)
    op.create_index(op.f('ix_memberships_user_id'), 'memberships', ['user_id'], unique=False)
    op.create_index(op.f('ix_stories_group_id'), 'stories', ['group_id'], unique=False)
    op.create_index(op.f('ix_stories_timestamp'), 'stories', ['timestamp'], unique=False)
    op.create_index(op.f('ix_stories_user_id'), 'stories', ['user_id'], unique=False)
    op.create_index(op.f('ix_users_username'), 'users', ['username'], unique=True)
    op.drop_constraint('users_username_key', 'users', type_='unique')
    # ### end Alembic commands ###


def downgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    op.create_unique_constraint('users_username_key', 'users', ['username'])
    op.drop_index(op.f('ix_users_username'), table_name='users')
    op.drop_index(op.f('ix_stories_user_id'), table_name='stories')
    op.drop_index(op.f('ix_stories_timestamp'), table_name='stories')
    op.drop_index(op.f('ix_stories_group_id'), table_name='stories')
    op.drop_index(op.f('ix_memberships_user_id'), table_name='memberships')
    op.drop_index(op.f('ix_memberships_group_id'), table_name='memberships')
    op.drop_index(op.f('ix_devices_user_id'), table_name='devices')
    op.drop_index(op.f('ix_comments_user_id'), table_name='comments')
    op.drop_index(op.f('ix_comments_story_id'), table_name='comments')
    op.drop_index(op.f('ix_blocks_blocker_id'), table_name='blocks')
    # ### end Alembic commands ###
