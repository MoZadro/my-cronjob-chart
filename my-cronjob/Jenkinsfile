def suppressEcho(cmd) {
    steps.sh (script: '#!/bin/sh -e\n'+ cmd, returnStdout: true)
}

pipeline {
  options {
      timeout(time: 10, unit: 'MINUTES')
      disableConcurrentBuilds() 
  }
  agent {
    label "generic"
  }
  environment {
      
    DOCKER_GOD_REGISTRY='docker-app.nsoft.com:10884'
    DOCKER_GOD_REGISTRY_CREDENTIALS_ID = 'docker-repo-god'
    HELM_IMAGE = 'helm-chart-template-upgrade:1.0'
    HELM_CHART_REPOSITORY_URL = "https://chartmuseum.utility.nsoft.cloud/"
    HELM_CHART_REPOSITORY_NAME = "chartmuseum"
    HELM_CHART_NAME = "my-cronjob-chart"

  }
  stages {

    stage ('Install stable') {
      agent {
        docker {
            image "${DOCKER_GOD_REGISTRY}/${HELM_IMAGE}"
            args "-u root"
            registryUrl "https://${DOCKER_GOD_REGISTRY}"
            registryCredentialsId "${DOCKER_GOD_REGISTRY_CREDENTIALS_ID}"
            label "generic"
        }
      }

      steps {
            
            sh "helm repo add ${HELM_CHART_REPOSITORY_NAME} ${HELM_CHART_REPOSITORY_URL} "
            withCredentials([usernamePassword(credentialsId: 'chartmuseum-user', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
                        sh("helm push ./ ${HELM_CHART_REPOSITORY_NAME} -p ${PASSWORD} -u ${USERNAME}")
            }
            

        


                  

          }
      }
  }
  post {
    always {
      cleanWs()
    }
  }

}