infile=$1
outfile=$2
pylint --rcfile=/usr/local/jenkins/logs/krm/.pylintrc $infile > $outfile
exit 0
