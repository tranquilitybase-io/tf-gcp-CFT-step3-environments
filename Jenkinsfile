pipeline {
    agent {
        kubernetes {
          label 'kubepod' 
          defaultContainer 'gcloud' 
        }
    }
    environment {
       def environment_params = "${environment_params}"
       def cicd_project = "${cicd_project}"
        
  }
    stages {
        
        stage ('Test received params') {
            steps {
                sh '''
                echo \"$environment_params\"
                echo \"$cicd_project\"
                '''
            }
        }
        stage('Activate GCP Service Account and Set Project') {
            steps {
                
                container('gcloud') {
                    sh '''
                        gcloud auth activate-service-account --key-file=$GOOGLE_APPLICATION_CREDENTIALS
                        gcloud config list
                       '''
                }
            }
            
        }
       stage('Setup Terraform & Dependencies') {
             steps {
                 container('gcloud') {
                     sh '''
                       
                         apt-get -y install jq wget unzip
                         wget -O /tmp/terraform.zip https://releases.hashicorp.com/terraform/0.13.7/terraform_0.13.7_linux_amd64.zip
                         unzip -q /tmp/terraform.zip -d /tmp
                         chmod +x /tmp/terraform
                         mv /tmp/terraform /usr/local/bin
                         rm /tmp/terraform.zip
                         terraform --version
                        '''
                 }
             }

         }
         stage('Deploy CFT env') {
             steps {
                 container('gcloud') {
                     sh '''
                        export CLOUD_BUILD_PROJECT_ID=$cicd_project 
                        cd ./scripts/2-environments/ && echo \"$environment_params\" | jq "." > terraform.auto.tfvars.json
                        cat terraform.auto.tfvars.json
                        cd ../.. && make env
                        echo "2-environments done"
                        '''
    
                 }
               
             }
         }
    
    
    }
    
    
    
}
