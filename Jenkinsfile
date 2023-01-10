pipeline {
    agent {
        node {
            label 'java17'
        }
    }
    tools {
        maven 'mvn3.6.3'
    }
    stages {
        stage('Maven') {
            steps {
                  script {
                     echo "Branch=${env.BRANCH_NAME}, author=${env.CHANGE_AUTHOR}"
                     if (env.BRANCH_NAME.startsWith('PR') && ! env.CHANGE_AUTHOR.startsWith('ia-ds-bot') && ! env.CHANGE_AUTHOR.startsWith('github-actions')) {
                        withMaven(maven: 'mvn3.6.3', globalMavenSettingsConfig: 'MyGlobalMavenJenkins') {
                            try {
                                sh "mvn clean package -Dmaven.repo.local=/u02/home/jenkins/${env.NODE_NAME}/workspace/.m2/repository"
                            } catch (Exception err) {
                                echo 'Maven clean package failed'
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
