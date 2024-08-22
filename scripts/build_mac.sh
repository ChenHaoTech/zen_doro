##
#  aar               Build a repository containing an AAR and a POM file.
#  apk               Build an Android APK file from your app.
#  appbundle         Build an Android App Bundle file from your app.
#  bundle            Build the Flutter assets directory from your app.
#  ios               Build an iOS application bundle (macOS host only).
#  ios-framework     Produces .xcframeworks for a Flutter project and its plugins for integration into existing, plain iOS Xcode projects.
#  ipa               Build an iOS archive bundle and IPA for distribution (macOS host only).
#  macos             Build a macOS desktop application.
#  macos-framework   Produces .xcframeworks for a Flutter project and its plugins for integration into existing, plain macOS Xcode projects.
#  web               Build a web application bundle.
##
# 如果当前 目录下有pubspec.yaml, name 就不 cd ../
if [ ! -f "./pubspec.yaml" ]; then
  cd ../
fi
cur=$(pwd)

appName="ZenDoro"

#  --obfuscate --split-debug-info ./debug_info
#fbuild apk && cd $cur/build/app/outputs/ && open .
#fbuild ios && cd $cur/build/ios/iphoneos/ && open .
echo "flutter build -t ./lib/main.dart --release $*"
flutter build macos $* -t ./lib/main.dart --release &&
  echo $cur/build/macos/Build/Products/Release/
cd $cur/build/macos/Build/Products/Release/
if [ -d /Applications/${appName}.app ]; then
  sudo rm -rf /Applications/${appName}.app
  echo "删除了/Applications/${appName}.app"
fi
sudo cp -r ./${appName}.app /Applications/
#fbuild appbundle && cd $cur/build/app/outputs/ && open .
#frun web
