#!/bin/bash

echo "🔍 AWS 资源验证脚本 (改进版)"
echo "=============================="

# 获取账户信息
echo "📋 1. 验证AWS账户信息..."
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text 2>/dev/null)
if [ $? -eq 0 ]; then
    echo "✅ 账户ID: $ACCOUNT_ID"
    echo "✅ 区域: us-west-2"
else
    echo "❌ AWS凭证配置有问题"
    exit 1
fi

echo ""

# 检查ECR仓库
echo "🐳 2. 验证ECR仓库..."
ECR_REPO=$(aws ecr describe-repositories --repository-names my-microservice --region us-west-2 --query 'repositories[0].repositoryName' --output text 2>/dev/null)
if [ "$ECR_REPO" = "my-microservice" ]; then
    echo "✅ ECR仓库存在: my-microservice"
    ECR_URI=$(aws ecr describe-repositories --repository-names my-microservice --region us-west-2 --query 'repositories[0].repositoryUri' --output text 2>/dev/null)
    echo "✅ ECR URI: $ECR_URI"
else
    echo "❌ ECR仓库不存在"
fi

echo ""

# 检查IAM角色
echo "🔐 3. 验证IAM角色..."

# 检查CodePipelineServiceRole
CP_ROLE=$(aws iam get-role --role-name CodePipelineServiceRole --query 'Role.RoleName' --output text 2>/dev/null)
if [ "$CP_ROLE" = "CodePipelineServiceRole" ]; then
    echo "✅ CodePipelineServiceRole 存在"
    
    # 检查角色策略
    CP_POLICY=$(aws iam get-role-policy --role-name CodePipelineServiceRole --policy-name CodePipelineServicePolicy --query 'PolicyName' --output text 2>/dev/null)
    if [ "$CP_POLICY" = "CodePipelineServicePolicy" ]; then
        echo "✅ CodePipelineServicePolicy 已附加"
    else
        echo "❌ CodePipelineServicePolicy 未附加"
    fi
else
    echo "❌ CodePipelineServiceRole 不存在"
fi

# 检查CodeBuildServiceRole
CB_ROLE=$(aws iam get-role --role-name CodeBuildServiceRole --query 'Role.RoleName' --output text 2>/dev/null)
if [ "$CB_ROLE" = "CodeBuildServiceRole" ]; then
    echo "✅ CodeBuildServiceRole 存在"
    
    # 检查角色策略
    CB_POLICY=$(aws iam get-role-policy --role-name CodeBuildServiceRole --policy-name CodeBuildServicePolicy --query 'PolicyName' --output text 2>/dev/null)
    if [ "$CB_POLICY" = "CodeBuildServicePolicy" ]; then
        echo "✅ CodeBuildServicePolicy 已附加"
    else
        echo "❌ CodeBuildServicePolicy 未附加"
    fi
else
    echo "❌ CodeBuildServiceRole 不存在"
fi

echo ""

# 检查CodeBuild项目
echo "🏗️ 4. 验证CodeBuild项目..."
CB_PROJECT=$(aws codebuild batch-get-projects --names my-microservice-build --region us-west-2 --query 'projects[0].name' --output text 2>/dev/null)
if [ "$CB_PROJECT" = "my-microservice-build" ]; then
    echo "✅ CodeBuild项目存在: my-microservice-build"
else
    echo "❌ CodeBuild项目不存在"
fi

echo ""

# 检查CodeDeploy应用
echo "🚀 5. 验证CodeDeploy应用..."
CD_APP=$(aws deploy get-application --application-name my-ecs-app --region us-west-2 --query 'application.applicationName' --output text 2>/dev/null)
if [ "$CD_APP" = "my-ecs-app" ]; then
    echo "✅ CodeDeploy应用存在: my-ecs-app"
else
    echo "❌ CodeDeploy应用不存在"
fi

echo ""

# 检查CodePipeline
echo "🔄 6. 验证CodePipeline..."
CP_PIPELINE=$(aws codepipeline get-pipeline --name my-microservice-pipeline --region us-west-2 --query 'pipeline.name' --output text 2>/dev/null)
if [ "$CP_PIPELINE" = "my-microservice-pipeline" ]; then
    echo "✅ CodePipeline存在: my-microservice-pipeline"
    
    # 检查仓库配置
    REPO_ID=$(aws codepipeline get-pipeline --name my-microservice-pipeline --region us-west-2 --query 'pipeline.stages[0].actions[0].configuration.FullRepositoryId' --output text 2>/dev/null)
    echo "✅ 配置仓库: $REPO_ID"
else
    echo "❌ CodePipeline不存在"
fi

echo ""

# 检查GitHub连接
echo "🔗 7. 验证GitHub连接..."
CONNECTIONS=$(aws codestar-connections list-connections --region us-west-2 --query 'Connections[?ConnectionName==`my-github-connection`]' --output json 2>/dev/null)
if [ "$CONNECTIONS" != "[]" ] && [ "$CONNECTIONS" != "" ]; then
    echo "✅ GitHub连接存在: my-github-connection"
    CONNECTION_STATUS=$(echo "$CONNECTIONS" | grep -o '"ConnectionStatus":"[^"]*"' | head -1 | cut -d'"' -f4)
    if [ "$CONNECTION_STATUS" = "AVAILABLE" ]; then
        echo "✅ 连接状态: AVAILABLE (已授权)"
    else
        echo "⚠️  连接状态: $CONNECTION_STATUS (需要在控制台授权)"
    fi
else
    echo "❌ GitHub连接不存在"
fi

echo ""
echo "🎉 验证完成！"
echo ""
echo "💡 提示："
echo "- ✅ 表示组件已正确配置"
echo "- ❌ 表示组件缺失或配置有问题"  
echo "- ⚠️  表示需要手动操作"
echo "- 请根据验证结果进行相应的配置调整" 