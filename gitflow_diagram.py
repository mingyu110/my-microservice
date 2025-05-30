#!/usr/bin/env python3
"""
GitFlow Process Diagram with CI/CD Integration
This script creates a visual representation of the GitFlow branching model
with AWS CodePipeline integration.
"""

from diagrams import Cluster, Diagram, Edge
from diagrams.generic.blank import Blank
from diagrams.aws.devtools import Codepipeline, Codedeploy, Codebuild
from diagrams.aws.compute import ECS, ECR
from diagrams.onprem.vcs import Git

with Diagram("GitFlow with AWS CI/CD Pipeline", show=False, direction="TB"):
    
    with Cluster("Git Repository (GitHub)"):
        # Main branches
        main = Git("main")
        develop = Git("develop")
        
        # Supporting branches
        with Cluster("Feature Branches"):
            feature1 = Git("feature/user-auth")
            feature2 = Git("feature/api-v2")
        
        with Cluster("Release Branch"):
            release = Git("release/v1.2.0")
            
        with Cluster("Hotfix Branch"):
            hotfix = Git("hotfix/security-fix")
    
    with Cluster("AWS CI/CD Pipeline"):
        # CodePipeline stages
        pipeline = Codepipeline("CodePipeline")
        build = Codebuild("CodeBuild")
        ecr = ECR("ECR Repository")
        deploy = Codedeploy("CodeDeploy")
        ecs = ECS("ECS Fargate")
    
    # GitFlow connections
    feature1 >> Edge(label="PR & merge") >> develop
    feature2 >> Edge(label="PR & merge") >> develop
    develop >> Edge(label="create release") >> release
    release >> Edge(label="merge") >> main
    release >> Edge(label="merge back") >> develop
    main >> Edge(label="critical fix") >> hotfix
    hotfix >> Edge(label="merge") >> main
    hotfix >> Edge(label="merge back") >> develop
    
    # CI/CD Pipeline connections
    main >> Edge(label="trigger on merge") >> pipeline
    develop >> Edge(label="trigger on merge") >> pipeline
    pipeline >> build
    build >> Edge(label="push image") >> ecr
    ecr >> deploy
    deploy >> Edge(label="blue-green deployment") >> ecs

print("GitFlow diagram generated successfully!")
print("Check the 'gitflow_with_aws_ci_cd_pipeline.png' file in your current directory.")