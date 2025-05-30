from diagrams import Diagram, Cluster
from diagrams.aws.network import VPC, InternetGateway, PublicSubnet
from diagrams.aws.compute import ECS
from diagrams.aws.network import ALB
from diagrams.aws.general import General

with Diagram("AWS Microservice Architecture with Gitflow", show=False, filename="aws_architecture_diagram", direction="TB", outformat="png"):
    with Cluster("VPC (vpc-076575a3420ca3e1a)"):
        igw = InternetGateway("Internet Gateway")
        sg = General("Security Group\n(HTTP/SSH/3000)")
        with Cluster("Public Subnets"):
            subnet1 = PublicSubnet("Subnet 1\nus-west-2a\n10.0.1.0/24")
            subnet2 = PublicSubnet("Subnet 2\nus-west-2b\n10.0.2.0/24")
        alb = ALB("Application Load Balancer")
        ecs = ECS("ECS Fargate Service")

        igw >> subnet1
        igw >> subnet2
        subnet1 >> alb
        subnet2 >> alb
        alb >> ecs
        ecs >> sg