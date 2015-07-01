# !/usr/bin/python

import re, sys, os, getopt

def parse_file(xmlfile):
	"""This will create a clean file for parsing"""
	print "We are now parsing" + xmlfile
	uscong_tmp = open(xmlfile, 'r') 
	alllines = uscong_tmp.read()
	#GetDate
	DateObject = re.compile(r'<date>(.+)<\/date>')
	Date = DateObject.findall(alllines[0:])
	#regex pattern that matches 'Mr.' with word boundary
	MrObject=re.compile(r'(\bMr.\s)')
	#This next line just tests for whether there are lowercase Mr.'s in the text
	#MrMatch = MrObject.findall(alllines[0])
	newtext = MrObject.sub('MR. ', alllines[0:])

	#Using look-back ?= for last name match and non-greedy .*? for text in middle
	SpeakerObject= re.compile(r'(The\sPRESIDENT\spro\stempore\s*|MR\.\s[A-Z]+)\b(.*?)\b(?=The\sPRESIDENT\spro\stempore\s*|MR\.\s[A-Z]+)')
	SpeakerMatchObj2 = SpeakerObject.findall(newtext)

	#Finding how many Speeches are within one day of a Congressional Record
	NumberofSpeakers = len(SpeakerMatchObj2)
	
	#print ("This record:", Date, "has %d speeches" %(NumberofSpeakers))
	print "This record:", Date, "has %d speeches" %NumberofSpeakers
	#Returns a list of speakers that gave speeches
	Speakers = SpeakerMatchObj2
	[item[0] for item in Speakers]
	#Date = str(Date)
	#Return a list of speakers that maps with a list of speech
	#mylists = SpeakerMatchObj2
	#list speaker items
	#[i for i,j in mylists]
	#list of speech items
	#[j for i,j in mylists]
	#print speaker and speeches 
	uscong_tmp.close()
	return (SpeakerMatchObj2, NumberofSpeakers, Date)


def write_file(SpeakerMatchObj2, count, NumberofSpeakers, Date, out_path):
	write_path = out_path + '/' + "Congressional_Record_Parsed"
	ret = os.access(write_path, os.F_OK)
	if ret == True:
		os.chdir(write_path)
		date_str = str(Date)+'.txt'
		if os.access(date_str, os.F_OK) == True:
			os.remove(date_str)
		outputfile = open(date_str, 'wb+')
		outputfile_content = "This data:"+ str(Date)+ '\n' + "This has this many speakers:" + str(NumberofSpeakers) + '\n'+ "This file is the:" + str(count) + '\n' + str(SpeakerMatchObj2)
		outputfile.write(outputfile_content) 
		outputfile.close()
	else:
		os.makedirs(write_path, 0777 )
		os.chdir(write_path)
		date_str = str(Date)+'.txt'
		outputfile = open(date_str, 'wb+')
		outputfile_content = "This data:"+ str(Date)+ '\n' + "This has this many speakers:" + str(NumberofSpeakers) + '\n'+ "This file is the:" + str(count) + '\n' + str(SpeakerMatchObj2)
		outputfile.write(outputfile_content) 
		outputfile.close()


def main(argv):
	#Getting the Input and Output files straight
	file_name = ''
	out_path = os.getcwd()
	in_path = os.getcwd()	
	try:
	  opts, args = getopt.getopt(argv,"h:i:o:",["help","ipath=","opath="])
	except getopt.GetoptError:
	  print 'US_parsetext_WI.py -i <input_path> -o <output_path>'
	  sys.exit(2)
	for opt, arg in opts:
	  if opt == '-h':
	     print 'US_parsetext_WI.py -i <input_path> -o <output_path>'
	     sys.exit()
	  elif opt in ("-i", "--ipath"):
	     in_path = arg
	  elif opt in ("-o", "--opath"):
	     out_path = arg
	print 'Input path is "', in_path
	print 'Output path is "', out_path


	#Now Running the Parsing functions
	dll = sorted(os.listdir(in_path))
	xmlfile = [s for s in dll if ".xml" in s]
	count = 0 
	for xml_file in xmlfile:
		count += 1
		SpeakerMatchObj2, NumberofSpeakers, Date = parse_file(xml_file)
		write_file(SpeakerMatchObj2, count, NumberofSpeakers, Date, out_path)



if __name__ == "__main__":
	main(sys.argv[1:])
