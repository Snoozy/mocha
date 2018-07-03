import time
from data.db.models.user import User
from data.db.models.clip import Clip


class BlockUserResource:
    def on_post(self, req, resp, user_id):
        user = req.session.query(User).filter(User.id == user_id).first()
        blockee_id = req.get_param('blockee_id')
        blockee = req.session.query(User).filter(User.id == blockee_id).first()
        if not user or not blockee:
            resp.json = {
                    'status': 1,
                    'error': 'Blockee does not exist.'
                }
            return
        if user.id == blockee_id:
            resp.json = {
                    'status': 2,
                    'error': 'Cannot block yourself.'
                }
        if blockee not in user.blocks:
            user.blocks.append(blockee)
        resp.json = {
                'status': 0
            }
        return
