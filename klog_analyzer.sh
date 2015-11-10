#!/bin/bash  
set -x
echo "Knowlus Log analyzer tool"
echo "-------------------------"

#Log Analyzser tool to send logs with matching pattern to sender(s).

curdate=`date "+%Y-%m-%d"` 
echo "curdate=$curdate"

#max line length of the logs generated. Required in order to not flood the sender's mail with large line log. 
line_len=140
#sender's mail ids
senders_mailid="kanhaiya.baranwal@knowlarity.com amith.t@knowlarity.com narendra.choubey@knowlarity.com"
#senders_mailid="narendra.choubey@knowlarity.com"
fs_pattern="ERR"
knowlus_pattern="ERROR"
ivr_pattern="ERROR"

freeswitch_log="/usr/local/freeswitch/log/freeswitch.log"
conserver_log="/var/log/knowlus/conserver/ConServer_*.log"
new_preprocessd_log="/var/log/knowlus/new_preprocessd_*.log"
postprocessd_log="/var/log/knowlus/postprocessd_*.log"
#twisted_reactord_log="/var/log/knowlus/twisted_reactord_*.log"
krpycd_log="/var/log/knowlus/krpycd_*.log"
#krpycd_incalld_log="/var/log/knowlus/krpycd_incalld_*.log"
#reactord_log="/var/log/knowlus/reactord_*.log"
incalld_log="/var/log/knowlus/incalld_*.log"
outcalld_log="/var/log/knowlus/outcalld_*.log"
krm_message_managerd_log="/var/log/knowlus/krm_message_managerd_*.log"
ivr_incall_log="/var/log/knowlus/ivr/incall_*.log"
ivr_outcall_log="/var/log/knowlus/ivr/outcall_*.log"
ivr_preprocess_log="/var/log/knowlus/ivr/preprocess_*.log"
logs="$freeswitch_log $krpycd_log $ivr_incall_log"
#logs="$freeswitch_log $conserver_log $new_preprocessd_log $postprocessd_log $krpycd_log $reactord_log $incalld_log $outcalld_log $krm_message_managerd_log $ivr_incall_log $ivr_outcall_log $ivr_preprocess_log"
#grep freeswitch.log in last_log.info
log_analyzer_info="/home/kanhaiya/last_log.info"

#temporary files
extract="/tmp/log.$USER.extract"
mail_log="/tmp/mail.$USER.log"
log_analyzer_info_tmp="/tmp/last_log.info.tmp"

if [ -f $extract ]
then
	rm -f $extract $mail_log $log_analyzer_info_tmp
fi
touch $log_analyzer_info_tmp
touch $mail_log
touch $extract

if [ ! -f $extract ]
then
	echo "Failed to create extract file $extract."
	echo "Permission issue; Contact System Administrator"
	exit -1
fi
echo "freeswitch_log=$freeswitch_log"

for logfile in $logs
do
	if [ ! -f $logfile ]
	then
		continue;
	fi
	echo "current logfile is $logfile"
	file=`basename $logfile`
	begline=1
	grep -q "^$file" $log_analyzer_info
	if [ $? -eq 0 ]
	then
		begline=`grep "^$file" $log_analyzer_info | cut -d= -f2`
	fi
	endline=`wc -l $logfile| cut -d" " -f1`
	if [ $begline -ge $endline ]
	then
		continue;
	fi
	echo "begline=$begline ; endline=$endline"
	#sed -n ${begline},${endline}p $logfile > $extract
	cat -n $logfile | sed -n ${begline},${endline}p > $extract
	#sed -n '1,50{=;p;}' klog_analyzer.sh | sed '{N;s/\n/ /}'
	#sed -n '${begline},${endline}{=;p;}' klog_analyzer.sh | sed '{N;s/\n/ /}'

	#handle case for each type of logs
	case $file in
	freeswitch*.log)
		grep -q $fs_pattern $extract
		if [ $? -eq 0 ]
		then
			echo "\n******Log File:$file******\n" >> $mail_log
			grep -i $fs_pattern  $extract | sort -u -k4,4 >> $mail_log
		fi
		;;
	postprocessd*log | krpycd*log | outcalld*log | incalld*log | new_preprocessd*log | krm_message_managerd*log)
		grep -q $knowlus_pattern $extract
		if [ $? -eq 0 ]
		then
			echo "\n******Log File:$file******\n" >> $mail_log
			echo "extract file=$extract"
			#grep -i $knowlus_pattern  $extract | grep -v "errorno | error node no" | grep -v "<.*>" | grep -v "error.mp3" | sort -u -k4,6 | cut -c -$line_len >> $mail_log
			grep -i $knowlus_pattern  $extract | grep -v "errorno\|error node no\|<.*>\|error.mp3" | sort -u -k4,6 | cut -c -$line_len >> $mail_log
		fi
		;;
	reactord*.log)
		echo "\n******Log File:$file******\n" >> $mail_log
		cat $extract | sort -u -k3,3 | cut -c -$line_len >> $mail_log
		;;
	#ivr logs
	incall_*log | outcall_*log | preprocess_*log )
		grep -q $ivr_pattern $extract
		if [ $? -eq 0 ]
		then
		echo "\n******Log File:$file******\n" >> $mail_log
		echo "extract file=$extract"
			#grep -i $ivr_pattern  $extract | grep -v errorno | grep -v "error node no" | grep -v "<.*>" | grep -v "error.mp3" | sort -u -k4,6 | cut -c -$line_len >> $mail_log
			grep -i $ivr_pattern  $extract | grep -v "errorno\|error node no\|<.*>\|error.mp3" | sort -u -k4,6 | cut -c -$line_len >> $mail_log
		fi
		;;
	esac
	echo "$file=$endline" >> $log_analyzer_info_tmp
done
if [ -s $mail_log ]
then
	#cat $mail_log | mailx -s "Error in knowlus logs: host `uname -n`; Analysis date:`date`" kanhaiya.baranwal@knowlarity.com
	cat $mail_log | mailx -s "Error in knowlus logs: host `uname -n`; Analysis date:`date`" $senders_mailid
	mv $log_analyzer_info_tmp $log_analyzer_info
else
	rm -f $log_analyzer_info_tmp
fi
