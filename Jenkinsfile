pipeline {
    parameters {
        booleanParam(name: 'autoApprove', defaultValue: false, description: 'Automatically run apply after generating plan?')
    }
    environment {
        AWS_ACCESS_KEY_ID     = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
        PATH = "C:\\terraform;${PATH}"  // Add Terraform path
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
        stage('Terraform Init') {
            steps {
                script {
                    dir("terraform") {
                        sh 'C:\\terraform\\terraform init'  // Full path to Terraform
                    }
                }
            }
        }
        stage('Plan') {
            steps {
                script {
                    dir("terraform") {
                        sh 'C:\\terraform\\terraform plan -out=tfplan'
                        sh 'C:\\terraform\\terraform show -no-color tfplan > tfplan.txt'
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
                        sh 'C:\\terraform\\terraform apply -input=false tfplan'
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

