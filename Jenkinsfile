pipeline {
    agent any

    environment {
        AWS_ACCESS_KEY_ID = credentials('applied-devops-project')
        AWS_SECRET_ACCESS_KEY = credentials('applied-devops-project')
        AWS_DEFAULT_REGION = 'us-east-1' // Update the region as per your AWS configuration
        ECR_REPO_NAME = 'applied-devops' // Update with your ECR repository name
        EKS_CLUSTER_NAME = 'applied-devops' // Update with your EKS cluster name
        DOCKER_IMAGE_NAME = 'applied_devops:v1.0' // Update with your Docker image name
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
                    docker build -t $DOCKER_IMAGE_NAME .
                '''
            }
        }

        stage('Push to ECR') {
            steps {
                script {
                    AWS_ACCOUNT_ID = sh(script: "aws sts get-caller-identity --query Account --output text", returnStdout: true).trim()
                    ecrLogin = sh(script: "aws ecr get-login-password --region ${AWS_DEFAULT_REGION}", returnStdout: true).trim()
                    sh "echo $ecrLogin | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com"
                    sh "docker tag $DOCKER_IMAGE_NAME:latest ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${ECR_REPO_NAME}:latest"
                    sh "docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${ECR_REPO_NAME}:latest"
                }
            }
        }

        stage('Deploy to EKS') {
            steps {
                script {
                    sh "aws eks --region ${AWS_DEFAULT_REGION} update-kubeconfig --name ${EKS_CLUSTER_NAME}"
                    sh "kubectl apply -f kubernetes/deployment.yaml"
                }
            }
        }
    }
}
