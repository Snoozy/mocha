from typing import Dict


RESP_ERR_JSON = {'status': 1}

GROUP_ID_XOR = 0x1FF


def resp_error(err: str = None):
    if err:
        return {'status': 1, 'error': err}
    else:
        return {'status': 1}


def resp_success(stuff: Dict = None):
    ret = {'status': 0}
    if stuff:
        ret.update(stuff)
    return ret
