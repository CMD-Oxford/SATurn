#
# SATURN (Sequence Analysis Tool - Ultima regula natura)
# Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
#
# To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
# software to the public domain worldwide. This software is distributed without any warranty. You should have received a
# copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
#

__author__ = 'David Damerell'

import sys
import json

from abifpy import Trace

def generate_files(data, base_file_name, suffix):
	data['LABELS'] = []

	for i in range(0, len(data['CH1'])):
		data['LABELS'].append('')

	for i in range(0, len(data['PLOC2'])):
		peak = data['PLOC2'][i] - 1
		nuc = data['SEQ'][i]

		data['LABELS'][peak] = nuc

	#Generate JSON dump of data
	json_data = json.dumps(data)

	#Output JSON dump to file
	with open(output_file_name + suffix + '.json', 'w') as fw:
		fw.write(json_data)

	#Output TSV file
	with open(output_file_name + suffix + '.tsv', 'w') as fw:
		fw.write('POS\tCH1\tCH2\tCH3\tCH4\n')
		for i in range(0, len(data['CH1'])):

			fw.write(str(i) + '\t' + str(data['CH1'][i]) + '\t' + str(data['CH2'][i]) + '\t' + str(data['CH3'][i]) + '\t' + str(data['CH4'][i]) + '\t' + data['LABELS'][i] + '\n')# + '\t' + peak_label + '\n')

def auto_prune(data):
	first_nuc = 0
	last_nuc = 0

	pruned_data = {'CH1': [], 'CH2': [], 'CH3': [], 'CH4':[], 'PLOC2':[], 'SEQ':[]}

	for i in range(0, len(data['SEQ'])):
		nuc = data['SEQ'][i]

		if not nuc is 'N':
			nuc_pos = data['PLOC2'][i]
			if first_nuc == 0:
				first_nuc = nuc_pos

			last_nuc = nuc_pos

			pruned_data['SEQ'].append(nuc)
			pruned_data['PLOC2'].append(nuc_pos - first_nuc + 1) #keep one based

	pruned_data['OFFSET'] = first_nuc
	pruned_data['CH1'] = data['CH1'][first_nuc-1: last_nuc]
	pruned_data['CH2'] = data['CH2'][first_nuc-1: last_nuc]
	pruned_data['CH3'] = data['CH3'][first_nuc-1: last_nuc]
	pruned_data['CH4'] = data['CH4'][first_nuc-1: last_nuc]

	return pruned_data

if __name__ == '__main__':
	if not len(sys.argv) == 3:
		sys.exit('Usage\tTrace file\tOutput file name')

	trace_file = sys.argv[1]
	output_file_name = sys.argv[2]

	#Load trace
	trace = Trace(trace_file)

	#Extract analysed trace data
	data = {'SEQ':trace.seq,
			'CH1': trace.tags['DATA9'].tag_data,
			'CH2': trace.tags['DATA10'].tag_data,
			'CH3': trace.tags['DATA11'].tag_data,
			'CH4': trace.tags['DATA12'].tag_data,
			'PLOC2': trace.tags['PLOC2'].tag_data,
			'OFFSET': 0
	}

	generate_files(data, output_file_name, '_full_trace')

	pruned_data = auto_prune(data)

	generate_files(pruned_data, output_file_name, '_pruned_data')