from data.db.models.user import User
from data.db.models.group import Group
from data.db.models.clip import Clip
import json
import falcon
from etc.common import group_code_from_id, group_id_from_code
from resources.constants import RESP_ERR_JSON, resp_success, resp_error
from falcon import Request, Response


class GroupCreateResource:
    def on_post(self, req, resp, user_id):
        name = req.get_param('name')
        if not name or name == '':
            resp.json = resp_error()
            return
        user = req.session.query(User).filter(User.id == user_id).first()
        group = Group(name=name)
        group.users.append(user)
        req.session.add(group)
        req.session.commit()
        resp.json = resp_success({'group': group.to_dict()})


class FindGroupResource:

    needs_auth = False

    def on_get(self, req, resp, user_id):
        code = req.get_param('code')
        if not code or code == "":
            resp.json = resp_error()
            raise falcon.HTTPBadRequest()
        group_id = group_id_from_code(code)
        if not group_id:
            resp.json = resp_error('Bad group code')
            raise falcon.HTTPBadRequest()
        user = req.session.query(User).filter(User.id == user_id).first()
        group = req.session.query(Group).filter(Group.id == group_id).first()
        if group:
            if not user:
                resp.set_header('Access-Control-Allow-Origin', '*')
                resp.json = {
                    'status': 0,
                    'group_name': group.name,
                    'member_count': group.memberships.count(),
                    'group_id': group.id,
                    'code': group_code_from_id(group.id),
                }
                return
            last_seen = None
            for m in user.memberships:
                if m.group.id == group.id:
                    last_seen = m.last_seen
            resp.json = {
                'status': 0,
                'group_name': group.name,
                'member_count': group.memberships.count(),
                'group_id': group.id,
                'code': group_code_from_id(group.id),
                'last_seen': last_seen
            }
        else:
            resp.json = resp_error()
            raise falcon.HTTPBadRequest()


class ListGroupsResource:
    def on_get(self, req, resp, user_id):
        user = req.session.query(User).filter(User.id == user_id).first()
        if not user:
            resp.json = resp_error('User id error')
            raise falcon.HTTPBadRequest()

        def get_group_recent_timestamp(group):
            most_recent_clip = group.clips.order_by(Clip.timestamp.desc()).first()
            print(group.name)
            if most_recent_clip is None:
                print(group.timestamp)
                return group.timestamp
            else:
                print(most_recent_clip.timestamp)
                return most_recent_clip.timestamp

        groups = sorted(user.groups, key=lambda x: get_group_recent_timestamp(x), reverse=True)
        for g in groups:
            print(g.name)
        group_arr = []
        for g in groups:
            g_dict = g.to_dict()
            last_seen = None
            for m in user.memberships:
                if m.group.id == g.id:
                    last_seen = m.last_seen
                    break
            g_dict['last_seen'] = last_seen

            # determine if vlog nudge should be shown
            # nudge_test = req.session.query(Clip).limit(5).all()
            nudges = []
            g_dict['vlog_nudge_clips'] = [c.to_dict(user) for c in nudges]

            group_arr.append(g_dict)
        resp.json = {
            'status': 0,
            'groups': group_arr
        }


class GroupJoinResource:
    def on_post(self, req, resp, user_id):
        code = req.get_param('code')
        if not code or code == '':
            resp.json = resp_error()
            raise falcon.HTTPBadRequest()
        group_id = group_id_from_code(code)
        group = req.session.query(Group).filter(Group.id == int(group_id)).first()
        user = req.session.query(User).filter(User.id == user_id).first()
        if not user or not group:
            resp.json = resp_error()
            raise falcon.HTTPBadRequest()
        if user not in group.users:
            group.users.append(user)
        req.session.commit()
        resp.json = {
            'status': 0,
            'group': group.to_dict()
        }


class GroupLeaveResource:
    def on_post(self, req: Request, resp: Response, user_id: int):
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


class GroupInfoResource:
    def on_get(self, req: Request, resp: Response, user_id: int):
        group_id = req.get_param('group_id')
        if not group_id:
            resp.json = RESP_ERR_JSON
            return
        user = req.session.query(User).filter(User.id == user_id).first()
        group = req.session.query(Group).filter(Group.id == int(group_id)).first()
        if not user or not group or user not in group.users:
            resp.json = RESP_ERR_JSON
            return
        members_info = [u.to_dict() for u in group.users]
        resp.json = {
            'members': members_info
        }
