#!/bin/bash

echo "check install package hddtemp"
epm assure hddtemp
echo "start service hddtemp and add autoload"
serv hddtemp on
echo "create conf file in /etc/zabbix/zabbix_agentd.conf.d"
touch /etc/zabbix/zabbix_agentd.conf.d/additional.conf
echo "add parameters in zabbix agent configuration"
disks=$(nc localhost 7634 |sed 's/|//m' | sed 's/||/ \n/g' | awk -F'|' '{print  $1}')
for i in $disks
do
  echo -e "UserParameter=$i[*],bash /usr/local/sbin/for_zabbix.sh $i" >> /etc/zabbix/zabbix_agentd.conf.d/additional.conf
done
cput=$(sensors| cut -d"(" -f1 | grep °C | awk '{print NR "" $0 }' | cut -d":" -f1 | tr -d ' ' |  cut -c 2-)
for i in $cput
do
  echo -e "UserParameter=$i[*],bash /usr/local/sbin/for_zabbix.sh $i" >> /etc/zabbix/zabbix_agentd.conf.d/additional.conf
done
host=`hostname -s`
sed -i -e 's/Hostname=.*/Hostname='"$host"'/' -e 's/Server=.*/(IP server)/' -e '/ServerActive=.*/s/^/#/' -e 's/^# HostMetadata=.*/HostMetadata=(key)' -e 's/^# UnsafeUserParameters=.*/UnsafeUserParameters=1/' /etc/zabbix/zabbix_agentd.conf
echo "restart zabbix agent"
serv zabbix_agentd.service restart
echo "done"
