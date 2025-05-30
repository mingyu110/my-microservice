# AWS 权限和策略文件

这个目录包含了GitFlow CI/CD流水线所需的所有AWS IAM权限和信任策略文件。

## 文件说明

### CodeDeploy 相关
- **`codedeploy-policy.json`** - CodeDeploy服务角色权限策略
  - S3访问权限（获取部署工件）
  - ECS权限（服务更新、TaskSet操作）
  - ElasticLoadBalancing权限（流量切换）
  - CloudWatch权限（监控部署）
  
- **`codedeploy-trust-policy.json`** - CodeDeploy服务角色信任策略
  - 允许CodeDeploy服务承担此角色

### CodeBuild 相关
- **`codebuild-service-policy.json`** - CodeBuild项目权限策略
  - ECR权限（推送Docker镜像）
  - S3权限（访问构建工件）
  - CloudWatch Logs权限（构建日志）

- **`codebuild-trust-policy.json`** - CodeBuild服务角色信任策略
  - 允许CodeBuild服务承担此角色

### CodePipeline 相关
- **`codepipeline-service-policy.json`** - CodePipeline服务角色权限策略
  - S3权限（管理工件存储）
  - CodeBuild权限（触发构建）
  - CodeDeploy权限（触发部署）
  - IAM权限（传递角色）

- **`codepipeline-trust-policy.json`** - CodePipeline服务角色信任策略
  - 允许CodePipeline服务承担此角色

### ECS 相关
- **`ecs-task-execution-policy.json`** - ECS任务执行角色权限策略
  - ECR权限（拉取Docker镜像）
  - CloudWatch Logs权限（容器日志）

## 使用方法

### 创建IAM角色
```bash
# 创建CodeDeploy服务角色
aws iam create-role --role-name CodeDeployServiceRole \
  --assume-role-policy-document file://aws-permissions/codedeploy-trust-policy.json

# 附加权限策略
aws iam put-role-policy --role-name CodeDeployServiceRole \
  --policy-name CodeDeployServiceRolePolicy \
  --policy-document file://aws-permissions/codedeploy-policy.json
```

### 更新权限策略
```bash
# 更新现有角色的权限
aws iam put-role-policy --role-name CodeDeployServiceRole \
  --policy-name CodeDeployServiceRolePolicy \
  --policy-document file://aws-permissions/codedeploy-policy.json
```

## 权限说明

### 安全原则
1. **最小权限原则** - 每个角色只包含必需的权限
2. **权限分离** - 不同服务使用专门的角色
3. **资源限制** - 尽可能指定具体的资源ARN

### 渐进式权限配置
这些权限文件是通过实际部署过程中遇到的错误逐步完善的：

1. **初始权限** - 基本的服务权限
2. **S3权限** - 访问构建工件存储桶
3. **ELB权限** - Blue/Green部署的流量切换
4. **ECS TaskSet权限** - Blue/Green部署的任务集管理

### 故障排除
如果遇到权限错误：
1. 查看CloudTrail日志确定具体缺少的权限
2. 参考主文档的FAQ部分
3. 按需添加最小必要权限
4. 测试验证权限是否足够

## 相关文档
- 主文档：`基于 AWS CodePipeline 和 CodeDeploy 结合 GitHub 实现 Gitflow 的渐进式发布.md`
- 进度报告：`gitflow-pipeline-progress-report.md`
- AWS IAM 官方文档：https://docs.aws.amazon.com/iam/ 