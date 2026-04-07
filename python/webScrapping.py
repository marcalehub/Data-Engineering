import requests as InvokeWeb_Request
from time import sleep

response = InvokeWeb_Request.get(url='https://www.one.gob.do/datos-y-estadisticas/')
status = response.status_code
data = response.json()