#!/bin/bash

# 定义标签前缀
TAG_PREFIX="$1"
# 如果$1 为空 , 返回
if [ -z "$1" ]; then
  echo "请输出build 目标"
  exit
fi
echo $1

# 检查 pubspec.yaml 文件是否存在
if [ ! -f "./pubspec.yaml" ]; then
  echo "pubspec.yaml not found in current directory."
  echo "Please make sure you are running this script from the project root."
  cd ..
fi

# 打印当前工作目录
pwd

# 提取版本号
VERSION=$(grep '^version: ' pubspec.yaml | sed 's/version: //')
if [ -z "$VERSION" ]; then
  echo "Version not found in pubspec.yaml."
  exit 1
fi

# 获取最新的 Git 提交哈希
GIT_HASH=$(git rev-parse --short HEAD)
echo "Tag: ${TAG_PREFIX}_v$VERSION - Message: Release version $VERSION, based on commit $GIT_HASH"

# 提交更改
git add .
git commit -m "Release version $VERSION"

# 删除本地存在的同名标签（如果有）
git tag -d "${TAG_PREFIX}_v$VERSION" 2>/dev/null

# 删除远程存在的同名标签（如果有）
git push origin ":refs/tags/${TAG_PREFIX}_v$VERSION"

# 创建新的注释标签
git tag -a "${TAG_PREFIX}_v$VERSION" -m "Release version $VERSION, based on commit $GIT_HASH"

# 推送提交到远程仓库
git push origin

# 推送标签到远程仓库
git push origin "refs/tags/${TAG_PREFIX}_v$VERSION"
