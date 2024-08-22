#!/usr/bin/env bash
function git_sync() {
  message=$1
  diff=$(git status --short)
  if [[ -z $message ]]; then
    message=$diff
  fi
  echo "cur: $(pwd)"
  echo "diff: $diff"

  # 如果 message 为空 则输出  message is null
  if [[ -z "$diff" ]]; then
    echo "diff is empty"
    return 1
  fi
  echo "git commit  && git pushing..."
  git add . && git commit -m "$message" && git push origin main
}

cd ../
git_sync "$1"