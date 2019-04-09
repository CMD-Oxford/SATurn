import urllib.request
import urllib.parse
import json
import os
from typing import NoReturn


class SATurnRESTController(object):
    """SATurnRESTController provides a simple Python API to call the SATurn REST API"""
    def __init__(self, json_config_path: str):
        """
        Constructor loads the SATurn service configuration

        Parameters
        ----------

        :param json_config_path: Path to the SATurn service configuration json file

        Raises
        ------
        SATurnRESTConfigurationError

        """

        # Location of the SATurn service configuration file
        self.json_config_path = json_config_path

        # Base URL to form SATurn REST calls with
        self.base_url = None

        # SATurn service configuration object
        self.config = None

        # Loads the SATurn service configuration into self.config
        self._load_service_configuration()

        # Sets self.base_url based on the SATurn service configuration
        self._set_base_url()

        # Last authentication token obtained
        self.token = None

    def _set_base_url(self) -> NoReturn:
        """
        sets, self.base_url with the base URL to form SATurn REST URLs from


        Raises
        ------

        SATurnRESTConfigurationError
        """

        hostname = None
        port = None
        protocol = 'http'

        if 'hostname' not in self.config:
            raise SATurnRESTConfigurationError('hostname field missing from ' + self.json_config_path)
        else:
            hostname = self.config['hostname']

        if 'port' not in self.config:
            raise SATurnRESTConfigurationError('port field missing from ' + self.json_config_path)
        else:
            port = self.config['port']

        if 'restify_http_options' in self.config and 'cert' in self.config['restify_http_options']:
            protocol = 'https'

        self.base_url = protocol + '://' + hostname + ':' + port

    def _load_service_configuration(self) -> NoReturn:
        """
        Parses the SATurn service configuration into self.config

        Raises
        ------
        SATurnRESTConfigurationError
        """

        if not os.path.exists(self.json_config_path):
            raise SATurnRESTConfigurationError('Unable to find file ' + self.json_config_path)

        self.config = json.load(self.json_config_path)

    def _get_authentication_configuration(self) -> dict:
        """
        returns a dictionary containing the username and password to authenticate against the REST service

        Raises
        ------
        SATurnRESTConfigurationError

        Returns
        -------
        {
            username: <username>,
            password: <password>
        }
        """

        if 'default_rest_credentials' not in self.config:
            raise SATurnRESTConfigurationError('Please set the default_rest_credentials configuration parameter')

        return self.config['default_rest_credentials']

    def run_query(self, command : str, args : dict, method :str = None) -> dict:
        """
        Runs a SATurn REST API command

        Parameters
        ----------
        :param command: SATurn REST API command (i.e. /api/blastdbs/constructs
        :param args: Any arguments required for the REST command
        :param method: HTTP verb

        Returns
        -------
        :return: dictionary of response from REST command
        """
        url = self.base_url + '/' + command
        data = urllib.parse.urlencode(args)
        data = data.encode('ascii')

        req = urllib.request.Request(url, data)

        if method is not None:
            req.get_method = lambda: method

        with urllib.request.urlopen(req) as res:
            ret_val = res.read()
            return json.loads(ret_val)

    def authenticate(self) -> NoReturn:
        """
        Obtains an authentication token from SATurn using the username and password stored in the SATurn service config

        """
        command = 'login'

        res = self.run_query(self.base_url, command, self._get_authentication_configuration())

        if res is None:
            raise Exception('Empty authentication response from server')

        if 'token' not in res or res['token'] is None:
            raise Exception('Token not found in response')

        self.token = res['token']

class SATurnControllerFactory(object):
    """
    Builds new  SATurnRESTController instances
    """
    def __init__(self):
        pass

    @staticmethod
    def get_default_controller() -> SATurnRESTController:
        """
        Returns a configured SATurnRESTController using the SATurn service configuration file referenced in SATURN_SERVICE_FILE

        """
        if 'SATURN_SERVICE_FILE' not in os.environ:
            raise Exception('Please set the SATURN_SERVICE_FILE environment variable to the location of the SATurn service configuration')

        return SATurnRESTController(os.environ['SATURN_SERVICE_FILE'])

class SATurnDefaultRESTHelper(object):
    """
    Provides a set of Python methods which call the SATurn REST API

    Parameters
    ----------
    :param rest_controller: Configured and authenticated SATurnRESTController instance

    """
    def __init__(self, rest_controller : SATurnRESTController):
        self.rest_controller = rest_controller

    def update_all(self):
        """
        Updates all BLAST databases using the SATurn REST API

        """

        # List of default BLAST databases
        databases = [
            'construct_protein',
            'construct_protein_no_tag',
            'construct_nucleotide',
            'allele_nucleotide',
            'allele_protein',
            'entryclone_nucleotide',
            'entryclone_protein',
            'target_nucleotide',
            'target_protein',
            'vector_nucleotide'
        ]

        for database in databases:
            # Request rebuild of BLAST database
            command = 'api/blastdbs/' + database

            # Wait for each rebuild
            self.rest_controller.run_query(command, {'wait': 'yes'}, 'PUT')


class SATurnRESTConfigurationError(Exception):
    """
    SATurn service configuration format error
    """
    pass

if __name__ == '__main__':
    controller = SATurnControllerFactory.get_default_controller()
    controller.authenticate()

    helper = SATurnDefaultRESTHelper(controller)
