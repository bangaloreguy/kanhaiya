#!/bin/bash -x
set -x
echo "Knowlus Log analyzer tool"
echo "-------------------------"

curdate=`date "+%Y-%m-%d"`
echo "curdate=$curdate"

freeswitch_log="/usr/local/freeswitch/log/freeswitch.log"
postprocessd_log="/var/log/knowlus/postprocessd_*.log"
twisted_reactord_log="/var/log/knowlus/twisted_reactord_*.log"
krpycd_log="/var/log/knowlus/krpycd_*.log"
krpycd_incalld_log="/var/log/knowlus/krpycd_incalld_*.log"
reactord_log="/var/log/knowlus/reactord_*.log"
incalld_log="/var/log/knowlus/incalld_*.log"
outcalld_log="/var/log/knowlus/outcalld_*.log"
krm_message_managerd_log="/var/log/knowlus/krm_message_managerd_*.log"
ivr_incall_log="/var/log/knowlus/ivr/incall_*.log"
#grep freeswitch.log in last_log.info
log_analyzer_info="/home/kadmin/last_log.info"
log_analyzer_info_tmp="/home/kadmin/last_log.info.tmp"
extract="/tmp/log.extract"

touch $log_analyzer_info_tmp
echo "freeswitch_log=$freeswitch_log"

#begline=`grep freeswitch_log $log_analyzer_info | cut -d= -f2`
#endline=`wc -l $freeswitch_log`
#sed -n ${begline},${endline}p $freeswitch_log > $fs_extract
#grep "[NOTICE]" $gs_extract

#exit 0
#for logfile in "$postprocessd_log $twisted_reactord_log $krpycd_log $krpycd_incalld_log $reactord_log $incalld_log $outcalld_log $krm_message_managerd_log $ivr_incall_log"
for logfile in "$freeswitch_log"
do
	file=`basename $logfile`
	begline=1
	grep -q $file $log_analyzer_info
	if [ $? -eq 0 ]
	then
		begline=`grep $file $log_analyzer_info | cut -d= -f2`
	fi
	endline=`wc -l $logfile| cut -d" " -f1`
	echo "begline=$begline; endline=$endline"
	sed -n ${begline},${endline}p $logfile > $extract
	grep -q ERR $extract
	if [ $? -eq 0 ]
	then
		grep ERR  $extract | sort -u -k4,4 | mailx -s "Error in $file, host `uname -n`; Analysis date:`date`" kanhaiya.baranwal@knowlarity.com
	fi
	echo "$file=$endline" >> $log_analyzer_info_tmp
	echo "$file=$endline"
	printf "%s\n" ${file}
done
mv $log_analyzer_info_tmp $log_analyzer_info
