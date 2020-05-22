pipeline {
    agent any
    options {
        timeout(time: 1, unit: 'HOURS')
        disableConcurrentBuilds()
    }
    triggers {
        cron 'H H/8 * * *'
    }

    stages {
        stage('Installing dependencies') {
            steps {
                echo 'installing NPM dependencies'
                sh '''
                npm i
                '''

                echo 'installing Haxe dependencies'
                sh '''
                npx lix download
                '''
            }
        }

        stage('Download benchs.haxe.org') {
            steps {
                echo 'Copy Formatter detail pages'
                sh '''
                if [ ! -d "benchs.haxe.org" ]; then
                    git clone --depth 1 https://github.com/HaxeBenchmarks/benchs.haxe.org.git
                else
                    cd benchs.haxe.org
                    git pull
                fi
                '''
            }
        }

        stage('Prepare site') {
            steps {
                echo 'Preparing site folder'
                sh '''
                mkdir -p site/js
                mkdir -p site/css
                '''
            }
        }

        stage('Build benchmark.css') {
            steps {
                echo 'Building benchmark.cs'
                sh '''
                npx sass css/one-shot-benchmark.scss site/css/one-shot-benchmark.css
                '''
            }
        }

        stage('Build benchmark.js') {
            steps {
                echo 'Building one-shot-benchmark.js'
                sh '''
                npx haxe buildOneShotJs.hxml
                '''
            }
        }

        stage('Build one-shot-page PHP') {
            steps {
                echo 'Building one-shot-page PHP'
                sh '''
                npx haxe build.hxml
                '''
            }
        }

        stage('Install to webserver') {
            steps {
                echo 'Install to webserver'
                sh '''
                rsync -rlu site/* $BENCHMARKS_WEBROOT/one-shot
                mkdir -p $BENCHMARKS_WEBROOT/one-shot-benchmarks
                '''
            }
        }
    }
}
