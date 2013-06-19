ebs_snapshot
============

Backup for Amazon EBS volume - http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/SettingUp_CommandLine.html

This script is developed based on ec2-api-tool-1.6.7.3 http://aws.amazon.com/developertools/351

you can modify based on your needs. check doc from Amazon - http://docs.aws.amazon.com/AWSEC2/latest/CommandLineReference/command-reference.html



1).Install java

2). Download ec2-api-tool - http://aws.amazon.com/developertools/351 , setup api-tool - http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/SettingUp_CommandLine.html

3) Create X.509 certificates from AWS Security Credentials, copy to certificates development server. 

4) Download script file(ebs_backup.sh) to development server home folder

5) add crontab job on development server - 00 6 * * * sh <path to script file>
