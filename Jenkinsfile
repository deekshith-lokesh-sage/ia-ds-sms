pipeline {
    agent {
        node {
            label 'java11'
        }
    }
    tools {
        maven 'mvn3.6.3'
    }
    stages {
        stage('Maven Install') {
            steps {
                  script {
                   if (env.BRANCH_NAME.startsWith('PR')) {
                        withMaven(maven: 'mvn3.6.3', globalMavenSettingsConfig: 'MyGlobalMavenJenkins') {
                            try {
                                sh "mvn clean install -Dmaven.repo.local=/u02/home/jenkins/${env.NODE_NAME}/workspace/.m2/repository"
                            } catch (Exception err) {
                                echo 'Maven clean install failed'
                                currentBuild.result = 'FAILURE'
                                slackSend channel: '#ci-jenkins-test', color: '#FF0000', failOnError: true, message: "FAILED ${env.JOB_NAME} ${env.BUILD_NUMBER} (<${env.BUILD_URL}|Open>)", notifyCommitters: true, tokenCredentialId: 'ci-jenkins-test'
                                emailext body: "FAILED ${env.JOB_NAME} ${env.BUILD_NUMBER} (<${env.BUILD_URL}|Open>)", recipientProviders: [culprits(), brokenBuildSuspects()], replyTo: 'no-reply@sage.com', subject: "FAILED ${env.JOB_NAME} ${env.BUILD_NUMBER} (<${env.BUILD_URL}|Open>)", to: "izet.salihbegovic@sage.com"
                            } finally {
                                // publishHTMLReports('Reports')
                            }
                        }
                    } 
                }
            }
        }
   }
} 
