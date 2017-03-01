import falcon
from data.db.models.user import User
from data.db.models.group import Group
from data.db.models.user_to_group import UserToGroup
import json

class GroupCreateResource:
    def on_post(self, req, resp, user_id):
        name = req.get_param('name')
        user = req.session.query(User).filter(User.id == user_id).first()
        group = Group(name=name)
        group.users.append(user)
        req.session.add(group)
        resp.context['json'] = {
                    'status' : 0
                }


class FindGroupResource:
    def on_get(self, req, resp, user_id):
        code = req.get_param('code').lstrip("0")
        user = req.session.query(User).filter(User.id == user_id).first()
        group = req.session.query(Group).filter(Group.id == int(code)).first()
        if group:
            resp.context['json'] = {
                    'status' : 0,
                    'group_name' : group.name,
                    'member_count' : group.users.count(),
                    'group_id' : group.id
                }
        else:
            resp.context['json'] = {
                    'status' : 1
                }


class ListGroupsResource:
    def on_get(self, req, resp, user_id):
        user = req.session.query(User).filter(User.id == user_id).first()
        groups = user.groups
        json_string = json.dumps([{"name" : g.name, "group_id" : g.id} for g in groups])
        resp.context['json'] = {
                'status' : 0,
                'groups' : json_string
            }

class GroupJoinResource:
    def on_post(self, req, resp, user_id):
        group_id = req.get_param('group_id')
        group = req.session.query(Group).filter(Group.id == int(group_id)).first()
        user = req.session.query(User).filter(User.id == user_id).first()
        if user not in group.users:
            group.users.append(user)
        resp.context['json'] = {
                'status' : 0
            }
