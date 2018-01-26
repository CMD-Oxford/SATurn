__author__ = 'David Damerell'

import sys
import os

class GenerateClientProgram(object):
	def __init__(self, workspace_class_name, object_class_name, program_class_name):
		self.workspace_class_name = workspace_class_name
		self.object_class_name = object_class_name
		self.program_class_name = program_class_name

		self.workspace_template = 'WorkspaceTemplate.hx'
		self.object_template = 'ObjectTemplate.hx'
		self.program_template = 'ProgramTemplate.hx'

		self.workspace_class_name_key = '<WORKSPACE_TEMPLATE>'
		self.object_class_name_key = '<OBJECT_TEMPLATE>'
		self.program_class_name_key = '<PROGRAM_TEMPLATE>'

		self.workspace_dst_dir = '../../src/saturn/client/workspace'
		self.object_dst_dir = '../../src/saturn/core'
		self.program_dst_dir = '../../src/saturn/client/programs'

		self.saturn_client_file = '../../src/saturn/app/SaturnClient.hx'
		self.saturn_client_file_tmp = '../../src/saturn/app/SaturnClient.hx.tmp'

		self.workspace_dst_file = self.workspace_dst_dir + '/' + self.workspace_class_name + '.hx'
		self.object_dst_file = self.object_dst_dir + '/' + self.object_class_name + '.hx'
		self.program_dst_file = self.program_dst_dir + '/' + self.program_class_name + '.hx'

		self.key_map = {
			self.workspace_class_name_key: self.workspace_class_name,
			self.object_class_name_key: self.object_class_name,
			self.program_class_name_key: self.program_class_name,
		}

		print "Generating: " + self.workspace_dst_file
		self.generate_file(self.workspace_template, self.workspace_dst_file, self.key_map)
		print "Generated: " + self.object_dst_file
		self.generate_file(self.object_template, self.object_dst_file, self.key_map)
		print "Generated: " + self.program_dst_file
		self.generate_file(self.program_template, self.program_dst_file, self.key_map)
		print "Updating: " + self.saturn_client_file
		self.generate_file(self.saturn_client_file, self.saturn_client_file_tmp, {
			'//<IMPORTS>': 'import saturn.client.programs.' + self.program_class_name + ';\n//<IMPORTS>',
			'//<LOAD_PROGRAMS>': 'this.getProgramRegistry().registerProgram(' + self.program_class_name + ', true);\n\t\t//<LOAD_PROGRAMS>'
		})
		os.remove(self.saturn_client_file)
		os.rename(self.saturn_client_file_tmp, self.saturn_client_file)



	def generate_file(self, input_file, output_file, key_map):
		with open(input_file, 'r') as f:
			with open(output_file, 'w') as fw:
				for line in f:
					for key in key_map.keys():
						line = line.replace(key, key_map[key])

					fw.write(line)

if __name__ == '__main__':
	if len(sys.argv) != 3:
		sys.exit('Usage\tWorkspace type name\n\tProgram class name');

	workspace_type_name = sys.argv[1]

	workspace_class_name = workspace_type_name + 'WO'
	object_class_name = workspace_type_name
	program_class_name = sys.argv[2]

	GenerateClientProgram(workspace_class_name, object_class_name, program_class_name)
