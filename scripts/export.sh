function build_export_dart(){
  cd "$1" ||exit
  # 如果 $2 是空, 那么使用 export.dart
  exp_path="$2"
  if [ -z "$exp_path" ]; then
    exp_path="export"
  fi
  exp_path="$exp_path.dart"

  touch "$exp_path"
  echo "">$exp_path
  for dir in *.dart ; do
    echo "export './${dir}';">>"$exp_path"
  done
}


build_export_dart ./