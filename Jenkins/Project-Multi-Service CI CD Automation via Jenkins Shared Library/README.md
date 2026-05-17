# Multi-Service CI/CD Automation via Jenkins Shared Library

## 1. Overview
This project implements a **Centralized Jenkins Shared Library** designed to automate the CI/CD lifecycle for multiple microservices (Service A, B, and C). By utilizing a "Pipeline as Code" strategy, this architecture ensures that all services follow a standardized deployment workflow while remaining highly configurable through dynamic parameters like service names and ports.
<p align="center">
  <img src="./Screenshots/0-project-overview.PNG" width="100%">
  <br>
  <em><b>Figure 0:</b> Project Overview </em>
</p>

## 2. System Architecture
The following diagram illustrates the interaction between the centralized Shared Library, the independent service repositories, and the underlying infrastructure (AWS ECR & Docker):

<p align="center">
  <img src="./Screenshots/1-architecture_design.png" width="100%">
  <br>
  <em><b>Figure 1:</b> Centralized Shared Library Architecture</em>
</p>

## 3. GitHub Repositories

---

* **Shared Library Repo:** [jenkins-shared-library](https://github.com/EslamHarpy/jenkins-shared-library)
* **petclinic-service-A:** [spring-petclinic-service-A](https://github.com/EslamHarpy/service-a)
* **petclinic-service-B:** [spring-petclinic-service-B](https://github.com/EslamHarpy/service-b)
* **petclinic-service-C:** [spring-petclinic-service-C](https://github.com/EslamHarpy/service-c)

---

## 4. Key Features
*   **DRY Principle (Don't Repeat Yourself):** Instead of defining 3 separate pipelines, we define one single logic in the library to manage all services.
*   **Modular Pipeline:** A single Groovy script (`petclinicPipeline.groovy`) handles 10 dynamic stages, ensuring consistent environments across the organization.
*   **Dynamic Tagging:** Images are tagged uniquely per service (e.g., `service-a-latest`, `service-b-latest`) and stored in a unified AWS ECR repository.
*   **Conflict-Free Local Deployment:** Automated port mapping dynamically assigns ports (8081, 8082, 8083) to prevent container runtime conflicts on the host machine.

---

## 5. Prerequisites
Before implementing this modular architecture, ensure the following are configured:

### Local Infrastructure
- **Jenkins Server**: Installed and running on a Linux-based VM (Ubuntu recommended).
- **Docker engine**: Installed and the `jenkins` user added to the `docker` group for socket access.
- **AWS CLI**: Installed and configured with an IAM user having `AmazonEC2ContainerRegistryFullAccess`.

### Jenkins Configuration
- **Global Tools**: 
    - **JDK 17** (Eclipse Temurin).
    - **Maven 3.9.15**.
- **Credentials**: 
    - **AWS Credentials**: ID `aws-credentials-id` (Type: Username with Password).
    - **GitHub Credentials**: For private repository access if applicable.
- **Plugins**: `Pipeline`, `Docker Pipeline`, `Amazon Web Services SDK`, `Eclipse Temurin installer`, `Git`.

---

## 6. Environment Preparation & Infrastructure Setup

This section details the steps taken to prepare the local environment and the AWS cloud infrastructure to support a multi-service architecture.

### A. Microservices Repository Setup
To simulate a real-world microservices environment, three independent repositories were prepared. Each repository contains the Spring Petclinic source code and a unique `Jenkinsfile`.

1. **Cloning the Source:** The base application was cloned into three distinct project directories: `Service-A`, `Service-B`, and `Service-C`.
2. **Configuration Customization:** While the source code remains consistent, each service is deployed on a unique port (8081, 8082, 8083) to avoid local runtime conflicts.

### B. Unified AWS ECR Configuration
Instead of creating multiple ECR repositories, we configured a single high-performance repository to store all service images, distinguished by dynamic tagging.

1. **Repository Creation:** Created a private ECR repository named `my-spring-petclinic`.
2. **Tagging Strategy:** Designed a tagging convention: `${serviceName}-latest` (e.g., `service-a-latest`). This allows one repository to host multiple independent services efficiently.

<p align="center">
  <img src="./Screenshots/2-aws_ecr_setup.png" width="100%">
  <br>
  <em><b>Figure 2:</b> AWS ECR unified repository configuration</em>
</p>

### C. Jenkins Shared Library Structure
The core of this automation is the Shared Library. It follows the standard Jenkins structure to ensure it is recognized by the controller.

**Directory Structure:**
```text
jenkins-shared-library/
├── vars/
│   └── petclinicPipeline.groovy   # The main declarative pipeline logic
└── README.md
```
1. **The Global Logic:** The `vars/petclinicPipeline.groovy` script was developed to accept dynamic parameters (`imageName`,` appPort`).

2. **Library Call:** The library is invoked in each service's `Jenkinsfile` using the @Library annotation.

<p align="center">
  <img src="./Screenshots/3-shared_library_structure.png" width="100%">
  <br>
  <em><b>Figure 3:</b> Shared Library Structure</em>
</p> 

### D. Jenkins Global Trusted Library Registration
The library must be registered globally so that individual Pipeline Jobs can "trust" and execute the Groovy code.

1. Navigate to **Manage Jenkins** > **System**.
2. Go to Global Trusted Pipeline Libraries and add `my-shared-library`.
3. Link it to the Shared Library GitHub repository.
<p align="center">
  <img src="./Screenshots/4-jenkins_global_library_reg.png" width="100%">
  <br>
  <em><b>Figure 4:</b> Jenkins Global Library Regsitration </em>
</p> 

---

## 7. Pipeline Implementation (Shared Library Logic)

The heart of this automation is the `petclinicPipeline.groovy` script. It defines a standardized lifecycle that all microservices adhere to, ensuring that security, testing, and deployment patterns are identical across the environment.

### A. Shared Library Core Code (`vars/petclinicPipeline.groovy`)
The library uses a `Map` named `config` to receive dynamic data (Service Name and Port) from the calling repository.
```groovy
// Main logic for Multi-Service CI/CD
def call(Map config = [:]) {
    pipeline {
        agent any 
        
        tools {
            maven 'maven-3.9.15'
            jdk 'jdk-17'
        }
        
        environment {
            AWS_ACCOUNT_ID = '053274260339' 
            AWS_DEFAULT_REGION = 'us-east-1' 
            // Fixed ECR name to use one repository for all services
            IMAGE_REPO_NAME = 'my-spring-petclinic' 
            // Unique service-specific tag (e.g., service-a-15)
            SERVICE_TAG = "${config.imageName}-${env.BUILD_NUMBER}"
            // Unique service-latest tag (e.g., service-a-latest)
            SERVICE_LATEST = "${config.imageName}-latest"
            
            APP_PORT = "${config.appPort}"
            REPOSITORY_URI = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${IMAGE_REPO_NAME}"
        }
        
        stages {
            stage('first stage') {
                steps {
                    sh 'date'
                    sh 'echo hello from iti'
                    sh 'whoami'
                    sh 'pwd'
                }
            }
            
            stage('clone') {
                steps {
                    // Automatically clones the repository that invoked the library
                    checkout scm
                }
            }
            
            stage('change config') {
                steps {
                    // Overwrite application.properties with the dynamic port
                    sh "echo 'server.port=${APP_PORT}' > src/main/resources/application.properties"
                }
            }
            
            stage('compile') {
                steps {
                    sh 'mvn clean compile'
                }
            }
            
            stage('test') {
                steps {
                    sh 'mvn test  '
                }
            }
            
            stage('package') {
                steps {
                    // Packages the application into a JAR file, skipping tests to save time
                    sh 'mvn package -DskipTests'
                }
            }
            
            stage('Docker Build & Tag') {
                steps {
                    script {
                        // Builds image with a unique tag per service
                        sh "docker build -t ${REPOSITORY_URI}:${SERVICE_TAG} ."
                        sh "docker tag ${REPOSITORY_URI}:${SERVICE_TAG} ${REPOSITORY_URI}:${SERVICE_LATEST}"
                    }
                }
            }
            
            stage('Push to AWS ECR') {
                steps {
                    withCredentials([usernamePassword(credentialsId: 'aws-credentials-id', 
                                                     passwordVariable: 'AWS_SECRET_ACCESS_KEY', 
                                                     usernameVariable: 'AWS_ACCESS_KEY_ID')]) {
                        sh """
                        # Authenticate Docker with AWS ECR
                        aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com
                        # Push the specific build tag and the service-latest tag
                        docker push ${REPOSITORY_URI}:${SERVICE_TAG}
                        docker push ${REPOSITORY_URI}:${SERVICE_LATEST}
                        """
                    }
                }
            }
            
            stage('Deploy') {
                steps {
                    script {
                        // Removes the old container based on the service name (config.imageName)
                        sh "docker rm -f ${config.imageName} || true"
                        // Runs the container using the service-specific latest tag and overrides the port via arguments
                        sh "docker run -d -p ${APP_PORT}:${APP_PORT} --name ${config.imageName} ${REPOSITORY_URI}:${SERVICE_LATEST} --server.port=${APP_PORT}"
                    }
                }
            }
        }    
    }
}
```
### B. Invoking the Library (The Service `Jenkinsfile`)
Each microservice repository (`Service-A`, `Service-B`, `Service-C`) contains a minimal `Jenkinsfile`. This abstraction keeps the application code clean and focuses on configuration rather than infrastructure logic.

**Example for Service-B:**
```Groovy
@Library('my-shared-library') _

petclinicPipeline(
    imageName: 'service-b',
    appPort: '8082'
)
```
### C. Pipeline Stages Breakdown
1. **Environment Info:** Verifies the Jenkins agent state.
2. **Checkout SCM:** Dynamically pulls code from the repository that triggered the job.
3. **Config Override:** Injects the specific `APP_PORT` into the Spring Boot properties.
4. **Compile & Package:** Standard Java build lifecycle using Maven.
5. **Docker Build & Tagging:** Creates a Docker image and applies dual tagging (Build Number & Latest).
6. **Push to ECR:** Authenticates with AWS and uploads the artifacts.
7. **Deploy & Run:** Hot-swaps the container on the local VM with the updated image.

---

## 8. Pipeline Execution & Verification

In this final section, we demonstrate the successful orchestration of all three services through the Jenkins dashboard and verify their deployment on the host machine.

### A. Jenkins Stage View (Multi-Service Status)
The Jenkins Stage View provides a visual confirmation that the Shared Library logic executed perfectly across all repositories. Every stage—from cloning to deployment—is completed successfully for each independent pipeline.

<p align="center">
  <img src="./Screenshots/5-pipeline_stage_view_success.png" width="100%">
  <br>
  <em><b>Figure 5:</b> Successful execution of the stages modular pipeline</em>
</p>

### B. AWS ECR Artifact Verification
Each build pushed two unique tags to the unified ECR repository:
1.  **Build Tag**: `${serviceName}-${buildNumber}` (e.g., `service-a-15`) for version history.
2.  **Latest Tag**: `${serviceName}-latest` (e.g., `service-a-latest`) for deployment.

<p align="center">
  <img src="./Screenshots/6-aws_ecr_images_verify.png" width="100%">
  <br>
  <em><b>Figure 6:</b> Multiple service images hosted within a single ECR repository</em>
</p>

### C. Local Runtime Verification
Using the terminal on the Jenkins host, we can verify that all three microservices are running simultaneously on their designated ports without any network conflicts.
```bash
docker ps
```
<p align="center">
  <img src="./Screenshots/7-docker_ps_images_verify.png" width="100%">
  <br>
  <em><b>Figure 7:</b> Docker Ps Images Verify </em>
</p>

### D. Final Application Access
The final proof of success is accessing the applications via a web browser. Each service is fully functional, independent, and serving traffic on its assigned dynamic port.

* **Service A:** `http://localhost:8081`

<p align="center">
  <img src="./Screenshots/8-Service_A_verify.png" width="100%">
  <br>
  <em><b>Figure 8:</b> Service A verify </em>
</p>

* **Service B:** `http://localhost:8082`

<p align="center">
  <img src="./Screenshots/9-Service_B_verify.png" width="100%">
  <br>
  <em><b>Figure 9:</b> Service B verify </em>
</p>

* **Service C:** `http://localhost:8083`

<p align="center">
  <img src="./Screenshots/10-Service_C_verify.png" width="100%">
  <br>
  <em><b>Figure 10:</b> Service C verify </em>
</p>

--- 

### 9. Conclusion
By implementing a **Jenkins Shared Library**, we successfully transitioned from repetitive, error-prone pipelines to a scalable, professional automation framework. This architecture allows the organization to onboard new services in minutes by simply adding a two-line `Jenkinsfile`, ensuring high-velocity delivery with enterprise-grade consistency.
 
