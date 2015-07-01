#!/usr/bin/python

####################################################################
### FD SYS Scrapping Project | William Isaac | June 29th, 2015 	 ###
####################################################################



##########################
#Section 1: Module Import#
##########################

import mechanize, sys, os, time, random, pprint, re
from BeautifulSoup import BeautifulSoup

###################################################
#Section 2: Creating Directory to Place Zip Files #
###################################################

new_path = "~/GitHub/US_congress/FDSYS_scrapper"
outpath = os.path.expanduser(new_path)+'/output'
#os.chdir(new_path_1)
#setting date and time
nname = time.strftime("%b")
date = time.strftime("%d")
ver = random.randrange(0, 999, 2)

####################################				
# Section 3: Gather Core file links#
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
		    print link.text, link.url
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

	#Getting Hearing Date
	tags = soup.findAll('td', text = re.compile("\w+\s\d+.\s\d+"), limit = 1)
	date = str(tags)
	print "This is the Date: " + date
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

def write_file(csv_rows):
	




	write_path = out_path + '/' + "Congressional_Record_Parsed"
	ret = os.access(write_path, os.F_OK)
	row = date, title, pdf_link, rawtext  
	if ret == True:
		os.chdir(write_path)
		date_str = str(Date)+'.txt'
		if os.access(date_str, os.F_OK) == True:
			os.remove(date_str)
		outputfile = open(date_str, 'wb+')
		outputfile.close()
	else:
		os.makedirs(write_path, 0777 )
		os.chdir(write_path)
		date_str = str(Date)+'.txt'
		outputfile = open(date_str, 'wb+')
		outputfile_content = "This data:"+ str(Date)+ '\n' + "This has this many speakers:" + str(NumberofSpeakers) + '\n'+ "This file is the:" + str(count) + '\n' + str(SpeakerMatchObj2)
		outputfile.write(outputfile_content) 
		outputfile.close()


try:
    finished='N' 
    #This is using the xml parsing software to pull the text from the file
    os.chdir(inpath)
    tree = ET.parse(xmltmp)
    root=tree.getroot()
    debate=[]
    date = ""
    member = ""
    member_contribution = ""
    title = ""
    header = ('Date', 'Debate', 'Member', 'Member Contribution')
    os.chdir(outpath)
    csvfile=xmltmp+'.csv'
    test= open(csvfile, 'wb+')
    writer = csv.writer(test)
    writer.writerow(header)
    for node in tree.iter():
      row = date, title, member, member_contribution      
      #print node.tag, node.attrib, node.text
      if node.tag == 'date':
                  date = node.attrib
      if node.tag == 'title':
                  title = node.text.encode('ascii', 'ignore').decode('ascii')
      if node.tag == 'member':
                  member = node.text
      if node.tag == 'membercontribution':
                  member_contribution = node.text.encode('ascii', 'ignore').decode('ascii')
                  print row
                  writer.writerow(row)
    test.close()
    finished = 'Y'  
  except finished == 'N':
    raise RunError('Parser module did not finish')

"def get pdfs"
"def write csv"



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






# Code Scrapyard
################################################################################################################################################	
'''

pp = pprint.PrettyPrinter(indent=4)
	pp_html = pp.pprint(html)
	print pp_html

	filename = 'htmlout.%s.%s.%01d.txt' %(nname,date,i)
	output1 = open(filename, 'wb+')
	print >> output1,test
	output1.close()

#These were useful modules from FDSYS github code
#https://github.com/unitedstates/congress/blob/master/tasks/fdsys.py
def get_package_files(package_name, granule_name, path):
    baseurl = "http://www.gpo.gov/fdsys/pkg/%s" % package_name
    baseurl2 = baseurl

    if not granule_name:
        file_name = package_name
    else:
        file_name = granule_name
        baseurl2 = "http://www.gpo.gov/fdsys/granule/%s/%s" % (package_name, granule_name)

    ret = {
        # map file type names used on the command line to a tuple of the URL path on FDSys and the relative path on disk
        'zip': (baseurl2 + ".zip", path + "/document.zip"),
        'mods': (baseurl2 + "/mods.xml", path + "/mods.xml"),
        'pdf': (baseurl + "/pdf/" + file_name + ".pdf", path + "/document.pdf"),
        'xml': (baseurl + "/xml/" + file_name + ".xml", path + "/document.xml"),
        'text': (baseurl + "/html/" + file_name + ".htm", path + "/document.html"),  # text wrapped in HTML
    }
    if not granule_name:
        # granules don't have PREMIS files?
        ret['premis'] = (baseurl + "/premis.xml", path + "/premis.xml")

    return ret


def unwrap_text_in_html(data):
    text_content = unicode(html.fromstring(data).text_content())
    return text_content.encode("utf8")
'''
