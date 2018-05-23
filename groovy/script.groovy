PROJECT_HOME = "/opt/terraform/terraform-aws-web"

node('praveenkandregula4') 
{
	stage('Create Infrastructure using terraform')
	{
		//sh (script: "cd ${PROJECT_HOME}/terraform && whoami", returnStatus: true)
		terraformStatus = sh (script: "cd ${PROJECT_HOME}/terraform && whoami && pwd && ~/terraform apply -auto-approve", returnStatus: true)
		print terraformStatus
	}
	
	stage ('Prepare EC2 inventory')
	{
		sh (script: "aws ec2 describe-instances --output text --query Reservations[*].Instances[*].[PublicDnsName] > /tmp/ec2.ini", returnStatus: true)
		sh (script: "cat /tmp/ec2.ini") 
	}
	
	stage ('Ansible ping')
	{
		ansiblePingStatus = sh (script: "export ANSIBLE_HOST_KEY_CHECKING=False && /usr/bin/ansible all -m ping -i /tmp/ec2.ini -u ec2-user  --private-key=/tmp/ohio-key.pem", returnStatus: true)
		print ansiblePingStatus
	}
	
	stage ('Deploy')
	{
		ansibleDeployStatus = sh (script: "export ANSIBLE_HOST_KEY_CHECKING=False && /usr/bin/ansible-playbook /opt/terraform/terraform-aws-web/ansible/web-httpd.yml -i /tmp/ec2.ini --private-key=/tmp/ohio-key.pem", returnStatus: true)
		print ansibleDeployStatus
	}
}
