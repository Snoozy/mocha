"""Vlogging

Revision ID: 48d83f0edec3
Revises: 
Create Date: 2018-07-10 14:37:50.014433

"""
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = '48d83f0edec3'
down_revision = None
branch_labels = None
depends_on = None


def upgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    op.create_table('groups',
    sa.Column('id', sa.Integer(), nullable=False),
    sa.Column('name', sa.String(length=20), nullable=True),
    sa.Column('timestamp', sa.BigInteger(), nullable=True),
    sa.PrimaryKeyConstraint('id')
    )
    op.create_table('users',
    sa.Column('id', sa.Integer(), nullable=False),
    sa.Column('name', sa.String(length=20), nullable=True),
    sa.Column('username', sa.String(length=15), nullable=True),
    sa.Column('password', sa.String(length=100), nullable=True),
    sa.PrimaryKeyConstraint('id')
    )
    op.create_index(op.f('ix_users_username'), 'users', ['username'], unique=True)
    op.create_table('blocks',
    sa.Column('id', sa.Integer(), nullable=False),
    sa.Column('blocker_id', sa.Integer(), nullable=True),
    sa.Column('blockee_id', sa.Integer(), nullable=True),
    sa.Column('timestamp', sa.BigInteger(), nullable=True),
    sa.ForeignKeyConstraint(['blockee_id'], ['users.id'], ),
    sa.ForeignKeyConstraint(['blocker_id'], ['users.id'], ),
    sa.PrimaryKeyConstraint('id')
    )
    op.create_index(op.f('ix_blocks_blocker_id'), 'blocks', ['blocker_id'], unique=False)
    op.create_table('clips',
    sa.Column('id', sa.Integer(), nullable=False),
    sa.Column('media_id', sa.String(), nullable=True),
    sa.Column('is_memory', sa.SmallInteger(), nullable=True),
    sa.Column('group_id', sa.Integer(), nullable=True),
    sa.Column('user_id', sa.Integer(), nullable=True),
    sa.Column('timestamp', sa.BigInteger(), nullable=True),
    sa.ForeignKeyConstraint(['group_id'], ['groups.id'], ),
    sa.ForeignKeyConstraint(['user_id'], ['users.id'], ),
    sa.PrimaryKeyConstraint('id')
    )
    op.create_index(op.f('ix_clips_group_id'), 'clips', ['group_id'], unique=False)
    op.create_index(op.f('ix_clips_timestamp'), 'clips', ['timestamp'], unique=False)
    op.create_index(op.f('ix_clips_user_id'), 'clips', ['user_id'], unique=False)
    op.create_table('devices',
    sa.Column('id', sa.Integer(), nullable=False),
    sa.Column('type', sa.SmallInteger(), nullable=True),
    sa.Column('arn', sa.String(), nullable=True),
    sa.Column('token', sa.String(), nullable=True),
    sa.Column('user_id', sa.Integer(), nullable=True),
    sa.ForeignKeyConstraint(['user_id'], ['users.id'], ),
    sa.PrimaryKeyConstraint('id')
    )
    op.create_index(op.f('ix_devices_user_id'), 'devices', ['user_id'], unique=False)
    op.create_table('memberships',
    sa.Column('id', sa.Integer(), nullable=False),
    sa.Column('user_id', sa.Integer(), nullable=True),
    sa.Column('group_id', sa.Integer(), nullable=True),
    sa.Column('timestamp', sa.BigInteger(), nullable=True),
    sa.Column('last_seen', sa.BigInteger(), nullable=True),
    sa.ForeignKeyConstraint(['group_id'], ['groups.id'], ),
    sa.ForeignKeyConstraint(['user_id'], ['users.id'], ),
    sa.PrimaryKeyConstraint('id')
    )
    op.create_index(op.f('ix_memberships_group_id'), 'memberships', ['group_id'], unique=False)
    op.create_index(op.f('ix_memberships_user_id'), 'memberships', ['user_id'], unique=False)
    op.create_table('vlogs',
    sa.Column('id', sa.Integer(), nullable=False),
    sa.Column('media_id', sa.String(), nullable=True),
    sa.Column('group_id', sa.Integer(), nullable=True),
    sa.Column('editor_id', sa.Integer(), nullable=True),
    sa.Column('description', sa.String(), nullable=True),
    sa.Column('clip_ids', sa.String(), nullable=True),
    sa.Column('timestamp', sa.BigInteger(), nullable=True),
    sa.ForeignKeyConstraint(['editor_id'], ['users.id'], ),
    sa.ForeignKeyConstraint(['group_id'], ['groups.id'], ),
    sa.PrimaryKeyConstraint('id')
    )
    op.create_index(op.f('ix_vlogs_editor_id'), 'vlogs', ['editor_id'], unique=False)
    op.create_index(op.f('ix_vlogs_group_id'), 'vlogs', ['group_id'], unique=False)
    op.create_table('clip_likes',
    sa.Column('id', sa.Integer(), nullable=False),
    sa.Column('user_id', sa.Integer(), nullable=True),
    sa.Column('clip_id', sa.Integer(), nullable=True),
    sa.Column('timestamp', sa.BigInteger(), nullable=True),
    sa.ForeignKeyConstraint(['clip_id'], ['clips.id'], ),
    sa.ForeignKeyConstraint(['user_id'], ['users.id'], ),
    sa.PrimaryKeyConstraint('id')
    )
    op.create_index(op.f('ix_clip_likes_clip_id'), 'clip_likes', ['clip_id'], unique=False)
    op.create_index(op.f('ix_clip_likes_user_id'), 'clip_likes', ['user_id'], unique=False)
    op.create_table('comments',
    sa.Column('id', sa.Integer(), nullable=False),
    sa.Column('vlog_id', sa.Integer(), nullable=True),
    sa.Column('user_id', sa.Integer(), nullable=True),
    sa.Column('content', sa.String(), nullable=True),
    sa.Column('timestamp', sa.BigInteger(), nullable=True),
    sa.ForeignKeyConstraint(['user_id'], ['users.id'], ),
    sa.ForeignKeyConstraint(['vlog_id'], ['vlogs.id'], ),
    sa.PrimaryKeyConstraint('id')
    )
    op.create_index(op.f('ix_comments_user_id'), 'comments', ['user_id'], unique=False)
    op.create_index(op.f('ix_comments_vlog_id'), 'comments', ['vlog_id'], unique=False)
    op.create_table('flags',
    sa.Column('id', sa.Integer(), nullable=False),
    sa.Column('clip_id', sa.Integer(), nullable=True),
    sa.Column('timestamp', sa.BigInteger(), nullable=True),
    sa.ForeignKeyConstraint(['clip_id'], ['clips.id'], ),
    sa.PrimaryKeyConstraint('id')
    )
    # ### end Alembic commands ###


def downgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    op.drop_table('flags')
    op.drop_index(op.f('ix_comments_vlog_id'), table_name='comments')
    op.drop_index(op.f('ix_comments_user_id'), table_name='comments')
    op.drop_table('comments')
    op.drop_index(op.f('ix_clip_likes_user_id'), table_name='clip_likes')
    op.drop_index(op.f('ix_clip_likes_clip_id'), table_name='clip_likes')
    op.drop_table('clip_likes')
    op.drop_index(op.f('ix_vlogs_group_id'), table_name='vlogs')
    op.drop_index(op.f('ix_vlogs_editor_id'), table_name='vlogs')
    op.drop_table('vlogs')
    op.drop_index(op.f('ix_memberships_user_id'), table_name='memberships')
    op.drop_index(op.f('ix_memberships_group_id'), table_name='memberships')
    op.drop_table('memberships')
    op.drop_index(op.f('ix_devices_user_id'), table_name='devices')
    op.drop_table('devices')
    op.drop_index(op.f('ix_clips_user_id'), table_name='clips')
    op.drop_index(op.f('ix_clips_timestamp'), table_name='clips')
    op.drop_index(op.f('ix_clips_group_id'), table_name='clips')
    op.drop_table('clips')
    op.drop_index(op.f('ix_blocks_blocker_id'), table_name='blocks')
    op.drop_table('blocks')
    op.drop_index(op.f('ix_users_username'), table_name='users')
    op.drop_table('users')
    op.drop_table('groups')
    # ### end Alembic commands ###