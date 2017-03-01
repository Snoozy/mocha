import redis
from config import config

redis_client = redis.StrictRedis(host=config['redis']['host'], port=config['redis']['port'])
