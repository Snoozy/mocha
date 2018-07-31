# File for common etc stuff

from etc.hashids import Hashids


GROUP_CODE_SALT = '8eyPYPbWNkJBLrZJWmsx'
hashid = Hashids(salt=GROUP_CODE_SALT, min_length=14)


def group_code_from_id(id):
    return hashid.encode(id)


def group_id_from_code(code):
    return hashid.decode(code)
