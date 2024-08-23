cd ../
# 1. 清理历史记录
git filter-branch --force --index-filter "git rm --cached --ignore-unmatch lib/misc/env_param_utils.g.dart" --prune-empty --tag-name-filter cat -- --all

# 2. 强制推送到远程仓库
git push origin --force --all
git push origin --force --tags

# 3. 删除本地和远程的备份引用（可选）
rm -rf .git/refs/original
git reflog expire --expire=now --all
git gc --prune=now --aggressive

