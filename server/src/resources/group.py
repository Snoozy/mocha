from data.db.models.user import User
from data.db.models.group import Group
import json


class GroupCreateResource:
    def on_post(self, req, resp, user_id):
        name = req.get_param('name')
        user = req.session.query(User).filter(User.id == user_id).first()
        group = Group(name=name)
        group.users.append(user)
        req.session.add(group)
        resp.json = {
                    'status' : 0
                }


class FindGroupResource:
    def on_get(self, req, resp, user_id):
        code = req.get_param('code').lstrip("0")
        if not code or code == "":
            resp.json = {
                    'status': 1
                }
            return
        user = req.session.query(User).filter(User.id == user_id).first()
        group = req.session.query(Group).filter(Group.id == int(code)).first()
        if group:
            last_seen = None
            for m in user.memberships:
                if m.group.id == group.id:
                    last_seen = m.last_seen
            resp.json = {
                    'status': 0,
                    'group_name': group.name,
                    'member_count': group.memberships.count(),
                    'group_id': group.id,
                    'last_seen': last_seen
                }
        else:
            resp.json = {
                    'status': 1
                }


class ListGroupsResource:
    def on_get(self, req, resp, user_id):
        user = req.session.query(User).filter(User.id == user_id).first()
        groups = user.groups
        group_arr = []
        for g in groups:
            g_dict = g.to_dict()
            last_seen = None
            for m in user.memberships:
                if m.group.id == g.id:
                    last_seen = m.last_seen
                    break
            g_dict['last_seen'] = last_seen
            group_arr.append(g_dict)
        resp.json = {
                'status': 0,
                'groups': json.dumps(group_arr)
            }


class GroupJoinResource:
    def on_post(self, req, resp, user_id):
        group_id = req.get_param('group_id')
        user = req.session.query(User).filter(User.id == user_id).first()
        group = req.session.query(Group).filter(Group.id == int(group_id)).first()
        if not user or not group:
            resp.json = {
                'status': 1
                }
            return
        if user not in group.users:
            group.users.append(user)
        req.session.commit()
        resp.json = {
                'status': 0,
                'group': group.to_dict()
            }


class GroupLeaveResource:
    def on_post(self, req, resp, user_id):
        group_id = req.get_param('group_id')
        user = req.session.query(User).filter(User.id == user_id).first()
        group = req.session.query(Group).filter(Group.id == int(group_id)).first()
        if not user or not group:
            resp.json = {
                'status': 1
            }
            return
        for m in user.memberships:
            if m.group.id == int(group_id):
                req.session.delete(m)
                break
        req.session.commit()
        resp.json = {
            'status': 0,
            'group': group.to_dict()
        }
