#!/usr/bin/env groovy

bearychatNotify "Started"
wechatNotify "Started"

pipeline {
    agent {
        label 'os:linux'
    }
    options {
        skipDefaultCheckout()
        disableConcurrentBuilds()
        buildDiscarder(logRotator(
            daysToKeepStr: '15',
            artifactNumToKeepStr: '20'
        ))
        ansiColor('xterm')
    }
    stages {
        stage('Clean Workspace') {
            steps {
                cleanWs()
            }
        }
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        stage('Build wrk') {
            steps {
                sh """
                    git submodule init wrk2/
                    git submodule update wrk2/
                    make -j`nproc` -C wrk2/
                    mkdir target && cp *.lua wrk2/wrk target
                """
            }
        }
        stage('Archive') {
            steps {
                zip zipFile: 'target/wrk.zip', dir: 'target', glob: '', archive: true
            }
        }
    }
    post {
        success {
            bearychatNotify what: "Success", withDuration: true, withSummary: true, withChanges: true
            wechatNotify what: "Success", withDuration: true, withSummary: true, withChanges: true
        }
        failure {
            bearychatNotify what: "Failure", withDuration: true, withSummary: true, withChanges: true
            wechatNotify what: "Failure", withDuration: true, withSummary: true, withChanges: true
        }
    }
}
