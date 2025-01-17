#!/bin/bash
. ../mvenv/bin/activate
cd src/
gunicorn -b 0.0.0.0:8000 server:app --reload --log-level=DEBUG --timeout 300 --worker-class gevent
