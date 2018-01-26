__author__ = 'David Damerell'

import sys
import os

class GenerateScript(object):
	def __init__(self, script_name):
		self.script_name = script_name

		self.script_template = 'ScriptTemplate.hx'

		self.script_class_name_key = '<NAME>'

		self.script_dst_dir = '../../src/saturn/scripts'


		self.script_dst_file = self.script_dst_dir + '/' + self.script_name + '.hx'

		self.key_map = {
			self.script_class_name_key: self.script_name,
		}

		print "Generating: " + self.script_dst_file
		self.generate_file(self.script_template, self.script_dst_file, self.key_map)



	def generate_file(self, input_file, output_file, key_map):
		with open(input_file, 'r') as f:
			with open(output_file, 'w') as fw:
				for line in f:
					for key in key_map.keys():
						line = line.replace(key, key_map[key])

					fw.write(line)

if __name__ == '__main__':
	if len(sys.argv) != 2:
		sys.exit('Usage\tScript Name\n');

	script_name = sys.argv[1]


	GenerateScript(script_name)
