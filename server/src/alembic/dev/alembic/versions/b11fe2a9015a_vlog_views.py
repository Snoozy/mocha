"""Vlog Views

Revision ID: b11fe2a9015a
Revises: 924b702dbffd
Create Date: 2018-07-30 23:51:23.750260

"""
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = 'b11fe2a9015a'
down_revision = '924b702dbffd'
branch_labels = None
depends_on = None


def upgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    op.add_column('vlogs', sa.Column('views', sa.Integer(), nullable=True))
    # ### end Alembic commands ###


def downgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    op.drop_column('vlogs', 'views')
    # ### end Alembic commands ###