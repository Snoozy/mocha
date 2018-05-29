"""Vlogging

Revision ID: 8da406f568b8
Revises: 382fd2510203
Create Date: 2018-05-21 14:07:08.625170

"""
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = '8da406f568b8'
down_revision = '382fd2510203'
branch_labels = None
depends_on = None


def upgrade():
    # ### commands auto generated by Alembic - please adjust! ###
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
    op.create_table('vlogs',
    sa.Column('id', sa.Integer(), nullable=False),
    sa.Column('media_id', sa.String(), nullable=True),
    sa.Column('group_id', sa.Integer(), nullable=True),
    sa.Column('editor_id', sa.Integer(), nullable=True),
    sa.Column('description', sa.String(), nullable=True),
    sa.Column('timestamp', sa.BigInteger(), nullable=True),
    sa.ForeignKeyConstraint(['editor_id'], ['users.id'], ),
    sa.ForeignKeyConstraint(['group_id'], ['groups.id'], ),
    sa.PrimaryKeyConstraint('id')
    )
    op.create_index(op.f('ix_vlogs_editor_id'), 'vlogs', ['editor_id'], unique=False)
    op.create_index(op.f('ix_vlogs_group_id'), 'vlogs', ['group_id'], unique=False)
    op.add_column('comments', sa.Column('vlog_id', sa.Integer(), nullable=True))
    op.create_index(op.f('ix_comments_vlog_id'), 'comments', ['vlog_id'], unique=False)
    op.drop_index('ix_comments_story_id', table_name='comments')
    op.create_foreign_key(None, 'comments', 'vlogs', ['vlog_id'], ['id'])
    op.drop_column('comments', 'story_id')
    op.add_column('flags', sa.Column('clip_id', sa.Integer(), nullable=True))
    op.create_foreign_key(None, 'flags', 'clips', ['clip_id'], ['id'])
    op.drop_column('flags', 'story_id')
    # ### end Alembic commands ###


def downgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    op.add_column('flags', sa.Column('story_id', sa.INTEGER(), autoincrement=False, nullable=True))
    op.drop_constraint(None, 'flags', type_='foreignkey')
    op.drop_column('flags', 'clip_id')
    op.add_column('comments', sa.Column('story_id', sa.INTEGER(), autoincrement=False, nullable=True))
    op.drop_constraint(None, 'comments', type_='foreignkey')
    op.create_index('ix_comments_story_id', 'comments', ['story_id'], unique=False)
    op.drop_index(op.f('ix_comments_vlog_id'), table_name='comments')
    op.drop_column('comments', 'vlog_id')
    op.drop_index(op.f('ix_vlogs_group_id'), table_name='vlogs')
    op.drop_index(op.f('ix_vlogs_editor_id'), table_name='vlogs')
    op.drop_table('vlogs')
    op.drop_index(op.f('ix_clips_user_id'), table_name='clips')
    op.drop_index(op.f('ix_clips_timestamp'), table_name='clips')
    op.drop_index(op.f('ix_clips_group_id'), table_name='clips')
    op.drop_table('clips')
    # ### end Alembic commands ###
