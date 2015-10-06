echo "This is build# ${BUILD_NUMBER}"
echo "Jobname is: ${JOB_NAME}"
#bash /usr/local/jenkins/files/check_config.sh --project krm
#cd /usr/local/jenkins/workspace/krm
echo "user is `whoami`"
git checkout master
git fetch

source_dir="/usr/local/jenkins/workspace/krm"
#source_dir="/srv/newknowlus-2.3.0/2.3.0/knowlus/knowlarity/call/tasks"
cd /usr/local/jenkins/logs/krm
sh krm_pylint.ksh $source_dir
python creat_html.py

python /usr/local/jenkins/files/upload-test-result-to-s3_kan.py --project-name krm --to-email "saurabh.prasad@knowlarity.com,rupesh.gopal@knowlarity.com" --cc-email "kanhaiya.baranwal@knowlarity.com"
