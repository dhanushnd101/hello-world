# CI/CD DevOps Project  

[![Image](/img/docker-project-flowchart.jpg "DevOps Project - CI/CD with Jenkins Ansible Docker Kubernetes ")](https://youtu.be/vmR2Q-fs4z0?si=KKhcAmvLBiFDvo4Z)

This project has two parts, the first part is to create a continuous integration (CI) of code using GitHub and create a job in Jenkins to build the code using Maven and store the antifactory in the sever. Second part is to create a continuous delivery (CD) of code using Ansible for server management, build a docker image using the artifact, push the docker image to the Docker Hub and deploy the code on Kubernetes cluster. 

## Parts

### Pre-Rec
- Have AWS account: [AWS: Account - Dhanush](https://us-east-1.console.aws.amazon.com/ec2/home?region=us-east-1#InstanceDetails:instanceId=i-0d3d5088580ac59e3)
- Fork GitHub project: [GiitHub: Code - Dhanush](https://github.com/dhanushnd101/hello-world.gitDevOps)

### Part 1: Install Jenkins server

1. Launch a free tear instance
- attach a SG
- add port 8080 to access the application over internet
- keep the .pem file

2. Install Jenkins in server [Download Jenkins](https://www.jenkins.io/download/)

- download the applicaiton in the server 
    ```
    sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
    sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
    ```
- install java and jenkins 
    ```
    yum install fontconfig java-11-openjdk
    yum install jenkins
    ```
    
- Install git
    ```
    yum install git
    ```

- Start Jenkins
    ```
	service jenkins start 
    ```

3. Using the public IP(xx.xx.xx.xx:port#) open jenkins 

4. Install plugins

- Manage jenkins -> manage plugins -> Available plugins
-> github 
- Manage Jenkins -> Tools
    - git 
        - path of the git executable -> git or git the path in the server 

5. Create a job with the code from github

### Part 2: Setup Maven

6. Install maven for build

- Go to [Download maven](https://maven.apache.org/download.cgi)
	copy the link address of the binary tar.gz [apache-maven-3.9.4-bin.tar.gz](https://dlcdn.apache.org/maven/maven-3/3.9.4/binaries/apache-maven-3.9.4-bin.tar.gz)
	
    ```
    cd /opt 
	wget https://dlcdn.apache.org/maven/maven-3/3.9.4/binaries/apache-maven-3.9.4-bin.tar.gz
	
    #unzip and install
	tar -xvzf apache-maven-3.9.4-bin.tar.gz 

	#rename the folder
	mv apache-maven-3.9.4 maven
	
    #update the PATH env
    cd to .bash_profile
    cd ~

    #Update the $PATH
    vi .bsh_profile
    ```

    #User specific environment and startup programs
    PATH=$PATH:$HOME/bin:$JAVA_HOME:$M2_HOME:$M2
    
    ```
    #read the file or relogin:
    source .bash_profile

    #check if the $PATH is updated 
    echo $PATH
    ```

- Install plugins
	- Manage jenkins -> manage plugins -> Available plugins
	-> maven integration 
    - Manage Jenkins -> Tools
    - add Java (Uncheck install automatically)
        - path /usr/lib/jvm/java-11-openjdk-11.0.20.0.8-1.amzn2.0.1.x86_64
    - add maven (Uncheck install automatically)
        - path /opt/maven

- Maven jenkins job
    - new item ->
	sellect a maven project ->
	sellect a git repo ->
	sellect a maven goal "clean install"

### Part 3: Set up tomcat server

7. Setup a linux ec2 instance
	- select amazon linux 2
	- create a SG - add port 8080
	- use the same keypair

- Install Java
    ```
	ssh -i DevOpsProjectKey.pem ec2-user@54.198.26.210 
	sudo su -
	amazon-linux-extras install java-openjdk11
    ```

- Configure Tomcat
    ```
	cd /opt
	wget https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.79/bin/apache-tomcat-9.0.79.tar.gz
	tar -xvzf apache-tomcat-9.0.79.tar.gz
	mv apache-tomcat-9.0.79/ tomcat
	cd /opt/tomcat
	find / -name context.xml
		vi /opt/tomcat/webapps/host-manager/META-INF/context.xml (comment the remoteaddrvalve <!-- ... -->)
	comment out the remotaddrvalve
		vi /opt/tomcat/webapps/manager/META-INF/context.xml
	/opt/tomcat/bin/shutdown.sh 
	/opt/tomcat/bin/startup.sh 
    ```

- Start Tomcat 
    ```
	/opt/tomcat/bin/startup.sh 
    ```

- Access web UI on port 8080

8. Add the user credentials in conf/tomcat-users.xml
    ```
	 <role rolename="manager-gui"/>
	 <role rolename="manager-script"/>
	 <role rolename="manager-jmx"/>
	 <role rolename="manager-status"/>
	 <user username="admin" password="admin" roles="manager-gui, manager-script, manager-jmx, manager-status"/>
	 <user username="deployer" password="deployer" roles="manager-script"/>
	 <user username="tomcat" password="s3cret" roles="manager-gui"/>
     ```

### Part 4: Integrate tomcat with jenkins

9. Install "Deploy to container" plugin
10. Add cred
- Manage Jenkins -> credentials -> system -> GLobal cred -> add cred (deployer)

11. Create a new job for deploying the application on tomcat 
- maven project
- git 
- build pom.xml
    - clean install for goals 
- post build action (select deploy war/ear to a container)
    - WAR file path -> **/*.war
    - Container 8.x.x
    - Cred 
    - url http://54.209.127.2:8080/

### Part 5: Set up Docker host

12. Setup a Linux EC2 
    - Amzaon Linux 2 AMI
    - t2.micro
    - docker-host
    - sg - docker-sg
    - same key-pair

13. Install Docker 
    - Login to the server
    - sudo su -
    - yum install docker -y

14. Start docker services
    - Service docker start 

16. Run tomcat container in the docker 
    ```
	docker pull tomcat
	docker run -d --name tomcat-i -p 8081:8080 tomcat
	docker exec -it tomcat-i /bin/bash
    ```
- Add the rule to open all the ports between 8080-9000 
- Add the following to your docker file to make yum work 
	
    ```
	RUN cd /etc/yum.repos.d/		
	RUN sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-*
	RUN sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*
    ```

- Custome docker image for tomcat 
    ```
	FROM tomcat
	RUN cp -R /usr/local/tomcat/webapps.dist/* /usr/local/tomcat/webapps
	```

17. Configure Jenkins to access docker

- create a user 
    - useraddd dockeradmin
    - passwd dockeradmin 
        - dockeradmin
    - id dockeradmin
    - usermod -aG docker dockeradmin
- update the sshd config file 
    - vi /etc/ssh/sshd_config
        - PasswordAuthentication yes
    - service sshd reload
    - ssh-keygen

- Install "Publish over SSH" plugin in Jenkins
    - manage jenkins -> system 
- add SSH Server
    - Hostname
    - username 
    - advance 
        - user password based auth

18. New job for deploying on Docker
- copy the previous job
- remove the post build step 
- add ( deploy over ssh)
    - give the working dir webapp/target/*.war
    - remove dir webapp/target
    - remote dir //opt//docker (Make the dockeradmin owner of /opt/docker)

19. Update image to deploy to automate deployment 
- Give the dockeradmin the owner access to docker 
    - chown -R dockeradmin:dockeradmin docker
- move the old dockerfile to the docker folder
- rm Edit the dockerfile to pick the .war file 

20. Automatic build,delpoymet on docker conatainer
    ```
    cd /opt/docker;
    docker stop tomcat-app;
    docker rm tomcat-app;
    docker rmi custom-tomcat-app:v1;
    docker build -t custom-tomcat-app:v1 .;
    docker run -d --name tomcat-app -p 8084:8080 custom-tomcat-app:v1;
    ```

### Part 6: Inregrating Ansible in CI/CD pipeline

21. Setup EC2 instance for Ansible 
- same as before
- SG need to have port 22 opened

22. Create ansadmin user and add to sudoers file
- Create user
    - useraddd ansadmin
    - passwd ansadmin -> ansadmin
    - visudo 
        - add ==> ansadmin ALL=(ALL) NOPASSWD: ALL
    - update the sshd config file 
        - vi /etc/ssh/sshd_config
            - PasswordAuthentication yes
        - service sshd reload
        - ssh-keygen

23. Generate SSH key 
- login to the ansadmin 
	- ssh-keygen (path= /home/ansadmin/.ssh/id_rsa)

34. Install ansible 
    ```
    sudo amazon-linux-extras install ansible2
    ```

35. Integrate dockerhost with ansible 

- On Docker 
    * Create ansadmin user
    * add ansadmin to sudoers file
    * Enable password based login

- on Ansibl node
    * add docker private ip to hosts file 
        - vi /etc/ansibl/hosts
    * Copy ssh Keys
        - ssh-copy-id <private-ip-docker>
    * Test the connection 
        - ansible all -m ping

36. Integrate ansible with Jenkins
- On Jenkins
    * add the ansible to the ansbile cred 
        - manage jenkins -> system 
        - add SSH Server
            - Hostname
            - username 
            - advance 
                - user password based auth
    * create a new job
- On Ansible 
    * add the docker folder ->  /opt/docker
    * add the ansadmin as owner -> chown -R 

37. Build a image on Ansible server
- Install docker -> sudo yum install docker
- start docker -> sudo service docker start 
- grand permission -> sudo chmod 777 /var/run/docker.sock 
- add the ansadmin to the docker group -> sudo usermod -aG docker ansadmin
- copy the Dockerfile 
- build and deploy 

38. Ansible playbook to creat images push the image to docker hub
- add the privat ip of ansible to hosts file /etc/ansible/hosts
- Share the ssh key of ansible server to ansible server
- Check if the connect is working
- login to dockerhub 
- Write a playbook to build a image
- Check if the playbook is correct 

39. update the Jenkins to trigger the ansible script 
- updated the exec -> ansible-playbook /opt/docker/regapp.yml 

40. Write another playbook to deploy on the docker server
- stop the old container
- remove the old container
- remove the old image 
- Deploy the new image in dockerhub on the docker server

### Part 6: Kubernetes on AWS

41. Set up Kubernetes server
- Launch a server 
- Install the latest AWS CLI 2.3
- Install the kubectl 1.21
    - Add exec permission to the file kunectl -> chmod +x kubectl
    - Move the kubctl to /usr/local/bin
    - Check the verison 
- Install eksctl
    - Move the eksctl to bin
    - Check the version
- Set up a IAM role 
    - ec2 -> ec2fullaccess, iam , cloudformation, Admin access
    - Add it to the role to eks server
- Creat you cluster on the server using eksctl create ~ 20 min
- Create a deployment in the cluster 
- expose the deployment as a sercice ~ loadbalancer

42. Create manifest file 
- Create a deployment file 
- create a sercice file - use the same table as deployment 
- check if the application is running 

43. Integrate kubernetes with Ansible 
- On Bootstrap server
    * Create ansadmin
    * Add ansadmin to sudoers file (visudo)
    * Enable passworkd based login (/etc/ssh/sshd_config yes, no)
    * reload the service 
- On Ansible Node
    * add to hosts file (/etc/ansible/hosts)
    * share the ssh keys
    * test the connections 
    * Add the private IP of eks to /etc/ansible/host file

44. Run the ansibe playbook for deployment
- Write the ansible play book for both deployment and service 
    - make sure the user is ec2-user
- Need to set up a passwork for ec2-user in eks (passwd ec2-user -> ec2-user)
- share the ssh key with the ec2-user user from ansible (ssh-copy-id ec2-user@172.31.38.141)	
- Test the connection

45. Create a new CD Job 
- Just a CD job to deploy the code to kuberneties 

46. Create a new CI Job
- Copy the old one and remove the post deployment step 
- add the post deployment step to trigger CD Job

47. Clean up
- Clean up deployment
    ```
    kubectl delete deployment.apps/dhanush-regapp
    kubectl delete service/regapp-service
    ```

- Clean up cluster
    ```
    eksctl delete cluster tomcat --region us-east-1
    ```