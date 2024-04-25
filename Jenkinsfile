pipeline {
    agent any

    environment {
        AWS_ACCESS_KEY_ID = credentials('applied-devops-project')
        AWS_SECRET_ACCESS_KEY = credentials('applied-devops-project')
        AWS_DEFAULT_REGION = 'us-east-1' // Update the region as per your AWS configuration
        ECR_REPO_NAME = 'applied-devops' // Update with your ECR repository name
        EKS_CLUSTER_NAME = 'applied-devops' // Update with your EKS cluster name
        DOCKER_IMAGE_NAME_FOR_CLIENT = 'harshpandey3001/client:latest'
        DOCKER_IMAGE_NAME_FOR_SERVER = 'harshpandey3001/server'
        ECR_URL = '975050378366.dkr.ecr.us-east-1.amazonaws.com'
        PROFILE_NAME = 'applied-devops'

    }

    stages {
        stage('Checkout') {
            steps {
                sh '''
                    rm -rf student_housing_chain
                    git clone https://github.com/LelutoDeku/student_housing_chain.git
                    cd student_housing_chain
                    git checkout main
                    '''
            }
        }

        stage('Build Docker Image') {
            steps {
                sh ''' 
                    curl -fsSL https://get.docker.com -o get-docker.sh
                    sh get-docker.sh
                    chown -R 1000:1000 /var/run/docker.sock                    
                    nohup dockerd >/dev/null 2>&1 &
                    docker pull $DOCKER_IMAGE_NAME_FOR_CLIENT
                    docker pull $DOCKER_IMAGE_NAME_FOR_SERVER
                    
                '''
            }
        }

        stage('Push to ECR') {
            steps {
                script {
                        //  Install AWS CLI
                    sh '''
                        curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
                        unzip -u awscliv2.zip
                        ./aws/install -i /usr/local/aws-cli -b /usr/local/bin --update
                    '''
                    
                    sh '''
                    echo $AWS_ACCOUNT_ID
                        aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 975050378366.dkr.ecr.us-east-1.amazonaws.com
                        docker tag $DOCKER_IMAGE_NAME_FOR_CLIENT $ECR_URL/${ECR_REPO_NAME}:client_3000
                        docker tag $DOCKER_IMAGE_NAME_FOR_SERVER $ECR_URL/${ECR_REPO_NAME}:server_3010
                        docker push $ECR_URL/${ECR_REPO_NAME}:client_3000
                        docker push $ECR_URL/${ECR_REPO_NAME}:server_3010

                    '''
                
                }
            }
        }

        stage('Terraform Provision') {
            environment {
                TF_IN_AUTOMATION = 'true' // Set Terraform in automation mode
            }
            steps {
                script {
                    // Initialize Terraform
                    sh 'terraform init'
                    
                    // Apply Terraform configuration to create resources
                    sh 'terraform apply -auto-approve'
                    // Retrieve the public IP address from Terraform output and store it in a variable
                    def EC2_PUBLIC_IP = sh(
                        script: "terraform output -raw public_ip",
                        returnStdout: true
                    ).trim()

                    // Output the value of the variable
                    echo "The public IP address of the EC2 instance is: $EC2_PUBLIC_IP"

                }
            }
        }

        stage('Deploy to EC2') {
            steps {
                script {
                    sh '''
                      // Get the public IP address from Terraform output
                    PUBLIC_IP=\$(terraform output -raw public_ip)

                     // Get the private key contents from Terraform output
                    PRIVATE_KEY=\$(terraform output -raw private_key_pem)

                     // Create a temporary file with the private key contents
                    echo "\$PRIVATE_KEY" > /tmp/ec2_private_key.pem
                    chmod 600 /tmp/ec2_private_key.pem

                     // Copy your application to the EC2 instance
                    scp -i /tmp/ec2_private_key.pem -r /path/to/your/application ec2-user@\${PUBLIC_IP}:/path/on/ec2

                     // Connect to the EC2 instance and run the Docker containers
                    ssh -i /tmp/ec2_private_key.pem ec2-user@\${PUBLIC_IP} "
                        cd /path/on/ec2/application
                        docker run -d -p 3000:3000 ${ECR_URL}/${ECR_REPO_NAME}:client_3000
                        docker run -d -p 3010:3010 ${ECR_URL}/${ECR_REPO_NAME}:server_3010
                    "
                    '''
                }
            }
        }
    }
}
