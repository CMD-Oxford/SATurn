import json
import os
import sys

if sys.argv < 2:
  sys.exit('Invalid number of arguments provided')
  
input_json_path = sys.argv[len(sys.argv)-2]
output_json_path = sys.argv[len(sys.argv)-1]

input_json = None

with open(input_json_path, 'r') as f:
  input_json = json.load(f)
  
output_json = {'greetings': 'Hello ' + input_json['name']}

with open(output_json_path, 'w') as fw:
    fw.write(json.dumps(output_json))

