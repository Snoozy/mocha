from data.aws import boto_session
import json
from botocore.exceptions import ClientError

from data.db.models.story import Story


def send_notification(device, message, badge_num=0):
    sns = boto_session.resource('sns', region_name='us-west-2')
    plat_endpoint = sns.PlatformEndpoint(device.arn)
    if not plat_endpoint:
        return
    apns_json = {
            'aps': {
                'alert': message,
                'badge': badge_num
            }
        }
    apns = json.dumps(apns_json, ensure_ascii=False)
    msg = {
            'default': message,
            'APNS': apns,
            'APNS_SANDBOX': apns
        }
    try:
        plat_endpoint.publish(
                Message=json.dumps(msg),
                MessageStructure='json'
            )
    except ClientError:
        print("disabled endpoint")


def get_user_badge_num(user):
    badge_num = 0
    for membership in user.memberships:
        last_seen = membership.last_seen
        last_story = membership.group.stories.order_by(Story.timestamp.desc()).first()
        if last_story and last_seen and last_story.timestamp > last_seen:
            badge_num += 1
    return badge_num

