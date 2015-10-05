#!/bin/bash
#script to create output of pylint on all python programs at arg1 in html format.
dir=$1
job_name=${JOB_NAME}
job_name="krm"
BUILD_NUMBER=1 		#comment this line before running from jenkins
bld_nbr=${BUILD_NUMBER}
curdate=`date "+%Y-%m-%d"`
newdir="$job_name.$curdate.$bld_nbr"
echo $newdir
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
	echo "Cyclomatic Complexity <br />" >> $newdir/radon/$newfile
	sudo radon cc $file -a -nc >> $newdir/radon/$newfile
	echo "Raw Metric <br />" >> $newdir/radon/$newfile
	sudo radon raw $file >> $newdir/radon/$newfile
	echo "radon completed!"

	#flake8 run
	echo "<pre>" > $newdir/flake8/$newfile
	sudo flake8 $file >> $newdir/flake8/$newfile
	echo "flake8 completed!"

        count=`expr $count + 1`;
done
echo "$count files processed"
exit 0;


echo "This is build# ${BUILD_NUMBER}"
#bash /usr/local/jenkins/files/check_config.sh --project krm
cd /usr/local/jenkins/projects/krm
#git pull
cd /usr/local/jenkins/logs/krm
#list all regular python files and create pylint output in current directory
for file in `find /srv/krm/ -not -path '*/\.*' -name "*.py"`    
do
        echo "File# $count: $file";
        newfile=`echo $file | tr / _ | sed s/\.py/.html/`
        echo "new file:$newfile"
        sudo pylint --disable=all $file --output-format=html > $newfile
        count=`expr $count + 1`;
done
python creat_html.py
python /usr/local/jenkins/files/upload-test-result-to-s3_kan.py --project-name krm --to-email "saurabh.prasad@knowlarity.com,munai.udasin@knowlarity.com" --cc-email "kanhaiya.baranwal@knowlarity.com"




