#Variable
my_cert="<path to file>"
my_key="<path to file>"

#Runing in same instance for Backup, else add instance_id and region value
instance_id=`curl http://169.254.169.254/latest/dynamic/instance-identity/document|grep instanceId|awk -F\" '{print $4}'`
my_region=`curl http://169.254.169.254/latest/dynamic/instance-identity/document|grep region|awk -F\" '{print $4}'`

#Number backup month and week
month_backup=4
week_backup=4

echo "Backup process starting... "
echo "Checking Volume ..."

# Volume info
ec2-describe-volumes -C $my_cert -K $my_key --region $my_region  --filter "attachment.instance-id=$instance_id" | grep VOLUME | awk '{print $2}' > /tmp/volume.txt 2>&1


# Backup start
for volume in $( cat /tmp/volume.txt )
do
echo "Backup for Volume - $volume"
 #Monthly BackUp on Every month 15th day
 day=`date +%d`
 if [ $day -eq 15 ]
   then
    echo "Monthly Backup `date +%B-%Y` start"
    ec2-create-snapshot $volume -K $my_key  -C $my_cert --region $my_region --description "$volume-Monthly-Backup-`date +%B-%Y`"
    old_backup=`date +%B-%Y --date  $month_backup'+ months ago'`
    ec2-describe-snapshots -C $my_cert -K $my_key --region $my_region -F "volume-id=$volume" -F "description=$volume-Monthly-Backup-$old_backup" | grep SNAPSHOT | awk '{print $2}' >> /tmp/snap_info.txt 2>&1
    echo "End Monthly Backup"
 fi

 #Weekly Backup on sunday(7)
 dayinweek=`date +%u`
 if [ $dayinweek -eq 7 ]
 then
  echo "Weekly Backup `date +%U-%Y` start"
   ec2-describe-snapshots -C $my_cert -K $my_key --region $my_region -F "volume-id=$volume" -F "description=$volume-Daliy-Backup-`date +%x --date='7 days ago'`" | grep SNAPSHOT | awk '{print $2}' >> /tmp/daliy_info.txt 2>&1

  for snapshot in $(cat /tmp/daliy_info.txt)
   do
     ec2-copy-snapshot -C $my_cert -K $my_key --region $my_region -r $my_region -s $snapshot -d "$volume-Weekly-Backup-`date +%U-%Y`"
     old_week_backup=`date +%U-%Y --date  $week_backup'+ weeks ago'`
     ec2-describe-snapshots -C $my_cert -K $my_key --region $my_region -F "volume-id=$volume" -F "description=$volume-Weekly-Backup-$old_week_backup" | grep SNAPSHOT | awk '{print $2}' >> /tmp/snap_info.txt 2>&1
  done
  echo "End Weekly Backup"
 fi

  #Daliy Backup
  echo "Daily Backup start"
  ec2-describe-snapshots -C $my_cert -K $my_key --region $my_region -F "volume-id=$volume" -F "description=$volume-Daliy-Backup-`date +%x --date='7 days ago'`" | grep SNAPSHOT | awk '{print $2}' >> /tmp/snap_info.txt 2>&1
  ec2-create-snapshot $volume -K $my_key  -C $my_cert --region $my_region --description "$volume-Daliy-Backup-`date +%x`"
  echo "End of Backup Volume - $volume"
  
done
#Backup End

echo "Delete process starting"
#Delete old Snapshot base on above
for snapshot in $(cat /tmp/snap_info.txt)
do
 echo "Delete Snapshot - $snapshot"
  ec2-delete-snapshot -C $my_cert -K $my_key --region $my_region $snapshot
done
echo "End of delete snapshot"

#Ref
mkdir -p ~/ebs/`date +%F`/ ;
mv /tmp/snap_info.txt   ~/ebs/`date +%F`/
