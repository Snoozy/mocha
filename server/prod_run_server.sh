cd src/
gunicorn -b 0.0.0.0:8000 server:app --daemon --log-file ../marble.log --pid ../marble.pid
