#!/bin/bash

echo "🔍 检查 GitFlow CI/CD 流水线状态..."
echo "================================================"

# 获取最新的执行状态
echo "📊 最新执行状态:"
aws codepipeline list-pipeline-executions \
  --pipeline-name my-microservice-pipeline \
  --region us-west-2 \
  --query 'pipelineExecutionSummaries[0].[pipelineExecutionId,status,startTime]' \
  --output table

echo ""
echo "🔧 各阶段详细状态:"
aws codepipeline get-pipeline-state \
  --name my-microservice-pipeline \
  --region us-west-2 \
  --query 'stageStates[*].[stageName,latestExecution.status,latestExecution.lastStatusChange]' \
  --output table

echo ""
echo "🎯 快速状态总结:"
STATUS=$(aws codepipeline get-pipeline-state --name my-microservice-pipeline --region us-west-2 --query 'stageStates[*].latestExecution.status' --output text)

echo "Source: $(echo $STATUS | cut -d' ' -f1)"
echo "Build:  $(echo $STATUS | cut -d' ' -f2)" 
echo "Deploy: $(echo $STATUS | cut -d' ' -f3)"

echo ""
echo "🔄 要重新触发流水线，运行:"
echo "aws codepipeline start-pipeline-execution --name my-microservice-pipeline --region us-west-2" 