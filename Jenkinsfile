pipeline {
    parameters {
        booleanParam(name: 'autoApprove', defaultValue: false, description: 'Automatically run apply after generating plan?')
    }
    environment {
        AWS_ACCESS_KEY_ID     = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
        PATH = "${PATH}:/usr/local/bin"  // Add this line to ensure Terraform is in PATH
    }

    agent any

    stages {
        stage('Checkout') {
            steps {
                script {
                    dir("terraform") {
                        git "https://github.com/vikrantyadav1996/Terraform-Jenkins.git"
                    }
                }
            }
        }

        stage('Terraform Init') {  // Split into separate stages for better error handling
            steps {
                script {
                    dir("terraform") {
                        sh 'terraform init'
                    }
                }
            }
        }

        stage('Plan') {
            steps {
                script {
                    dir("terraform") {
                        sh 'terraform plan -out=tfplan'
                        sh 'terraform show -no-color tfplan > tfplan.txt'
                    }
                }
            }
        }

        stage('Approval') {
            when {
                not {
                    equals expected: true, actual: params.autoApprove
                }
            }
            steps {
                script {
                    def plan = readFile 'terraform/tfplan.txt'
                    input message: "Do you want to apply the plan?",
                          parameters: [text(name: 'Plan', description: 'Please review the plan', defaultValue: plan)]
                }
            }
        }

        stage('Apply') {
            steps {
                script {
                    dir("terraform") {
                        sh 'terraform apply -input=false tfplan'
                    }
                }
            }
        }
    }

    post {
        always {
            cleanWs()  // Clean workspace after pipeline
        }
    }
}
