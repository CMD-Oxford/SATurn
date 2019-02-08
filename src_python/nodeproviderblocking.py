# ChemiReg - web-based compound registration platform
# Written in 2017 by David Damerell <david.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
#
# To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this software to the public domain worldwide. This software is distributed without any warranty.
# You should have received a copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.

# ChemiReg CC0
from nodeprovider import NodeProvider

# Core Python
from threading import Lock
import threading
import os
import pprint
import uuid
from time import sleep
import tempfile
import urllib

class NodeProviderBlocking(object):
    def __init__(self, hostname, port, username, password):
        # ChemiReg hostname include protocol (https/http)
        self.hostname = hostname

        # ChemiReg port
        self.port = port

        # ChemiReg username
        self.username = username

        # ChemiReg password
        self.password = password

        # Lock to synchronize threads
        self.lock = Lock()

        # Variable to store web-service call results
        self.blocking_results = {'ready': False}

        # Variable to instruct web-service thread
        self.blocking_input = {}

        # Used to communicate between threads
        self.wait_event = threading.Event()

        # Thread for listen for messages
        self.web_socket_thread = None

        self.error = None

    def set_ready(self, ready):
        self.lock.acquire()
        try:
            self.blocking_results['ready'] = ready
        finally:
            self.lock.release()

    def set_state(self, error, objects, ready):
        self.lock.acquire()
        try:
            self.blocking_results['error'] = error
            self.blocking_results['objects'] = objects
            self.blocking_results['ready'] = ready
        finally:
            self.lock.release()

    def is_ready(self):
        self.lock.acquire()
        try:
            return self.blocking_results['ready']
        finally:
            self.lock.release()  # release lock, no matter what

    def block_call(self):
        while True:
            if self.is_ready():
                return self.blocking_results
            else:
                sleep(0.05)

    def _process_response(self, error, json):
        if 'objects' in json and json['objects'] is not None:
            if 'upload_set' in json['objects'][0]:
                objs = json['objects'][0]['upload_set']
            elif 'refreshed_objects' in json['objects'][0]:
                objs = json['objects'][0]['refreshed_objects']
            else:
                objs = json['objects'][0]
        else:
            objs = json

        self.set_state(error, objs, True)

    def connect(self):
        # Initialise NodeProvider which handles communication with ChemiReg via a WebSocket
        self.provider = NodeProvider(self.hostname, self.port, self.username, self.password, None, None)

        # This function is called after the connection has been established
        def after_connect():
            # Used to inform the initiating thread that we are connected (releases the block)
            self.set_ready(True)

        def after_error(err):
            self.set_ready(True)
            self.error = err

        def start_login():
            self.provider._after_connect = after_connect
            self.provider._after_error = after_error
            self.provider.login()

        self.web_socket_thread = threading.Thread(target=start_login)
        self.web_socket_thread.start()

        while True:
            if self.is_ready():
                if self.error is None:
                    break
                else:
                    self.close()
                    raise self.error


    def _close(self):
        if self.provider.socketIO is not None:
            print('Closing WebSocket!')
            self.provider.socketIO.__exit__()

    def close(self):
        self._close()

        self.web_socket_thread.join()


    def get_by_named_query(self,command_name, arguments):
        self.set_ready(False)

        self.provider.get_by_named_query(command_name, arguments, self._process_response)

        return self.block_call()

    def run_query(self, command_name, arguments):
        self.set_ready(False)

        self.provider.run_query(command_name, arguments, self._process_response)

        return self.block_call()

if __name__ == '__main__':
    tests = NodeProviderBlocking('http://localhost', 80, 'username', 'password')
