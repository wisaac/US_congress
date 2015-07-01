#!/usr/bin/python

####################################################################
### FD SYS Scrapping Project | William Isaac | June 29th, 2015 	 ###
####################################################################



##########################
#Section 1: Module Import#
##########################

import mechanize, sys, os, time, random, pprint, re, csv
from BeautifulSoup import BeautifulSoup

###################################################
#Section 2: Creating Directory to Place Zip Files #
###################################################

new_path = "~/GitHub/US_congress/FDSYS_scrapper"
outpath = os.path.expanduser(new_path)
#os.chdir(new_path_1)
#setting date and time
nname = time.strftime("%b")
date = time.strftime("%d")
ver = random.randrange(0, 999, 2)

####################################				
#  Section 3: Writing Functions	   #
####################################

def grab_links():
	""" This is used to get the source links for each hearing """

	br=mechanize.Browser()
	br.addheaders = [('User-agent', 'Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.9.0.1) Gecko/2008071615 Fedora/3.0.1-1.fc9 Firefox/3.0.1')]
	br.set_handle_robots(False)
	src_links=[]
	hr_links=[]
	for i in range(2):
		i=+1
		tmp_link = 'http://www.gpo.gov/fdsys/search/search.action?sr={0}&originalSearch=&st=collection%3aCHRG+and+content%3a(teacher+quality)&ps=10&na=&se=&sb=re&timeFrame=&dateBrowse=&govAuthBrowse=&collection=&historical=false'.format(i)
		src_links.append(tmp_link)
	pp = pprint.PrettyPrinter(indent=4)
	#This is where I am grabbing the links for each hearing
	for s_link in src_links:
		response = br.open(s_link)
		for link in br.links():
		    if "More Information" in link.text:
		            hr_links.append(link.url)
	return hr_links



def grab_meta(hr_links):
	""" This function is going to grab metadata and links """
	#This function should return hearing title, date, and raw text


	#Setting BS and printing html output
	br=mechanize.Browser()
	br.addheaders = [('User-agent', 'Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.9.0.1) Gecko/2008071615 Fedora/3.0.1-1.fc9 Firefox/3.0.1')]
	br.set_handle_robots(False)
	new_link = "http://www.gpo.gov" + hr_links
	print new_link
	response = br.open(new_link)
	html = response.read()
	soup = BeautifulSoup(html)
	#print(soup.prettify())


	#Looking for link to pdf of hearing text
	pdf_link = soup.findAll(href=re.compile(".pdf"), limit = 1)
	print "This is the PDF link:" + str(pdf_link)

	#Looking for html link of raw text
	tags = soup.findAll('a',href=True)
	for tag in tags:
	 	if "Text" in tag.contents:
	 		text_link = str(tag['href'])
	 		print "This is the Text link:" + text_link
	rawtext = br.open(text_link)
	rawtext = rawtext.read()
	rawtext = text_link

	#Getting Hearing Date
	tags = soup.findAll('td', text = re.compile("\w+\s\d+.\s\d+"), limit = 1)
	date = str(tags)
	print "This is the Date: " + date
	date = date.strip("[ ]")
	# for tag in tags:
	# 		print tag.contents
		  	# date = str(tag.next)
	# 	  	print "This is the Date: " + date

	#Looking for Hearing Title and Serial Number
	tags = soup.find('h3')
	title = tags.string
	title = title.strip()

	return (pdf_link,rawtext,date,title)

	#This can be used to extract raw text in a single line "bs4.BeautifulSoup(urllib.urlopen('http://google.com/?hl=en').read()).select('#footer a')"

def write_file(csv_rows = [], *args):
	""" This function is to write out the files to csv """
	
	#This is creating the output folder path and determining whether the directory exists.
	write_path = outpath + '/' + "output"
	ret = os.access(write_path, os.F_OK)
	header = ('Date', 'Title', 'PDF link', 'Raw Text link')
	z = len(csv_rows)

	#Writing the CSV File
	if ret == True:
		os.chdir(write_path)
		filename = 'tq_out.%s.%s.%03d.csv' %(nname,date,ver)
		if os.access(filename, os.F_OK) == True:
			os.remove(filename)
		outputfile = open(filename, 'wb+')
		writer = csv.writer(outputfile)
		writer.writerow(header)
		for i in range(z):
			writer.writerow(csv_rows[i]) 
		outputfile.close()
	else:
		os.makedirs(write_path, 0777)
		os.chdir(write_path)
		filename = 'tq_out.%s.%s.%03d.csv' %(nname,date,ver)
		outputfile = open(filename, 'wb+')
		writer = csv.writer(outputfile)
		writer.writerow(header)
		for i in range(z):
			writer.writerow(csv_rows[i]) 
		outputfile.close()

####################################				
# Section 4: Running Functions 	   #
####################################
hr_links = grab_links()
y=len(hr_links)

print hr_links
print y
csv_rows = []
for i in range(y):
	print "Working on link" + str(i)
	#We need to write something here that will collect the output from grab_meta into an arrary.  
	pdf_link,rawtext,date,title = grab_meta(hr_links[i])
	row = date, title, pdf_link, rawtext
	csv_rows.append(row)
write_file(csv_rows)