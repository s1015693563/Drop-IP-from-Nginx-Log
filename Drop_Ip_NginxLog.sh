#!/bin/bash
#author=lxh
#description:Drop IP from nginx Log and delete rules after 30 minutes;
#date=2021/7/22/16:56:49

logfile=/usr/local/nginx/log/access.log
d1=`date -d "-1 minute" +%H%M`
d2=`date +%M`
ipt=/sbin/iptables
ips=/tmp/drop_ip.txt

Deny_IP(){
 grep '$d1:' $logfile|awk '{print $1}'|sort -n|uniq -c|sort -n > $ips
 for i in `awk '$1>100 {print $2}' $ips`
 do
    $ipt -I INPUT -p tcp --dport 80 -s $i -j REJECT
    echo "`date +%F-%T` $i" >> /tmp/badip.log
 done
}
Roll_Back(){
 for a in `$ipt -nvL INPUT --line-numbers |grep '0.0.0.0/0'|awk '$2<10 {print $1}'|sort -nr`
 do 
    $ipt -D INPUT $a
 done

 #Clear iptables rules
 $ipt -Z
}

if [ $d2 -eq "00" ] || [ $d2 -eq "30" ];
then
  Roll_Back
  Deny_IP
else
  Deny_IP
fi