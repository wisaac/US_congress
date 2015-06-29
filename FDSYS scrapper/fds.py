####################################################
### FD SYS Scrapping Project | June 29th, 2015 	 ###
####################################################





##########################
#Section 1: Module Import#
##########################

import mechanize, sys, spynner, time, os, pyquery,random, django
from time import sleep
from StringIO import StringIO
import urllib, urllib2, urlparse
from urllib2 import urlopen, URLError, HTTPError
from BeautifulSoup import BeautifulSoup
import zipfile
import re
import pprint
import shutil

###################################################
#Section 2: Creating Directory to Place Zip Files #
###################################################

new_path = "/Volumes/Gdrive Backup Mac Pro 2 /hansardfiles/"
new_path_1 = os.path.expanduser(new_path)+'zip_files'

#setting date and time
nname = time.strftime("%b")
date = time.strftime("%d")
ver = random.randrange(0, 999, 2)

####################################				
# Section 3: Gather Core file links#
####################################

def grab_links():
	""" This is used to get the source links for each hearing """
	#browser from mechanize
	br=mechanize.Browser()
	br.addheaders = [('User-agent', 'Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.9.0.1) Gecko/2008071615 Fedora/3.0.1-1.fc9 Firefox/3.0.1')]
	br.set_handle_robots(False)
	src_links=[]
	hr_links=[]
	#Instead a single link, we can simply create an array of the links in the archive
	for i in range(0:467):
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
	br=mechanize.Browser()
	br.addheaders = [('User-agent', 'Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.9.0.1) Gecko/2008071615 Fedora/3.0.1-1.fc9 Firefox/3.0.1')]
	br.set_handle_robots(False)
	for link in hr_links:




'''
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
