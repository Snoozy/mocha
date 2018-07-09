"""Adding clip ids to vlog table

Revision ID: 924b702dbffd
Revises: 3a7751818a16
Create Date: 2018-06-27 17:36:55.133728

"""
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = '924b702dbffd'
down_revision = '3a7751818a16'
branch_labels = None
depends_on = None


def upgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    op.add_column('vlogs', sa.Column('clip_ids', sa.String(), nullable=True))
    # ### end Alembic commands ###


def downgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    op.drop_column('vlogs', 'clip_ids')
    # ### end Alembic commands ###