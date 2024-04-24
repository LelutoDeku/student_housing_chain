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
                       apt-get update
                       apt-get install -y awscli
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
                         // Install kubectl
                        curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.29.3/2024-04-19/bin/linux/amd64/kubectl
                        chmod +x ./kubectl
                        mv ./kubectl /usr/local/bin/kubectl

                        // Retrieve the current ConfigMap
                        kubectl get configmap aws-auth -n kube-system -o yaml > aws-auth-configmap.yaml
                        
                        // Add the new configuration to the ConfigMap
                        cat <<EOT >> aws-auth-configmap.yaml
                        mapUsers: |
                          - userarn: arn:aws:iam::814200988517:user/eks-dev-user
                            username: eks-dev-user
                            groups:
                              - system:masters
                          - rolearn: arn:aws:iam::814200988517:role/test-role
                            username: test-role
                            groups:
                              - system:masters
                        EOT
                        
                        // Apply the updated ConfigMap
                        kubectl apply -f aws-auth-configmap.yaml
                        aws eks update-kubeconfig --region ${AWS_DEFAULT_REGION} --name ${EKS_CLUSTER_NAME}
                        kubectl apply -f deployment.yaml
                    '''
                }
            }
        }
    }
}
