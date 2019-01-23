# ChemiReg - web-based compound registration platform
# Written in 2017 by David Damerell <david.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
#
# To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this software to the public domain worldwide. This software is distributed without any warranty.
# You should have received a copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.

# Haxe portion is MIT and SATurn portion is CC0
from nodeproviderblocking import haxe_Serializer
from nodeproviderblocking import haxe_ds_StringMap
from nodeproviderblocking import _hx_AnonObject

# Core Python
import urllib.request
import urllib.parse
import logging
import time
import os
import base64
import json

# BSD - 3 clause 2010 Ivan Safalaev
import ijson

# MIT 2013 Roy Hyunjin
from socketIO_client_nexus import SocketIO, LoggingNamespace

logging.getLogger('socketIO-client').setLevel(logging.INFO)
logging.basicConfig()

class NodeProvider(object):
    def __init__(self, hostname, port, username, password, cb1, cb2):
        self.hostname = hostname
        self.port = port
        self.username = username
        self.password = password
        self.auth_token = None
        self.socketIO = None

        self.next_msg_id = 0

        self.msg_id_to_callback = {}

        self._after_connect = cb1
        self._after_error = cb2
        self.closed = False

    def login(self):
        login_url = self.hostname + ':' + str(self.port) + '/login'

        values = {
            'username': self.username, 'password': self.password
        }

        data = urllib.parse.urlencode(values).encode('ascii')

        request = urllib.request.Request(login_url, data)

        print('Connecting to ' + login_url)

        attempts = 0
        attempt_limit = 4

        while True:
            try:
                with urllib.request.urlopen(request,timeout=5) as response:
                    content = response.read()

                    content_obj = json.loads(content.decode('ascii'))

                    if 'token' in content_obj:
                        self.auth_token = content_obj['token']

                        self.configure_socket()
                        break
                    else:
                        raise Exception('Authentication failed no token in response')
            except urllib.error.URLError as e:
                attempts += 1

                if attempts == attempt_limit:
                    print('Informing caller of error')
                    self.after_error(e)
                    break

                print('Sleeping!')
                print(e)
                time.sleep(10)
            except Exception as e:
                print(e)
                self.after_error(e)
                break

    def configure_socket(self):
        if self.hostname.startswith('https'):
            needs_sslv4 = True
        else:
            needs_sslv4 = False
        print('Creating WebSocket connection')
        self.socketIO = SocketIO(self.hostname, self.port, LoggingNamespace,False,transports=['xhr-polling'],needs_sslv4=needs_sslv4)
        time.sleep(3)
        self.socketIO.on('authenticated', self._socket_authenticated)
        self.socketIO.emit('authenticate', {'token': self.auth_token})
        self.socketIO.on('__response__', self._process_response)

        self.socketIO.on('reconnect', self._socket_authenticated)
        self.socketIO.on('connect', self._socket_authenticated)
        self.socketIO.on('disconnect', self._disconnected)
        self.socketIO.on('open', self._socket_authenticated)

        try:
            self.socketIO.wait()
        except Exception as e:
            raise e
            self.after_error(e)

    def _disconnected(self):
        if self.closed:
            return

        print('Disconnected')

        self.closed = True

    def _process_response(self, data):
        if 'bioinfJobId' in data:
            msg_id = data['bioinfJobId']

            if msg_id in self.msg_id_to_callback:
                error = None
                json = None

                if 'error' in data:
                    error = data['error']
                elif 'json' in data and 'error' in data['json']:
                    error = data['json']['error']
                else:
                    error = None

                if 'json' in data:
                    json = data['json']

                self.msg_id_to_callback[msg_id](error, json)

                self.msg_id_to_callback.pop(msg_id)

                #Important - otherwise we leak file descriptors
                # TODO: Check that this still closes file handles on Linux
                if hasattr(data, 'close'):
                    data.close()
            else:
                print('Warning message not found ' + msg_id)

    def handle_fetch(self, error, data):
        print(data)

    def _authenticate_socket(self):
        print('Authenticating')
        self.socketIO.emit('authenticate', {token: self.auth_token})

    def _socket_authenticated(self):
        self.after_connect()

    def after_connect(self):
        self._after_connect()

    def set_after_connect(self, cb):
        self._after_connect = cb

    def after_error(self, error):
        self._after_error(error)

    def get_by_named_query(self, query_id, data, cb):
        json = {"queryId": query_id, 'parameters': self._serialise(data)}

        def _cb(error, json):
            cb(error, data['objects'])

        self.run_query('_remote_provider_._data_request_objects_namedquery', json, cb)

    def upload_file(self, filename, cb):
        f = open(filename, 'rb')

        chunk_size = 1024 * 60000

        scope_obj = {'file_identifier': None}

        def upload_chunk():
            byte_buf = f.read(chunk_size)

            eof = len(byte_buf) != chunk_size

            def _cb(error, upload_id):
                if error is not None:
                    f.close()

                    cb(error, None)

                scope_obj['file_identifier'] = upload_id

                if not eof:
                    upload_chunk()
                else:
                    f.close()

                    cb(None, scope_obj['file_identifier'])

            self.upload_bytes_as_file(byte_buf, scope_obj['file_identifier'], _cb)

        upload_chunk()

    def upload_bytes_as_file(self, contents, file_identifer, cb):
        contents_b64 = base64.b64encode(contents).decode('ascii')
        json = {'contents': contents_b64, 'file_identifier': file_identifer}

        def _cb(error, json):
            cb(error, json['upload_id'])

        self.run_query('_remote_provider_._data_request_upload_file', json, _cb)

    def _convert_dictionaries(self, obj):
        for key in obj.keys():
            if type(obj[key]) == dict:
                obj[key] = self._convert_dictionaries(obj[key])

        return _hx_AnonObject(obj)

    def _serialise(self, params):
        a = self._convert_dictionaries(params)

        param_str = haxe_Serializer.run([a])

        return param_str

    def run_query(self, api_command, json, cb):
        msg_id = self.increment_next_id()

        json['msgId'] = msg_id

        self.register_callback(msg_id, cb)

        self.socketIO.emit(api_command, json)

    def register_callback(self, msg_id, cb):
        self.msg_id_to_callback[msg_id] = cb

    def increment_next_id(self):
        i = self.next_msg_id

        self.next_msg_id += 1

        return str(i)
