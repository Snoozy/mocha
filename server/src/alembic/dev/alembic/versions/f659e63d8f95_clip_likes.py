"""Clip likes

Revision ID: f659e63d8f95
Revises: 8da406f568b8
Create Date: 2018-06-20 13:07:58.907447

"""
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = 'f659e63d8f95'
down_revision = '8da406f568b8'
branch_labels = None
depends_on = None


def upgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    op.add_column('comments', sa.Column('content', sa.String(), nullable=True))
    op.drop_column('comments', 'media_id')
    # ### end Alembic commands ###


def downgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    op.add_column('comments', sa.Column('media_id', sa.VARCHAR(), autoincrement=False, nullable=True))
    op.drop_column('comments', 'content')
    # ### end Alembic commands ###
