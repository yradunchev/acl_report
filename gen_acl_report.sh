#!/bin/bash

# purpose: create ACL report on 1 level depth directories and output to text file report
# usage: ./gen_acl_report.sh start_path report
# the above command will generate a file called "report_20100203_YYYYMMDD_HHMMSS.txt"

# created by: aaron
# created at: 20100203

# debug flag
DEBUG="on"

# debug function
function DEBUG()
{
[ "$DEBUG" == "on" ] && $@ || :
}

# set path to find files
STARTPATH="$1"

# set report output
REPORT="$2_`date +%Y%m_%H%M%S`.txt"

# set temp report file
ACLFILELIST=/tmp/acl_file_list.txt

DEBUG echo "REPORT is = $REPORT"
DEBUG echo "ACLFILELIST is = $ACLFILELIST"
DEBUG echo "STARTPATH is = $STARTPATH"

# build acl list
function reportHeader
{
DEBUG echo "...inside function reportHeader"
echo "ACL REPORT" >> $REPORT
echo "Started on `date`" >> $REPORT
echo "===================================" >> $REPORT
DEBUG echo "...end of function reportHeader"
}

function getACL
{
DEBUG echo "...inside function getACL"
# find all files excluding .svn
#find $STARTPATH -path '*.svn' -prune -o -type f -exec getfacl {} \; > $ACLFILELIST
# find all top level directories
DEBUG echo "executing find $1"
#find $STARTPATH -maxdepth 1 -prune -o -type d -exec getfacl {} \; > $ACLFILELIST
find $STARTPATH ! -path $STARTPATH -maxdepth 1 -type d | xargs getfacl > $ACLFILELIST
DEBUG echo "...end of function getACL"
}

function groupsSummary
{
DEBUG echo "...inside function groupsSummary"
echo "Group Summary:" >> $REPORT
echo "-----------------------------------" >> $REPORT
cat $ACLFILELIST | grep "^group:[a-zA-Z]" | sort | uniq -c >> $REPORT
echo " " >> $REPORT
#echo "Default Group Summary:" >> $REPORT
#echo " " >> $REPORT
#cat $ACLFILELIST | grep "^default:group:[a-zA-Z]" | sort | uniq -c >> $REPORT
#echo " " >> $REPORT
echo "Users for each group:" >> $REPORT
echo "-----------------------------------" >> $REPORT
for a in `cat $ACLFILELIST | grep "^group:[a-zA-Z]" | sort | awk -F: '{print $2}' | uniq`
do
echo $a >> $REPORT
for g in `cat /etc/group | grep $a`
do
echo $g | awk -F: '{print "\t"$4}' >> $REPORT
done
done
#echo "Users for each default group:" >> $REPORT
#echo "-----------------------------------" >> $REPORT
#for a in `cat $ACLFILELIST | grep "^default:group:[a-zA-Z]" | sort | awk -F: '{print $3}' | uniq`
#do
#echo $a >> $REPORT
#for g in `cat /etc/group | grep $a`
#do
#echo $g | awk -F: '{print "\t"$4}' >> $REPORT
#done
#done
echo "===================================" >> $REPORT
DEBUG echo "...end of function groupsSummary"
}

function usersSummary
{
DEBUG echo "...inside function usersSummary"
echo "User Summary:" >> $REPORT
echo " " >> $REPORT
cat $ACLFILELIST | grep "^user:" | sort | uniq -c >> $REPORT
echo " " >> $REPORT
echo "Default User Summary:" >> $REPORT
echo " " >> $REPORT
cat $ACLFILELIST | grep "^default:user:" | sort | uniq -c >> $REPORT
echo "===================================" >> $REPORT
DEBUG echo "...end of function usersSummary"
}

function maskSummary
{
DEBUG echo "...inside function maskSummary"
echo "Mask Summary:" >> $REPORT
echo " " >> $REPORT
cat $ACLFILELIST | grep "^mask:" | sort | uniq -c >> $REPORT
echo " " >> $REPORT
echo "Default Mask Summary:" >> $REPORT
echo " " >> $REPORT
cat $ACLFILELIST | grep "^default:mask:" | sort | uniq -c >> $REPORT
echo "===================================" >> $REPORT
DEBUG echo "...end of function maskSummary"
}

function findGroups
{
DEBUG echo "...finding list of groups"
cat $ACLFILELIST | grep group:
}

function otherSummary
{
DEBUG echo "...inside function otherSummary"
echo "Other Summary:" >> $REPORT
echo " " >> $REPORT
cat $ACLFILELIST | grep "^other:" | sort | uniq -c >> $REPORT
echo " " >> $REPORT
echo "Default Other Summary:" >> $REPORT
echo " " >> $REPORT
cat $ACLFILELIST | grep "^default:other:" | sort | uniq -c >> $REPORT
echo " " >> $REPORT
echo "===================================" >> $REPORT
DEBUG echo "...end of function otherSummary"
}

function listofFiles
{
DEBUG echo "...list of directories"
echo "List of directories" >> $REPORT
cat $ACLFILELIST | grep "# file: " >> $REPORT
echo "===================================" >> $REPORT
DEBUG echo "...end of list of directories"
}

function appendACL
{
DEBUG echo "...appending acl contents"
echo "ACL list of directories" >> $REPORT
echo " " >> $REPORT
cat $ACLFILELIST >> $REPORT
echo "===================================" >> $REPORT
DEBUG echo "...end of acl contents appending"
}

function removeACL
{
DEBUG echo "...removing temp files for ACL"
rm $ACLFILELIST
DEBUG echo "...removing temp files for ACL done"
}

reportHeader
getACL
groupsSummary
#usersSummary
#maskSummary
#otherSummary
listofFiles
appendACL
findGroups

removeACL