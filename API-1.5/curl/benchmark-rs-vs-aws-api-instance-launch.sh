#!/bin/bash
#
#  Compares the time it takes for a raw instance to be launched when
#  using the RS API vs Cloud API [EC2 and GCE]
#
#  Requires:
#  AWS EC2 CLI Tools [http://docs.aws.amazon.com/AWSEC2/latest/CommandLineReference/ec2-cli-get-set-up.html]
#  RightScale rsc [https://github.com/rightscale/rsc]
#  curl
#
#  Developed and tested on Ubuntu 14.04 [2015-08-20]

# Global Parameters

## AWS Account Credentials
AWS_ACCESS_KEY=${AWS_ACCESS_KEY:='ABC__replace_with_aws_access_key_XYZ'}
AWS_SECRET_KEY=${AWS_SECRET_KEY:='123XYZ__replace_with_aws_secret_key__XXX'}

## RightScale Account Credentials
RS_EMAIL=${rs_email:='your@email.com'}     	# RS User Account
RS_PASSWORD=${rs_pswd:='yourpassword'}      # RS User Password
RS_ACCT=${rs_acct:='12345'}             	# RS Account ID


# Functions
launchInstanceUsingRS(){
	## Execute API Call to authenticate and retrieve session cookie
	curl -s -l -H X_API_VERSION:1.5 -c mycookie \
	-d email="$RS_EMAIL" \
	-d password="$RS_PASSWORD" \
	-d account_href="/api/accounts/$RS_ACCT" \
	-X POST https://my.rightscale.com/api/session
	
		
	## Launch the instance and get the resource_uid
	rs_startTime=`date +%s`
	instance_href="$(curl -s -i -l -H X_API_VERSION:1.5 -b mycookie \
	-d instance[image_href]='/api/clouds/1/images/BT0FJ9DJ8VOJ4' \
	-d instance[ssh_key_href]='/api/clouds/1/ssh_keys/9AQBF50L4A8O5' \
	-d instance[instance_type_href]='/api/clouds/1/instance_types/CQQV62T389R32' \
	-d instance[name]='Test-Raw-Instance_fromRS-API' \
	-X POST https://my.rightscale.com/api/clouds/1/instances | grep "Location: /api/clouds/")"
	instance_href="${instance_href:10}"
	instance_href="$(echo -e "${instance_href}" | tr -d '[[:space:]]')"
	RsInstanceResourceId=`/home/bryankaraffa/Applications/rsc/rsc --x1 .resource_uid cm15 show ${instance_href}`


	## Wait for instance to pass AWS status checks	
	rs_launch_in_progress="true"
	while [ "$rs_launch_in_progress" == "true" ]
	do		
		read -a RSresponseArray <<< $(ec2-describe-instance-status $RsInstanceResourceId)
		
		if [ "${RSresponseArray[5]}" == "ok" ] && [ "${RSresponseArray[6]}" == "ok" ] && [ "${RSresponseArray[10]}" == "passed" ] && [ "${RSresponseArray[13]}" == "passed" ]
		then
			rs_launch_in_progress=false
		fi
	done
		
	rs_endTime=`date +%s`
	rs_launchTime=`expr $rs_endTime - $rs_startTime`
	echo $rs_launchTime > rs_launchTime.txt	
	
	# Clean up the instances to prevent incurring additional costs
	sleep 3
	ec2-terminate-instances $RsInstanceResourceId &> /dev/null
}

launchInstanceUsingEC2(){
	ImageId='ami-ef6cdc84'
	KeyName='bk-test-ssh-key'
	InstanceType='m1.small'

	## Launch the instance and get resource_uid
	ec2_startTime=`date +%s`
	read -a response <<< $(ec2-run-instances -v $ImageId -k $KeyName -t $InstanceType --aws-access-key $AWS_ACCESS_KEY --aws-secret-key $AWS_SECRET_KEY | grep 'INSTANCE')
	Ec2InstanceResourceId=${response[1]}
	
	ec2-create-tags $Ec2InstanceResourceId --tag 'Name=Test-Raw-Instance_fromAWS-API' &> /dev/null
	
	
	## Wait for instance to pass AWS status checks	
	ec2_launch_in_progress="true"
	while [ "$ec2_launch_in_progress" == "true" ]
	do		
		read -a EC2responseArray <<< $(ec2-describe-instance-status $Ec2InstanceResourceId)
		
		if [ "${EC2responseArray[5]}" == "ok" ] && [ "${EC2responseArray[6]}" == "ok" ] && [ "${EC2responseArray[10]}" == "passed" ] && [ "${EC2responseArray[13]}" == "passed" ]
		then
			ec2_launch_in_progress=false
		fi
	done
	
	ec2_endTime=`date +%s`
	ec2_launchTime=`expr $ec2_endTime - $ec2_startTime`
	echo $ec2_launchTime > ec2_launchTime.txt
	
	# Clean up the instances to prevent incurring additional costs
	sleep 3
	ec2-terminate-instances $Ec2InstanceResourceId &> /dev/null
}

#  Begin the Benchmark
clear
launchInstanceUsingEC2 &
launchInstanceUsingRS &
wait
clear
# Print Results
echo ""
echo "----- Results -----"
echo 'EC2 API Launch Time in seconds:'
cat ec2_launchTime.txt
echo 'RS API Launch Time in seconds:'
cat rs_launchTime.txt
echo '----- ------- -----'
echo 'Results appended to benchmarks.log [timestamp ec2_launchTime rs_launchTime]'
echo "$(date +%s) $(cat ec2_launchTime.txt) $(cat rs_launchTime.txt)" >> benchmarks.log
echo 'Done!'
rm ec2_launchTime.txt rs_launchTime.txt