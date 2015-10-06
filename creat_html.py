# create index.html for static code analysis output
import datetime
import glob
import os,sys


html_dir="/kanalysis"
now = datetime.datetime.today()
curdate="%4d-%02d-%02d" % ( now.year,now.month,now.day)
bld_nbr=os.environ.get('BUILD_NUMBER')
job=os.environ.get('JOB_NAME')
#bld_nbr="1"
#job="krm"
#curdate="09-28-2015"
oldcwd=os.getcwd()
print "oldcwd=%s" %(oldcwd)
list=""
newdir="%s.%s.%s" % (job,curdate,bld_nbr)
print "newdir=%s" % (newdir)
os.chdir(newdir)
cwd=os.getcwd()
#print "cwd=%s" %(cwd)
print "Showing files in %s" %(cwd)
globallist=""
for dir in os.listdir(cwd): 
    if os.path.isfile(dir):
	continue
    if dir <> 'htmlcov':
        os.chdir(dir)
        localdir=os.getcwd()
        print "localdir is %s" % (localdir)
        list=""
        for file in os.listdir(localdir):
    	    if str(file).endswith('.html'):
    		print "subdir is %s and file is %s" % (dir,file)
            	#print os.path.join(subdir, file)
    		#temp="""<li><a href="%s/%s">%s/%s/%s/%s</a></li><br />\n""" % (localdir,file,html_dir,newdir,dir,file)
    		temp="""<li><a href="%s/%s/%s/%s">%s</a></li>\n""" % (html_dir,newdir,dir,file,file)
    		list=list+temp
        	#print "list =%s" % (list)
    
        message = """<html>
<head></head>
<body><p>List of files generated from %s!</p></body>
%s
</html>
"""
        indexfile="index.html" 
        f = open(indexfile,'w')
        msg=message % (dir,list)
        f.write(msg)
        os.chdir(cwd)
        f.close()

    #append index file from this dir to global index file
    temp="""<li><a href="%s/%s/%s/%s">%s/%s</a></li><br />\n""" % (html_dir,newdir,dir,indexfile,dir,indexfile)
    globallist=globallist+temp

#add coverage index file to global list: manual since coverage index file is already created by the tool
#temp="""<li><a href="%s/%s/%s/%s">%s/%s</a></li><br />\n""" % (html_dir,newdir,dir,indexfile,dir,indexfile)
#globallist=globallist+temp

#create global index file in job directory for this build
indexfile="index.html"
gf=open(indexfile,'w')
message="""<htm>
<head></head>
<body><p>Knowlus Code Static Analysis generated on %s, project=%s, bld_nbr=%s!</p></body>
%s
</html>
"""

global_msg=message %(curdate,job,bld_nbr,globallist)
gf.write(global_msg)
gf.close()


sys.exit()
