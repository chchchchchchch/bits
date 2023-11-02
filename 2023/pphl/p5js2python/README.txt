RUN LOCAL WEBSERVER:
python3 -m http.server

RUN LOCAL WEBSOCKET:
python3 websocket-server.py

GO TO:
-> http://localhost:8000/index.html

RUN:
python websocket-client.py

----

REQUIRES:
pip install websocket-client

https://github.com/Pithikos/python-websocket-server
pip install websocket_server
