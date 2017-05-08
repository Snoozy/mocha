"""prod update

Revision ID: 746ccf050342
Revises: 22ade4399541
Create Date: 2017-05-01 01:23:37.275015

"""
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = '746ccf050342'
down_revision = '22ade4399541'
branch_labels = None
depends_on = None


def upgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    op.create_table('comments',
    sa.Column('id', sa.Integer(), nullable=False),
    sa.Column('story_id', sa.Integer(), nullable=True),
    sa.Column('user_id', sa.Integer(), nullable=True),
    sa.Column('media_id', sa.String(), nullable=True),
    sa.Column('timestamp', sa.BigInteger(), nullable=True),
    sa.ForeignKeyConstraint(['story_id'], ['stories.id'], ),
    sa.ForeignKeyConstraint(['user_id'], ['users.id'], ),
    sa.PrimaryKeyConstraint('id')
    )
    # ### end Alembic commands ###


def downgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    op.drop_table('comments')
    # ### end Alembic commands ###
