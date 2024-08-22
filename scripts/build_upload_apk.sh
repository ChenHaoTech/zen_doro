if [ ! -f "./pubspec.yaml" ]; then
  cd ../
fi

VERSION=$(grep '^version: ' pubspec.yaml | sed 's/version: //')
echo "versions: $VERSION"
#  --obfuscate --split-debug-info ./debug_info
#fbuild apk && cd $cur/build/app/outputs/ && open .
#fbuild ios && cd $cur/build/ios/iphoneos/ && open .
flutter build apk -t ./lib/main.dart --release
open ./build/app/outputs/flutter-apk/
pwd
# 定义标题和备注信息
TITLE="Release $VERSION"
NOTES="Release version $VERSION, based on commit $GIT_HASH."
gh release delete "$VERSION" -y
# 创建 GitHub Release
gh release create $VERSION ./build/app/outputs/flutter-apk/app-release.apk --title "$TITLE" --notes "$NOTES"
