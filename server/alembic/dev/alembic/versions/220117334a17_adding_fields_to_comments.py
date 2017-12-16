"""adding fields to comments

Revision ID: 220117334a17
Revises: d53f39afbebb
Create Date: 2017-04-25 13:36:20.095260

"""
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = '220117334a17'
down_revision = 'd53f39afbebb'
branch_labels = None
depends_on = None


def upgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    op.add_column('comments', sa.Column('media_id', sa.String(), nullable=True))
    op.add_column('comments', sa.Column('user_id', sa.Integer(), nullable=True))
    op.create_foreign_key(None, 'comments', 'users', ['user_id'], ['id'])
    # ### end Alembic commands ###


def downgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    op.drop_constraint(None, 'comments', type_='foreignkey')
    op.drop_column('comments', 'user_id')
    op.drop_column('comments', 'media_id')
    # ### end Alembic commands ###