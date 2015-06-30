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
new_path_1 = os.path.expanduser(new_path)+'/output'
os.chdir(new_path_1)
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
	
	# for tag in tags:
	#  	if ".pdf" in tag['href']:
	#  		pdf_link = str(tag['href'])
	#  		print "This is the PDF link:" + pdf_link
	#pprint(soup.select("td > a")) # all a tag that inside p
	#soup.select('a[href="http://www.gpo.gov:"]')
	#print "This is the PDF link:" + str(pdf_link)
	pdf_link = soup.findAll(href=re.compile(".pdf"), limit = 1)
	print "This is the Text link:"

	links = soup.findAll('td')
	# [(l, l.parent.get('id')) for l in links]
	tags = soup.findAll('a',href=True)
	for tag in tags:
	 	if "Text" in tag.contents:
	 		text_link = str(tag['href'])
	 		print "This is the Text link:" + text_link


	
	#paraText = soup.findAll(text='Text')
	#test = soup.findAll("td", { "class" : "page-details-budget-download-files-left-td" })
	#print str(paraText)
	#Now looking for the raw text
	# tags_td = soup.td
	# for tag in tags_td:
	# 	print "Tag: " + str(tag.string)
	# 	print "Tag Content: " + str(tag)
	
	#test = soup.select('table td tr')
	#soup.find("b", { "class" : "two-col-layout-table" })
	# test_1 = soup.find("h3", { "class" : "page-title" })
	# test_2 = soup.findAll("td", { "class" : "page-details-budget-download-files-left-td" })
	# print test_1
	# print test_2
	

	return soup

	#This can be used to extract raw text in a single line "bs4.BeautifulSoup(urllib.urlopen('http://google.com/?hl=en').read()).select('#footer a')"


"def get pdfs"
"def write csv"



####################################				
# Section 4: Running Functions 	   #
####################################
hr_links = grab_links()
y=len(hr_links)

print hr_links
print y

for i in range(y):
	print "Working on link" + str(i)
	#We need to write something here that will collect the output from grab_meta into an arrary.  
	test = grab_meta(hr_links[i])





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
