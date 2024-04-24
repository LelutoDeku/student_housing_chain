pipeline {
    agent any
    
    environment {
        AWS_ACCESS_KEY_ID     = credentials('aws-access-key-id')
        AWS_SECRET_ACCESS_KEY = credentials('aws-secret-access-key')
        AWS_DEFAULT_REGION    = 'us-east-1' # Update the region as per your AWS configuration
        ECR_REPO_NAME         = 'applied-devops' # Update with your ECR repository name
        EKS_CLUSTER_NAME      = 'applied-devops' # Update with your EKS cluster name
        DOCKER_IMAGE_NAME     = 'applied_devops:v1.0' # Update with your Docker image name
    }

    stages {
        stage('Checkout') {
            steps {
                script {
                    # Checkout code from GitHub
                    git 'https://github.com/your-username/your-repo.git'
                }
            }
        }
        
        stage('Build Docker Image') {
            steps {
                script {
                    # Build Docker image
                    docker build -t $DOCKER_IMAGE_NAME .
                }
            }
        }
        
        stage('Push to ECR') {
            steps {
                script {
                    # Authenticate with AWS ECR
                    AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

                    # Get the ECR login command
                    ecrLogin=$(aws ecr get-login-password --region ${AWS_DEFAULT_REGION})

                    # Login to AWS ECR
                    echo $ecrLogin | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com

                    # Tag the Docker image
                    docker tag $DOCKER_IMAGE_NAME:latest ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${ECR_REPO_NAME}:latest

                    # Push Docker image to ECR
                    docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${ECR_REPO_NAME}:latest
                }
            }
        }
        
        stage('Deploy to EKS') {
            steps {
                script {
                    # Authenticate with AWS EKS
                    aws eks --region ${AWS_DEFAULT_REGION} update-kubeconfig --name ${EKS_CLUSTER_NAME}

                    # Apply deployment
                    kubectl apply -f kubernetes/deployment.yaml
                }
            }
        }
    }
}
