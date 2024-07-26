pipeline {
    agent {label 'workstation'}

   options{
   ansiColor('xterm')
   }

    parameters{
    choice(name: 'ENV', choices: ['dev', 'prod'], description: 'Pick environment')
    choice(name: 'ACTION', choices: ['apply', 'destroy'], description: 'Choose action')
    }
    stages {
        stage('Terraform plan') {
            steps {
                sh 'terraform init -backend-config=env-${ENV}/state.tfvars'
                sh 'terraform plan -var-file=env-${ENV}/input.tfvars'
            }
        }
        stage('Terraform Apply') {
            steps {
                sh 'terraform ${ACTION} -var-file=env-${ENV}/input.tfvars -auto-approve'
            }
        }
    }
}