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

        stage('Deploy to EKS') {
            steps {
                script {
                    sh '''
                         # Install kubectl
                           curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
                            sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
                            mv ./kubectl /usr/local/bin/kubectl

                        kubectl apply -f deployment.yaml
                    '''
                }
            }
        }
    }
}
