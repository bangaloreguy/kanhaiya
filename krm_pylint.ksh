#!/bin/bash
#script to create output of pylint on all python programs at arg1 in html format.
dir=$1
workspace='/usr/local/jenkins/workspace/krm'
logspace='/usr/local/jenkins/logs/krm'
#BUILD_NUMBER=1 		#comment this line before running from jenkins
#job_name="krm"
job_name=${JOB_NAME}
bld_nbr=${BUILD_NUMBER}
curdate=`date "+%Y-%m-%d"`
newdir="$job_name.$curdate.$bld_nbr"
echo $newdir
oldcwd=`pwd`
#exit 0;
sudo mkdir -p $newdir/pylint $newdir/radon $newdir/flake8
if [ ! -d $newdir/pylint ]
then
	echo "Error!!! $newdir/pylint not created"
fi
sudo chmod 777 $newdir $newdir/pylint $newdir/radon $newdir/flake8
#exit 0;
#file="incall.py"
count=0
for file in `find $dir -not -path '*/\.*' -name "in*.py"`;
do
        echo "File# $count: $file";
        newfile=`echo $file | tr / _ | sed s/\.py/.html/`
        echo "new file:$newfile"
	#pylint run
        #sudo pylint --disable=all $file --output-format=html >> $newdir/pylint/$newfile
	outfile=$newdir/pylint/$newfile
	sh ./pylint.ksh $file $outfile
	echo "pylint completed!"

	#radon run
	echo "<pre>" > $newdir/radon/$newfile
	echo "<p><b><big>Cyclomatic Complexity </p></b></big>" >> $newdir/radon/$newfile
	sudo radon cc $file --total-average -nc >> $newdir/radon/$newfile
	echo "<p><b><big>Raw Metric </p></b></big>" >> $newdir/radon/$newfile
	sudo radon raw $file >> $newdir/radon/$newfile
	echo "radon completed!"

	#flake8 run
	echo "<pre>" > $newdir/flake8/$newfile
	echo "<p><b><big>flake8 output for $newfile </p></b></big>" >> $newdir/flake8/$newfile
	sudo flake8 $file >> $newdir/flake8/$newfile
	echo "flake8 completed!"

        count=`expr $count + 1`;
done

#coverage report
cd $workspace
/usr/local/jenkins/projects/krm_env/bin/coverage run manage.py test ivr --noinput

if [ -f $workspace/.coverage ]
then
	sudo mv $workspace/.coverage $logspace/$newdir
	cd $logspace/$newdir
	/usr/local/jenkins/projects/krm_env/bin/coverage html --omit=/usr/local/jenkins/projects/krm_env/lib/python2.7/site-packages/*
	sudo rm .coverage
	if [ ! -d htmlcov ]
	then
		echo "Error!! failed to generate html coverage report"
	else
		echo "coverage html report successfully created"
	fi
fi
cd $oldcwd
echo "$count files processed"
#exit 0;




