start-servers:
	aws ec2 start-instances --instance-id i-070cfa2385792f874
	aws ec2 start-instances --instance-id i-0d3d5088580ac59e3
	aws ec2 start-instances --instance-id i-0fee66230234e58b7
	aws ec2 start-instances --instance-id i-005824b4e851da3b8

stop-servers:
	aws ec2 stop-instances --instance-id i-070cfa2385792f874
	aws ec2 stop-instances --instance-id i-0d3d5088580ac59e3
	aws ec2 stop-instances --instance-id i-0fee66230234e58b7
	aws ec2 stop-instances --instance-id i-005824b4e851da3b8

tomcat:
	ssh -i /Users/dhanushdinesh/Downloads/DevOpsProjectKey.pem ec2-user@52.90.68.67
# start tomcat /opt/tomcat/bin/startup.sh
# stop tomcat /opt/tomcat/bin/shutdown.sh

jenkins:
	ssh -i /Users/dhanushdinesh/Downloads/DevOpsProjectKey.pem ec2-user@52.55.43.125
# start Jenkins service jenkins start
# stop Jenkins service jenkins stop
# Get passwork cat var/lib/jenkisn/secrets/initialAdminPassword -> 043e9c0354fa4818959763b474fac72d

dockers:
	ssh -i /Users/dhanushdinesh/Downloads/DevOpsProjectKey.pem ec2-user@54.158.221.208
# start docker service docker start 
# stop docker service docker stop

ansible:
	ssh -i /Users/dhanushdinesh/Downloads/DevOpsProjectKey.pem ec2-user@54.224.41.136
# start docker service docker start 
# stop docker service docker stop
# Login to dockehub account 

gitpush:
	git add .
	git commit -m "Added the footer"
	git push origin master

.PHONY: start-servers stop-servers tomcat jenkins dockers ansible